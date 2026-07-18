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

#' Update an existing file header
#'
#' Revise a header that is already in a file, changing only the fields you name.
#' Each update is either a replacement value or a function that receives the
#' current value of the field and returns the new one. [year_extend()] and
#' [author_add()] build the two most useful such functions, and [stamp_edits()]
#' bundles a set of them for reuse. For the common tasks there are also dedicated
#' verbs, [stamp_bump_year()] and [stamp_add_author()].
#'
#' If `file` is a directory, every already-stamped file it contains is updated
#' and a `stamp_dir_results` object is returned.
#'
#' @param file Character. Path to a file or directory to update.
#' @param ... Named updates to apply to header fields (each value is a new value
#'   or a function of the field's current value), or a single [stamp_edits()]
#'   bundle.
#' @param action Character. Action to perform: "modify", "dryrun", or "backup".
#' @param recursive Logical. When `file` is a directory, descend into
#'   subdirectories.
#' @param pattern Character or NULL. When `file` is a directory, only update
#'   files whose name matches this pattern.
#'
#' @return TRUE invisibly on success (a `stamp_update_preview` for
#'   `action = "dryrun"`), or a `stamp_dir_results` object when `file` is a
#'   directory.
#' @seealso [stamp_bump_year()], [stamp_add_author()], [stamp_edits()],
#'   [year_extend()], [author_add()]
#' @examples
#' file <- tempfile(fileext = ".R")
#' writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "x <- 1"), file)
#'
#' stamp_update(file, copyright = year_extend(), author = author_add("Sam"))
#' readLines(file)[1:2]
#' @export
stamp_update <- function(file, ..., action = "modify", recursive = FALSE,
                         pattern = NULL) {
  ensure_valid_action(action)
  updates <- collect_edits(list(...))

  # A directory updates every already-stamped file it contains
  if (dir.exists(file)) {
    files <- header_find_files(file, pattern, recursive)
    files <- files[vapply(files, has_header, logical(1))]
    cli::cli_alert_info("Updating {length(files)} file{?s} in {file}")

    results <- lapply(files, function(f) {
      tryCatch({
        res <- update_one_file(f, updates, action)
        list(file = f, status = if (isFALSE(res)) "skipped" else "success")
      }, error = function(e) {
        list(file = f, status = "error", message = conditionMessage(e))
      })
    })

    return(structure(
      list(results = results, dir = file, action = action,
           operation = "Updating"),
      class = "stamp_dir_results"
    ))
  }

  ensure_file_exists(file)
  update_one_file(file, updates, action)
}

#' Flatten stamp_edits bundles and inline updates into one named list
#'
#' @param dots List captured from `...`.
#'
#' @return A named list of updates.
#' @keywords internal
collect_edits <- function(dots) {
  is_bundle <- vapply(dots, inherits, logical(1), "stamp_edits")
  if (any(is_bundle)) {
    bundled <- do.call(c, lapply(dots[is_bundle], unclass))
    dots <- c(bundled, dots[!is_bundle])
  }
  dots
}

#' Apply header updates to a single file
#'
#' @param file Character. Path to file.
#' @param updates Named list of updates.
#' @param action Character. Action to perform.
#'
#' @return TRUE invisibly, FALSE if skipped, or a preview object for "dryrun".
#' @keywords internal
update_one_file <- function(file, updates, action) {
  if (!has_header(file)) {
    cli::cli_warn("File does not have a header: {file}")
    return(invisible(FALSE))
  }

  header <- extract_header(file)
  for (field in names(updates)) {
    header <- update_header_field(header, field, updates[[field]])
  }

  switch(action,
         "dryrun" = preview_update(file, header),
         "backup" = {
           backup_file(file)
           update_file_header(file, header, requested = names(updates))
         },
         "modify" = update_file_header(file, header, requested = names(updates)))
}

