#' Register default languages on package load
#'
#' @keywords internal
.onLoad <- function(libname, pkgname) {
  # Register default languages
  # TODO: Consider trying to pre-load languages into an environment?
  language_register(
    "text",
    extensions = c("txt"),
    comment_single = "#"
  )

  language_register(
    "r",
    extensions = c("r", "R"),
    comment_single = "#"
  )

  language_register(
    "python",
    extensions = c("py", "pyw"),
    comment_single = "#",
    comment_multi_start = '"""',
    comment_multi_end = '"""'
  )

  language_register(
    "c",
    extensions = c("c", "h"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "cpp",
    extensions = c("cpp", "hpp", "cc", "hh", "cxx", "hxx"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "java",
    extensions = c("java"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "javascript",
    extensions = c("js", "jsx"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "typescript",
    extensions = c("ts", "tsx"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "ruby",
    extensions = c("rb"),
    comment_single = "#",
    comment_multi_start = "=begin",
    comment_multi_end = "=end"
  )

  language_register(
    "rust",
    extensions = c("rs"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "perl",
    extensions = c("pl", "pm"),
    comment_single = "#"
  )

  language_register(
    "php",
    extensions = c("php"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "shell",
    extensions = c("sh", "bash"),
    comment_single = "#"
  )

  language_register(
    "sql",
    extensions = c("sql"),
    comment_single = "--",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  language_register(
    "yaml",
    extensions = c("yml", "yaml"),
    comment_single = "#"
  )

  language_register(
    "markdown",
    extensions = c("md", "markdown"),
    comment_single = "<!--",
    comment_multi_start = "<!--",
    comment_multi_end = "-->"
  )

  language_register(
    "html",
    extensions = c("html", "htm"),
    comment_single = "<!--",
    comment_multi_start = "<!--",
    comment_multi_end = "-->"
  )

  language_register(
    "css",
    extensions = c("css"),
    comment_single = "/*",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )
}
