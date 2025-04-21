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

#' Register a new language
#'
#' @param name Character. Language name.
#' @param extensions Character vector. File extensions.
#' @param comment_single Character. Single-line comment marker.
#' @param comment_multi_start Character or NULL. Multi-line comment start.
#' @param comment_multi_end Character or NULL. Multi-line comment end.
#'
#' @return stamp_language object, invisibly.
#' @export
language_register <- function(name, extensions, comment_single,
                              comment_multi_start = NULL, comment_multi_end = NULL) {
  lang <- structure(
    list(
      name = name,
      extensions = extensions,
      comment_single = comment_single,
      comment_multi_start = comment_multi_start,
      comment_multi_end = comment_multi_end
    ),
    class = "stamp_language"
  )

  langs <- getOption("filestamp.languages", list())
  langs[[name]] <- lang
  options(filestamp.languages = langs)

  invisible(lang)
}

#' Get registered language
#'
#' @param name Character. Language name.
#'
#' @return stamp_language object.
#' @export
language_get <- function(name) {
  langs <- getOption("filestamp.languages", list())

  if (!name %in% names(langs)) {
    cli::cli_abort("Language not found: {name}")
  }

  langs[[name]]
}

#' List all registered languages
#'
#' @return Named list of stamp_language objects.
#' @export
languages <- function() {
  getOption("filestamp.languages", list())
}

#' Detect language based on file extension
#'
#' @param file Character. Path to file.
#'
#' @return stamp_language object.
#' @export
detect_language <- function(file) {
  ext <- tolower(tools::file_ext(file))

  langs <- languages()

  for (lang_name in names(langs)) {
    lang <- langs[[lang_name]]
    if (ext %in% lang$extensions) {
      return(lang)
    }
  }

  # Default to plain text
  language_get("text")
}

#' Format header according to language's comment style
#'
#' @param content Character. Header content.
#' @param language stamp_language object. Language for comment formatting.
#'
#' @return Character. Formatted header.
#' @keywords internal
format_header <- function(content, language) {
  # Ensure content is properly split into lines
  lines <- unlist(strsplit(content, "\n"))

  if (!is.null(language$comment_multi_start) && !is.null(language$comment_multi_end)) {
    # Use multi-line comments
    paste0(
      language$comment_multi_start, "\n",
      paste(lines, collapse = "\n"),
      "\n", language$comment_multi_end
    )
  } else {
    # Use single-line comments
    paste(
      paste0(language$comment_single, " ", lines),
      collapse = "\n"
    )
  }
}