#' Bump the copyright year in a file header
#'
#' A convenience wrapper around [stamp_update()] that extends the header's
#' copyright field to the current year, keeping the owner and start year (see
#' [year_extend()]).
#'
#' @inheritParams stamp_update
#'
#' @return TRUE invisibly on success, or a `stamp_update_preview` object when
#'   `action = "dryrun"`.
#' @seealso [stamp_update()], [stamp_add_author()]
#' @examples
#' file <- tempfile(fileext = ".R")
#' writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "x <- 1"), file)
#'
#' stamp_bump_year(file)
#' readLines(file)[1]
#' @export
stamp_bump_year <- function(file, action = "modify", recursive = FALSE,
                            pattern = NULL) {
  stamp_update(file, copyright = year_extend(), action = action,
               recursive = recursive, pattern = pattern)
}

#' Add an author to a file header
#'
#' A convenience wrapper around [stamp_update()] that appends an author to the
#' header's author field without duplicating anyone already listed (see
#' [author_add()]).
#'
#' @inheritParams stamp_update
#' @param author Character. Author to add.
#'
#' @return TRUE invisibly on success, or a `stamp_update_preview` object when
#'   `action = "dryrun"`.
#' @seealso [stamp_update()], [stamp_bump_year()]
#' @examples
#' file <- tempfile(fileext = ".R")
#' writeLines(c("# Copyright (c) 2020", "# Author: Jane Doe", "", "x <- 1"), file)
#'
#' stamp_add_author(file, "Sam Smith")
#' readLines(file)[2]
#' @export
stamp_add_author <- function(file, author, action = "modify",
                             recursive = FALSE, pattern = NULL) {
  stamp_update(file, author = author_add(author), action = action,
               recursive = recursive, pattern = pattern)
}

#' Bundle header edits for reuse
#'
#' Collects a set of named header updates into a reusable object you can inspect
#' and apply to one or many files with [stamp_update()]. Each edit is a new value
#' or a function of the field's current value, exactly as in [stamp_update()].
#'
#' @param ... Named header edits. Each value is a new value or a function of the
#'   field's current value (see [year_extend()] and [author_add()]).
#'
#' @return A `stamp_edits` object.
#' @seealso [stamp_update()], [year_extend()], [author_add()]
#' @examples
#' edits <- stamp_edits(copyright = year_extend(), author = author_add("Sam"))
#' edits
#'
#' file <- tempfile(fileext = ".R")
#' writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "x <- 1"), file)
#' stamp_update(file, edits)
#' @export
stamp_edits <- function(...) {
  edits <- list(...)
  nms <- names(edits)
  if (length(edits) > 0 && (is.null(nms) || any(!nzchar(nms)))) {
    cli::cli_abort(c(
      "Every edit must be named.",
      "i" = "For example, {.code stamp_edits(author = author_add(\"Sam\"))}."
    ))
  }
  structure(edits, class = "stamp_edits")
}

