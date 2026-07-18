# Copyright (c) 2025
# Author: James J Balamuta
# License: GNU Affero General Public License v3.0 or later
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

#' Stamp a single file with a header
#'
#' @param file Character. Path to file to stamp.
#' @param template Character or stamp_template object. Template to use for stamping.
#' @param action Character. Action to perform: "modify", "dryrun", or "backup".
#' @param ... Additional arguments passed to render_template.
#'
#' @return Result object, invisibly.
#' @export
stamp_file <- function(file, template = NULL, action = "modify", ...) {
  ensure_file_exists(file)
  ensure_valid_action(action)

  # Handle template selection/loading
  if (is.null(template)) {
    template <- stamp_template_default()
  } else if (is.character(template)) {
    template <- stamp_template_load(template)
  } else {
    ensure_valid_template(template)
  }

  language <- detect_language(file)

  # Skip files with no known comment syntax rather than corrupting them
  # (e.g. JSON, or any unregistered extension)
  if (is.null(language)) {
    cli::cli_warn(c(
      "Skipping {.file {file}}: unrecognized file type.",
      "i" = "No language with a known comment syntax is registered for this extension."
    ))
    return(invisible(FALSE))
  }

  # A dry run never writes, so preview and return before touching the file
  if (action == "dryrun") {
    return(invisible(preview_stamp(file, template, language, ...)))
  }

  # Write preconditions, checked BEFORE any backup so a skipped or aborted
  # operation never leaves an orphan .bck behind
  file_info <- header_file_info(file)
  if (file_info$read_only) {
    cli::cli_abort("File is read-only: {file}")
  }
  if (has_header(file)) {
    cli::cli_warn("File already has a header: {file}")
    return(invisible(FALSE))
  }

  if (action == "backup") {
    backup_file(file)
  }

  invisible(modify_file(file, template, language, ...))
}

#' Modify file with header
#'
#' @param file Character. Path to file to modify.
#' @param template stamp_template object. Template to use for stamping.
#' @param language stamp_language object. Detected language for formatting comments.
#' @param ... Additional arguments passed to render_template.
#'
#' @return TRUE invisibly on success.
#' @keywords internal
modify_file <- function(file, template, language, ...) {
  # Read file with original encoding and preserve attributes
  file_info <- header_file_info(file)

  # Check if file is read-only
  if (file_info$read_only) {
    cli::cli_abort("File is read-only: {file}")
  }

  content <- readLines(file, warn = FALSE, encoding = file_info$encoding)

  # Drop any leading BOM character from the first line; it is re-emitted as
  # raw bytes on write so it stays at the very start, ahead of the header
  if (file_info$has_bom && length(content) >= 1) {
    content[1] <- sub("^\ufeff", "", content[1])
  }

  # Check if file already has a header
  if (has_header(file)) {
    cli::cli_warn("File already has a header: {file}")
    return(invisible(FALSE))
  }

  # Render template
  rendered <- render_template(template, file, ...)

  # Format header, split into lines so every line ending is normalized below
  header <- format_header(rendered, language)
  header_lines <- unlist(strsplit(header, "\n", fixed = TRUE))

  # Determine insert position (shebang, YAML, etc.)
  insert_pos <- determine_insert_position(content)

  # Separate the header from any content that follows it with a blank line
  if (insert_pos < length(content) && nzchar(content[insert_pos + 1])) {
    header_lines <- c(header_lines, "")
  }

  # Insert header
  new_content <- append(content, header_lines, after = insert_pos)

  # Write back with original encoding and line endings, keeping the
  # file's final newline
  con <- file(file, "wb")
  on.exit(close(con))

  text <- paste0(paste(new_content, collapse = file_info$line_ending),
                 file_info$line_ending)

  # Write with original encoding, re-emitting a UTF-8 BOM if the file had one
  raw_out <- charToRaw(text)
  if (file_info$has_bom) {
    raw_out <- c(as.raw(c(0xEF, 0xBB, 0xBF)), raw_out)
  }
  writeBin(raw_out, con)

  invisible(TRUE)
}

#' Create backup of file
#'
#' @param file Character. Path to file to backup.
#'
#' @return Path to backup file, invisibly.
#' @export
backup_file <- function(file) {
  backup <- paste0(file, ".bck")
  file.copy(file, backup, overwrite = TRUE)
  invisible(backup)
}

#' Preview stamp without modifying
#'
#' @param file Character. Path to file to preview.
#' @param template stamp_template object. Template to use for stamping.
#' @param language stamp_language object. Detected language for formatting comments.
#' @param ... Additional arguments passed to render_template.
#'
#' @return stamp_preview object.
#' @keywords internal
preview_stamp <- function(file, template, language, ...) {
  file_info <- header_file_info(file)
  content <- readLines(file, warn = FALSE, encoding = file_info$encoding)

  rendered <- render_template(template, file, ...)
  header <- format_header(rendered, language)
  insert_pos <- determine_insert_position(content)

  structure(
    list(
      file = file,
      header = header,
      insert_position = insert_pos,
      encoding = file_info$encoding,
      line_ending = file_info$line_ending,
      read_only = file_info$read_only
    ),
    class = "stamp_preview"
  )
}

#' Determine where to insert header
#'
#' @param content Character vector. File content lines.
#'
#' @return Integer. Position to insert header (0 for beginning of file).
#' @keywords internal
determine_insert_position <- function(content) {
  # Insert after YAML front matter, if present
  yaml_end <- yaml_front_matter_end(content)
  if (yaml_end > 0) {
    return(yaml_end)
  }

  # Insert after a first-line language prologue that must stay first:
  # a shebang, a PHP open tag, an XML declaration, or an (X)HTML doctype.
  # Anything written before these is emitted verbatim / breaks parsing.
  if (length(content) > 0) {
    prologue <- paste(
      "^#!",                        # shebang
      "^\\s*<\\?php",               # PHP open tag
      "^\\s*<\\?xml",               # XML declaration
      "^\\s*<!DOCTYPE",             # (X)HTML doctype
      sep = "|"
    )
    if (grepl(prologue, content[1], ignore.case = TRUE)) {
      return(1L)
    }
  }

  # Default: insert at beginning
  0L
}
