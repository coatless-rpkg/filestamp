#' Get file information (encoding, line endings, etc.)
#'
#' @param file Character. Path to file.
#'
#' @return stamp_file_info object.
#' @keywords internal
header_file_info <- function(file) {
  con <- file(file, "rb")
  on.exit(close(con))
  content <- readBin(con, "raw", n = file.info(file)$size)

  # Detect encoding
  encoding <- guess_encoding(content)

  # Detect line endings
  line_ending <- guess_line_ending(content)

  # Check if file is read-only
  read_only <- !file.access(file, 2) == 0

  structure(
    list(
      path = file,
      encoding = encoding,
      line_ending = line_ending,
      read_only = read_only
    ),
    class = "stamp_file_info"
  )
}

#' Guess file encoding
#'
#' @param content Raw vector. File content.
#'
#' @return Character. Encoding name.
#' @keywords internal
guess_encoding <- function(content) {
  # Check for BOM
  if (length(content) >= 3 &&
      content[1] == 0xEF && content[2] == 0xBB && content[3] == 0xBF) {
    return("UTF-8")
  }

  if (length(content) >= 2 &&
      content[1] == 0xFE && content[2] == 0xFF) {
    return("UTF-16BE")
  }

  if (length(content) >= 2 &&
      content[1] == 0xFF && content[2] == 0xFE) {
    return("UTF-16LE")
  }

  # Default to UTF-8
  "UTF-8"
}

#' Guess line endings
#'
#' @param content Raw vector. File content.
#'
#' @return Character. Line ending: `"\n"` (LF), `"\r"` (CR), or `"\r\n"(CRLF)`.
#' @keywords internal
guess_line_ending <- function(content) {
  # Convert to character
  text <- rawToChar(content)

  # Count line endings
  cr_count <- sum(gregexpr("\r", text, fixed = TRUE)[[1]] > 0)
  lf_count <- sum(gregexpr("\n", text, fixed = TRUE)[[1]] > 0)
  crlf_count <- sum(gregexpr("\r\n", text, fixed = TRUE)[[1]] > 0)

  if (crlf_count > 0) {
    return("\r\n")
  } else if (cr_count > 0) {
    return("\r")
  } else {
    return("\n")
  }
}