#' Extract header from file
#'
#' @param file Character. Path to file.
#'
#' @return List with header information, or NULL if the file has no header.
#' @keywords internal
extract_header <- function(file) {
  content <- readLines(file, warn = FALSE)

  # Find candidate header field lines (see header_field_lines(); this
  # excludes roxygen doc comments, data files, and prose that merely
  # mentions a license), ignoring anything inside YAML front matter
  header_lines <- which(header_field_lines(content))
  header_lines <- header_lines[header_lines > yaml_front_matter_end(content)]

  if (length(header_lines) == 0) {
    return(NULL)
  }

  # Group consecutive lines and take the topmost group: the file header is
  # the first header-shaped block, anything later is content quoting one
  header_groups <- split(header_lines, cumsum(c(1, diff(header_lines) != 1)))
  header_range <- range(header_groups[[1]])

  # Extend the range over adjacent short "Field: value" comment lines so
  # template fields beyond the recognized ones (e.g. "Last updated:") are
  # included
  field_ish <- paste0(
    "^\\s*+(?:<!--|-{2,}+|[#/*;%!=]++)?+\\s*+",
    "[A-Za-z][A-Za-z_-]*(?: [A-Za-z][A-Za-z_-]*){0,2}\\s*+:(?=\\s|$)"
  )
  is_field_ish <- function(i) {
    i >= 1 && i <= length(content) &&
      grepl(field_ish, content[i], ignore.case = TRUE, perl = TRUE, useBytes = TRUE)
  }
  while (is_field_ish(header_range[1] - 1L)) header_range[1] <- header_range[1] - 1L
  while (is_field_ish(header_range[2] + 1L)) header_range[2] <- header_range[2] + 1L

  # Extract fields
  fields <- list()

  for (i in header_range[1]:header_range[2]) {
    line <- content[i]

    # Extract field name and value using regex with multiple patterns

    # Pattern 1: Field: Value (field names may span up to three words,
    # e.g. "Last updated")
    matches <- regmatches(line, regexec(
      "([A-Za-z][A-Za-z_-]*(?: [A-Za-z][A-Za-z_-]*){0,2})\\s*[:-]\\s*(.*)", line))

    # Pattern 2: Field (c) Value (for copyright)
    if (length(matches[[1]]) < 3) {
      matches <- regmatches(line, regexec("([A-Za-z_-]+)\\s*\\([^)]*\\)\\s*(.*)", line))
    }

    # Pattern 3: Field Value (no separator)
    if (length(matches[[1]]) < 3) {
      matches <- regmatches(line, regexec("([A-Za-z_-]+)\\s+(.*)", line))
    }

    if (length(matches[[1]]) >= 3) {
      # Normalize multi-word names to snake_case ("Last updated" -> "last_updated")
      field_name <- gsub("\\s+", "_", tolower(trimws(matches[[1]][2])))
      field_value <- trimws(matches[[1]][3])

      fields[[field_name]] <- field_value
    }
  }

  list(
    range = header_range,
    fields = fields,
    content = content
  )
}


#' Update a header field
#'
#' @param header List. Header information from extract_header.
#' @param field Character. Field name to update.
#' @param update Function or character. Update to apply.
#'
#' @return Updated header list.
#' @keywords internal
update_header_field <- function(header, field, update) {
  # Get current value
  current <- header$fields[[field]]

  # Apply update
  if (is.function(update)) {
    new_value <- update(current)
  } else {
    new_value <- update
  }

  # Update field
  header$fields[[field]] <- new_value

  header
}

#' Update file header
#'
#' @param file Character. Path to file.
#' @param header List. Header information from extract_header.
#' @param requested Character. Field names the caller asked to update; a
#'   warning is emitted for any of these not found in the header.
#'
#' @return TRUE invisibly on success.
#' @keywords internal
update_file_header <- function(file, header, requested = names(header$fields)) {
  file_info <- header_file_info(file)
  content <- header$content

  # Check if file is read-only
  if (file_info$read_only) {
    cli::cli_abort("File is read-only: {file}")
  }

  # Update header lines
  updated <- character(0)
  for (field in names(header$fields)) {
    # Escape regex metacharacters in the field name; let underscores match
    # the spaces used in the file ("last_updated" ~ "Last updated")
    field_re <- gsub("_", "[ _]", regex_escape(field))

    # Match field name with various patterns
    patterns <- c(
      # Field: Value
      paste0("(", field_re, "\\s*[:-]\\s*).*"),
      # Field (c) Value
      paste0("(", field_re, "\\s*\\([^)]*\\)\\s*).*"),
      # Field Value
      paste0("(", field_re, "\\s+).*")
    )

    # Backslashes in the value must be written literally, not interpreted
    # as replacement backreferences
    value <- gsub("\\\\", "\\\\\\\\", header$fields[[field]])

    for (i in header$range[1]:header$range[2]) {
      for (pattern in patterns) {
        if (grepl(pattern, content[i], ignore.case = TRUE)) {
          content[i] <- sub(pattern, paste0("\\1", value), content[i],
                            ignore.case = TRUE)
          updated <- c(updated, field)
          break  # Stop after first successful replacement
        }
      }
    }
  }

  # Warn about requested fields that could not be located, rather than
  # silently reporting success while changing nothing
  not_found <- setdiff(requested, updated)
  if (length(not_found) > 0) {
    cli::cli_warn(c(
      "Could not locate {length(not_found)} requested field{?s} in the header of {.file {file}}.",
      "!" = "Not updated: {.field {not_found}}."
    ))
  }

  # Write back with original encoding and line endings, keeping the
  # file's final newline
  con <- file(file, "wb")
  on.exit(close(con))

  text <- paste0(paste(content, collapse = file_info$line_ending),
                 file_info$line_ending)
  writeBin(charToRaw(text), con)

  invisible(TRUE)
}

