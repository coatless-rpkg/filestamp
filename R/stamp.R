#' Stamp a file or directory with a header
#'
#' This is the main entry point for the filestamp package. It automatically
#' detects if the path is a file or directory and calls the appropriate function.
#'
#' @param path Character. Path to file or directory to stamp.
#' @param template Character or stamp_template object. Template to use for stamping.
#' @param action Character. Action to perform: "modify", "dryrun", or "backup".
#' @param ... Additional arguments passed to stamp_file or stamp_dir.
#'
#' @return Result object, invisibly.
#' @export
stamp <- function(path, template = NULL, action = "modify", ...) {
  if (file.info(path)$isdir) {
    stamp_dir(path, template, action, ...)
  } else {
    stamp_file(path, template, action, ...)
  }
}
