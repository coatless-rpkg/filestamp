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

  result <- switch(action,
                   "dryrun" = preview_stamp(file, template, language, ...),
                   "backup" = {
                     backup_file(file)
                     modify_file(file, template, language, ...)
                   },
                   "modify" = modify_file(file, template, language, ...))

  invisible(result)
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

  # Check if file already has a header
  if (has_header(file)) {
    cli::cli_warn("File already has a header: {file}")
    return(invisible(FALSE))
  }

  # Render template
  rendered <- render_template(template, file, ...)

  # Format header
  header <- format_header(rendered, language)

  # Determine insert position (shebang, YAML, etc.)
  insert_pos <- determine_insert_position(content)

  # Insert header
  new_content <- c(
    if (insert_pos > 0) content[1:insert_pos] else NULL,
    header,
    if (insert_pos >= 0) content[(insert_pos + 1):length(content)] else content
  )

  # Write back with original encoding and line endings
  con <- file(file, "wb")
  on.exit(close(con))

  # Convert to original line endings
  text <- paste(new_content, collapse = file_info$line_ending)

  # Write with original encoding
  writeBin(charToRaw(text), con)

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
  # Check for shebang
  has_shebang <- length(content) > 0 && grepl("^#!", content[1])

  # Check for YAML header
  yaml_start <- which(grepl("^---\\s*$", content))[1]

  if (!is.na(yaml_start) && yaml_start == 1) {
    # Find end of YAML header
    yaml_end <- which(grepl("^---\\s*$", content))

    if (length(yaml_end) > 1) {
      return(yaml_end[2])
    }
  }

  if (has_shebang) {
    return(1)
  }

  # Default: insert at beginning
  return(0)
}
