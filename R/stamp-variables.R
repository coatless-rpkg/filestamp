#' Get built-in variables
#'
#' @return Environment with built-in variables.
#' @export
stamp_variables <- function() {
  # Get stored variables if available
  vars <- getOption("filestamp.variables")

  if (!is.null(vars)) {
    return(vars)
  }

  # Create new environment
  env <- new.env(parent = emptyenv())

  # File-related variables
  env$cwd <- function() getwd()
  env$file_ext <- function() tools::file_ext(get("file", envir = parent.frame()))
  env$filename <- function() basename(get("file", envir = parent.frame()))

  # Date-related variables
  env$date_full <- function() format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  env$date <- function() format(Sys.time(), "%Y-%m-%d")
  env$year <- function() format(Sys.time(), "%Y")

  # User-related variables
  env$user <- function() Sys.getenv("USER", Sys.info()["user"])

  # Company (from options)
  env$company <- function() getOption("filestamp.company", default = "Your Company")

  # Store in options
  options(filestamp.variables = env)

  return(env)
}

#' Add custom variable
#'
#' @param name Character. Variable name.
#' @param value Any. Variable value or function.
#'
#' @return Environment with all variables.
#' @export
stamp_variables_add <- function(name, value) {
  vars <- stamp_variables()
  vars[[name]] <- value
  options(filestamp.variables = vars)
  invisible(vars)
}

#' List all available variables
#'
#' @return Character vector of variable names.
#' @export
stamp_variables_list <- function() {
  vars <- stamp_variables()
  ls(vars)
}
