#' Stamp all files in a directory with a header
#'
#' @param dir Character. Path to directory to stamp.
#' @param template Character or stamp_template object. Template to use for stamping.
#' @param action Character. Action to perform: "modify", "dryrun", or "backup".
#' @param pattern Character. File pattern to match (passed to list.files).
#' @param recursive Logical. Whether to search recursively.
#' @param ... Additional arguments passed to stamp_file.
#'
#' @return stamp_dir_results object.
#' @export
stamp_dir <- function(dir, template = NULL, action = "modify", pattern = NULL,
                      recursive = FALSE, ...) {
  ensure_directory_exists(dir)
  ensure_valid_action(action)

  files <- header_find_files(dir, pattern, recursive)

  cli::cli_alert_info("Stamping {length(files)} files in {dir}")

  results <- lapply(files, function(file) {
    tryCatch({
      stamp_file(file, template, action, ...)
      list(file = file, status = "success")
    }, error = function(e) {
      list(file = file, status = "error", message = conditionMessage(e))
    })
  })

  # Return result object with class for pretty printing
  structure(
    list(results = results, dir = dir, action = action),
    class = "stamp_dir_results"
  )
}

#' Find files in a directory
#'
#' @param dir Character. Directory to search.
#' @param pattern Character. File pattern to match (passed to list.files).
#' @param recursive Logical. Whether to search recursively.
#'
#' @return Character vector of file paths.
#' @keywords internal
header_find_files <- function(dir, pattern = NULL, recursive = FALSE) {
  files <- list.files(
    path = dir,
    pattern = pattern,
    recursive = recursive,
    full.names = TRUE
  )

  # Filter directories
  files[!file.info(files)$isdir]
}
