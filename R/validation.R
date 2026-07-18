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

#' Check if path is a file
#'
#' @param path Character. Path to check.
#'
#' @return Logical. TRUE if path is a file.
#' @export
is_file <- function(path) {
  file.exists(path) && !dir.exists(path)
}

#' Build the header field regular expression
#'
#' @param require_marker Logical. Require a comment marker before the field?
#'
#' @return Character. A perl-compatible regular expression.
#' @keywords internal
header_field_regex <- function(require_marker = FALSE) {
  # Comment marker: <!--, a run of two or more dashes (SQL, Haskell, Lua),
  # or a run of #, /, *, ;, %, !, = followed by whitespace or end of line.
  # Markdown syntax (**License:**, "- Author:", "## License-related") and
  # doc comments (roxygen's #') all fail these requirements. Possessive
  # quantifiers (*+, ++) keep matching linear on pathological input.
  marker <- "(?:<!--|-{2,}+(?=\\s|$)|[#/*;%!=]++(?=\\s|$))"

  # Header fields, anchored at the start of the comment content:
  # - Copyright followed by (c), the copyright sign, a colon, a year, or a
  #   capitalized owner name ("Copyright ACME Inc.")
  # - Author(s)/Licen[sc]e(s) followed by a separator and whitespace
  # - Apache-style "Licensed under ..." and "All rights reserved."
  fields <- paste0(
    "(?:copyright\\s*+(?:\\(c\\)|\u00a9|:|\\d{4}|(?-i:[A-Z]))",
    "|authors?\\s*+[:-](?=\\s|$)",
    "|licen[sc]es?\\s*+[:-](?=\\s|$)",
    "|licen[sc]ed\\s++under\\b",
    "|all\\s++rights\\s++reserved\\b)"
  )

  if (require_marker) {
    paste0("^\\s*+", marker, "\\s*+", fields)
  } else {
    paste0("^\\s*+", marker, "?+\\s*+", fields)
  }
}

#' Check if lines look like file header fields
#'
#' A header line is a comment (or bare, for multi-line comment blocks) line
#' whose content *starts* with a recognizable header field such as
#' `Copyright (c) ...`, `Author: ...`, or `License: ...`. Anchoring the match
#' to the start of the comment content avoids false positives from
#' documentation comments (e.g. roxygen's `#' @author`), prose that merely
#' mentions a license, markdown syntax, and code that manipulates these
#' keywords.
#'
#' @param lines Character vector. Lines to test.
#'
#' @return Logical vector. TRUE for lines that look like header fields.
#' @keywords internal
is_header_line <- function(lines) {
  grepl(header_field_regex(), lines,
        ignore.case = TRUE, perl = TRUE, useBytes = TRUE)
}

#' Identify header field lines in file content
#'
#' Comment-marked field lines always count. Bare (marker-less) field lines --
#' the body of Python docstrings, C block comments, and the like -- only
#' count when a block-comment opener appears on the same or an earlier line,
#' so data files (YAML configs and friends) are not mistaken for headers.
#'
#' @param lines Character vector. File content lines.
#'
#' @return Logical vector. TRUE for lines that are part of a header.
#' @keywords internal
header_field_lines <- function(lines) {
  marked <- grepl(header_field_regex(require_marker = TRUE), lines,
                  ignore.case = TRUE, perl = TRUE, useBytes = TRUE)
  bare <- grepl(header_field_regex(require_marker = FALSE), lines,
                ignore.case = TRUE, perl = TRUE, useBytes = TRUE) & !marked

  # Block-comment openers that make bare field lines credible. Covers every
  # block-comment style used by a registered language (see zzz.R): Python
  # triple quotes, C-style /*, (X)HTML/markdown <!--, PowerShell <#, Julia
  # #=, Haskell {-, Lua --[[, Ruby =begin, Perl =pod.
  opener <- grepl("^\\s*+(?:\"\"\"|'''|/\\*|<!--|<#|#=|\\{-|--\\[\\[|=begin|=pod)",
                  lines, perl = TRUE, useBytes = TRUE)

  marked | (bare & cumsum(opener) > 0)
}

#' Check if file has a header
#'
#' Looks for header field lines (see [header_field_lines()]) in the first 30
#' lines of the file. Documentation comments such as roxygen blocks, YAML
#' metadata fields (e.g. `author:` in an R Markdown document or a YAML
#' config), and markdown syntax are not considered headers.
#'
#' @param file Character. Path to file.
#'
#' @return Logical. TRUE if file has a header.
#' @export
has_header <- function(file) {
  content <- readLines(file, warn = FALSE)
  region <- content[seq_len(min(length(content), 30L))]
  any(header_field_lines(region))
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