#' Preview header update
#'
#' @param file Character. Path to file.
#' @param header List. Header information from extract_header.
#'
#' @return stamp_update_preview object.
#' @keywords internal
preview_update <- function(file, header) {
  file_info <- header_file_info(file)

  structure(
    list(
      file = file,
      fields = header$fields,
      range = header$range,
      encoding = file_info$encoding,
      line_ending = file_info$line_ending,
      read_only = file_info$read_only
    ),
    class = "stamp_update_preview"
  )
}

#' Build a copyright-year updater
#'
#' Returns a function that extends a copyright field to the current year,
#' keeping the owner name and any existing start year. Pass it as a named
#' update to [stamp_update()], or use [stamp_bump_year()] to apply it directly
#' to a file.
#'
#' @param initial_year Character or NULL. Start year to use when the field has
#'   no year yet.
#'
#' @return A function of the current field value, suitable as an update in
#'   [stamp_update()].
#' @seealso [stamp_update()], [stamp_bump_year()], [author_add()]
#' @examples
#' extend <- year_extend()
#' extend("Acme Corp 2020")
#' @export
year_extend <- function(initial_year = NULL) {
  updater <- function(current) {
    current <- if (is.null(current)) "" else current
    now <- format(Sys.Date(), "%Y")
    years <- extract_years(current)

    # Preserve the owner/company text: everything that is not a year token
    prefix <- gsub("\\s*\\b\\d{4}\\s*(-\\s*\\d{4})?\\b\\s*", " ", current)
    prefix <- trimws(gsub("\\s+", " ", prefix))
    prefix <- trimws(gsub(",+$", "", prefix))

    start <- if (length(years) == 0) {
      if (is.null(initial_year)) now else initial_year
    } else {
      min(years)
    }

    # Avoid a degenerate "2026-2026" range when nothing needs extending
    year_str <- if (as.character(start) == now) now else paste0(start, "-", now)

    if (nzchar(prefix)) paste(prefix, year_str) else year_str
  }
  attr(updater, "desc") <- "extend the copyright year"
  updater
}

#' Build an author-add updater
#'
#' Returns a function that appends an author to an author field without
#' duplicating anyone already listed. Pass it as a named update to
#' [stamp_update()], or use [stamp_add_author()] to apply it directly to a file.
#'
#' @param new_author Character. Author to add.
#'
#' @return A function of the current field value, suitable as an update in
#'   [stamp_update()].
#' @seealso [stamp_update()], [stamp_add_author()], [year_extend()]
#' @examples
#' add <- author_add("Sam Smith")
#' add("Jane Doe")
#' @export
author_add <- function(new_author) {
  updater <- function(current) {
    if (is.null(current) || current == "") {
      return(new_author)
    }

    # Split on separators, handling the Oxford comma (", and ") before the
    # plain comma so a 3+ author list does not leave "and X" fused together
    authors <- unlist(strsplit(current, "\\s*,\\s*and\\s+|\\s*,\\s*|\\s+and\\s+"))

    if (new_author %in% authors) {
      return(current)  # Author already exists
    }

    if (length(authors) == 1) {
      return(paste(current, "and", new_author))
    } else {
      authors <- c(authors, new_author)
      last <- authors[length(authors)]
      rest <- authors[-length(authors)]
      return(paste0(paste(rest, collapse = ", "), ", and ", last))
    }
  }
  attr(updater, "desc") <- paste0("add ", encodeString(new_author, quote = "\""))
  updater
}

#' Extract years from a string
#'
#' @param text Character. Text to extract years from.
#'
#' @return Numeric vector of years.
#' @keywords internal
extract_years <- function(text) {
  # Extract 4-digit numbers
  matches <- regmatches(text, gregexpr("\\b\\d{4}\\b", text))
  as.numeric(unlist(matches))
}
