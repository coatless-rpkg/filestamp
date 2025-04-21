#' Check if path is a file
#'
#' @param path Character. Path to check.
#'
#' @return Logical. TRUE if path is a file.
#' @export
is_file <- function(path) {
  file.exists(path) && !dir.exists(path)
}

#' Check if file has a header
#'
#' @param file Character. Path to file.
#'
#' @return Logical. TRUE if file has a header.
#' @export
has_header <- function(file) {
  content <- readLines(file, n = 20)
  any(grepl("copyright|author|license", content, ignore.case = TRUE))
}

#' Ensure file exists
#'
#' @param file Character. Path to file.
#'
#' @return TRUE invisibly if file exists, otherwise aborts.
#' @keywords internal
ensure_file_exists <- function(file) {
  if (!file.exists(file)) {
    cli::cli_abort("File does not exist: {file}")
  }
  
  if (dir.exists(file)) {
    cli::cli_abort("Path is a directory, not a file: {file}")
  }
  
  invisible(TRUE)
}

#' Ensure directory exists
#'
#' @param dir Character. Path to directory.
#'
#' @return TRUE invisibly if directory exists, otherwise aborts.
#' @keywords internal
ensure_directory_exists <- function(dir) {
  if (!dir.exists(dir)) {
    cli::cli_abort("Directory does not exist: {dir}")
  }
  
  invisible(TRUE)
}

#' Ensure action is valid
#'
#' @param action Character. Action to check.
#'
#' @return TRUE invisibly if action is valid, otherwise aborts.
#' @keywords internal
ensure_valid_action <- function(action) {
  valid_actions <- c("modify", "dryrun", "backup")
  
  if (is.null(action) || !action %in% valid_actions) {
    cli::cli_abort("Invalid action: {action}. Must be one of: {paste(valid_actions, collapse = ', ')}")
  }
  
  invisible(TRUE)
}

#' Ensure template is valid
#'
#' @param template Object. Template to check.
#'
#' @return TRUE invisibly if template is valid, otherwise aborts.
#' @keywords internal
ensure_valid_template <- function(template) {
  if (!inherits(template, "stamp_template")) {
    cli::cli_abort("Invalid template. Must be a stamp_template object.")
  }
  
  invisible(TRUE)
}
