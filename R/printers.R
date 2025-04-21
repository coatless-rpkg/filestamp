#' Print method for templates
#'
#' @param x stamp_template object.
#' @param ... Additional arguments.
#'
#' @return The stamp_template object, invisibly.
#' @export
#' @method print stamp_template
print.stamp_template <- function(x, ...) {
  cli::cli_h1("Template: {x$name}")
  
  cli::cli_h2("Fields:")
  for (field_name in names(x$fields)) {
    field <- x$fields[[field_name]]
    default <- if (is.null(field$default)) "<none>" else field$default
    required <- if (field$required) "Required" else "Optional"
    cli::cli_li("{field_name}: {default} ({required})")
  }
  
  cli::cli_h2("Content:")
  cli::cli_code(x$content)
  
  invisible(x)
}

#' Print method for stamp preview
#'
#' @param x stamp_preview object.
#' @param ... Additional arguments.
#'
#' @return The stamp_preview object, invisibly.
#' @export
#' @method print stamp_preview
print.stamp_preview <- function(x, ...) {
  cli::cli_h1("Preview for: {x$file}")
  
  cli::cli_h2("Header to be inserted:")
  cli::cli_code(x$header)
  
  cli::cli_h2("Insertion point:")
  if (x$insert_position == 0) {
    cli::cli_text("Beginning of file")
  } else if (x$insert_position == 1) {
    cli::cli_text("After shebang")
  } else {
    cli::cli_text("Line {x$insert_position}")
  }
  
  cli::cli_h2("File properties:")
  cli::cli_li("Encoding: {x$encoding}")
  cli::cli_li("Line ending: {if (x$line_ending == '\n') 'LF' else if (x$line_ending == '\r') 'CR' else 'CRLF'}")
  cli::cli_li("Read-only: {if (x$read_only) 'Yes' else 'No'}")
  
  invisible(x)
}

#' Print method for language
#'
#' @param x stamp_language object.
#' @param ... Additional arguments.
#'
#' @return The stamp_language object, invisibly.
#' @export
#' @method print stamp_language
print.stamp_language <- function(x, ...) {
  cli::cli_h1("Language: {x$name}")
  
  cli::cli_h2("File extensions:")
  extensions <- paste(x$extensions, collapse = ", ")
  cli::cli_text(extensions)
  
  cli::cli_h2("Comment style:")
  cli::cli_li("Single line: {x$comment_single}")
  
  if (!is.null(x$comment_multi_start) && !is.null(x$comment_multi_end)) {
    cli::cli_li("Multi-line start: {x$comment_multi_start}")
    cli::cli_li("Multi-line end: {x$comment_multi_end}")
  }
  
  invisible(x)
}

#' Print method for directory results
#'
#' @param x stamp_dir_results object.
#' @param ... Additional arguments.
#'
#' @return The stamp_dir_results object, invisibly.
#' @export
#' @method print stamp_dir_results
print.stamp_dir_results <- function(x, ...) {
  cli::cli_h1("Directory Stamping Results: {x$dir}")
  
  cli::cli_h2("Action: {x$action}")
  
  success_count <- sum(sapply(x$results, function(r) r$status == "success"))
  error_count <- sum(sapply(x$results, function(r) r$status == "error"))
  
  cli::cli_alert_success("{success_count} files successfully processed")
  
  if (error_count > 0) {
    cli::cli_alert_danger("{error_count} files had errors")
    
    cli::cli_h2("Errors:")
    for (result in x$results) {
      if (result$status == "error") {
        cli::cli_li("{result$file}: {result$message}")
      }
    }
  }
  
  invisible(x)
}

#' Print method for file info
#'
#' @param x stamp_file_info object.
#' @param ... Additional arguments.
#'
#' @return The stamp_file_info object, invisibly.
#' @export
#' @method print stamp_file_info
print.stamp_file_info <- function(x, ...) {
  cli::cli_h1("File Information: {x$path}")
  
  cli::cli_li("Encoding: {x$encoding}")
  cli::cli_li("Line ending: {if (x$line_ending == '\n') 'LF' else if (x$line_ending == '\r') 'CR' else 'CRLF'}")
  cli::cli_li("Read-only: {if (x$read_only) 'Yes' else 'No'}")
  
  invisible(x)
}

#' Print method for update preview
#'
#' @param x stamp_update_preview object.
#' @param ... Additional arguments.
#'
#' @return The stamp_update_preview object, invisibly.
#' @export
#' @method print stamp_update_preview
print.stamp_update_preview <- function(x, ...) {
  cli::cli_h1("Update Preview for: {x$file}")
  
  cli::cli_h2("Updated fields:")
  for (field_name in names(x$fields)) {
    cli::cli_li("{field_name}: {x$fields[[field_name]]}")
  }
  
  cli::cli_h2("Header location:")
  cli::cli_text("Lines {x$range[1]} to {x$range[2]}")
  
  cli::cli_h2("File properties:")
  cli::cli_li("Encoding: {x$encoding}")
  cli::cli_li("Line ending: {if (x$line_ending == '\n') 'LF' else if (x$line_ending == '\r') 'CR' else 'CRLF'}")
  cli::cli_li("Read-only: {if (x$read_only) 'Yes' else 'No'}")
  
  invisible(x)
}