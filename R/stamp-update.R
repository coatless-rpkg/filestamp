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

#' Update existing file headers
#'
#' @param file Character. Path to file to update.
#' @param updates Named list. Updates to apply to header fields.
#' @param action Character. Action to perform: "modify", "dryrun", or "backup".
#'
#' @return TRUE invisibly on success.
#' @export
stamp_update <- function(file, updates, action = "modify") {
  ensure_file_exists(file)
  ensure_valid_action(action)

  if (!has_header(file)) {
    cli::cli_warn("File does not have a header: {file}")
    return(invisible(FALSE))
  }

  header <- extract_header(file)

  # Apply updates to header fields
  for (field in names(updates)) {
    header <- update_header_field(header, field, updates[[field]])
  }

  # Process based on selected action
  switch(action,
         "dryrun" = preview_update(file, header),
         "backup" = {
           backup_file(file)
           update_file_header(file, header)
         },
         "modify" = update_file_header(file, header))
}

#' Extract header from file
#'
#' @param file Character. Path to file.
#'
#' @return List with header information.
#' @keywords internal
extract_header <- function(file) {
  content <- readLines(file, warn = FALSE)

  # TODO: Rewrite this section to be more robus
  # This gets us a decent guess at the header range; but it may not be perfect.

  # Find header boundaries (look for copyright, author, license)
  header_lines <- grep("copyright|author|license", content, ignore.case = TRUE)

  if (length(header_lines) == 0) {
    return(NULL)
  }

  # Group consecutive lines
  header_groups <- split(header_lines, cumsum(c(1, diff(header_lines) != 1)))

  # Choose the largest group
  largest_group <- which.max(sapply(header_groups, length))
  header_range <- range(header_groups[[largest_group]])

  # Extract fields
  fields <- list()

  for (i in header_range[1]:header_range[2]) {
    line <- content[i]

    # Extract field name and value using regex with multiple patterns

    # Pattern 1: Field: Value
    matches <- regmatches(line, regexec("([A-Za-z_-]+)\\s*[:-]\\s*(.*)", line))

    # Pattern 2: Field (c) Value (for copyright)
    if (length(matches[[1]]) < 3) {
      matches <- regmatches(line, regexec("([A-Za-z_-]+)\\s*\\([^)]*\\)\\s*(.*)", line))
    }

    # Pattern 3: Field Value (no separator)
    if (length(matches[[1]]) < 3) {
      matches <- regmatches(line, regexec("([A-Za-z_-]+)\\s+(.*)", line))
    }

    if (length(matches[[1]]) >= 3) {
      field_name <- tolower(matches[[1]][2])
      field_value <- trimws(matches[[1]][3])

      fields[[field_name]] <- field_value
    }
  }

  list(
    range = header_range,
    fields = fields,
    content = content
  )
}


#' Update a header field
#'
#' @param header List. Header information from extract_header.
#' @param field Character. Field name to update.
#' @param update Function or character. Update to apply.
#'
#' @return Updated header list.
#' @keywords internal
update_header_field <- function(header, field, update) {
  # Get current value
  current <- header$fields[[field]]

  # Apply update
  if (is.function(update)) {
    new_value <- update(current)
  } else {
    new_value <- update
  }

  # Update field
  header$fields[[field]] <- new_value

  header
}

#' Update file header
#'
#' @param file Character. Path to file.
#' @param header List. Header information from extract_header.
#'
#' @return TRUE invisibly on success.
#' @keywords internal
update_file_header <- function(file, header) {
  file_info <- header_file_info(file)
  content <- header$content

  # Check if file is read-only
  if (file_info$read_only) {
    cli::cli_abort("File is read-only: {file}")
  }

  # Update header lines
  for (field in names(header$fields)) {
    # Match field name with various patterns
    patterns <- c(
      # Field: Value
      paste0("(", field, "\\s*[:-]\\s*).*"),
      # Field (c) Value
      paste0("(", field, "\\s*\\([^)]*\\)\\s*).*"),
      # Field Value
      paste0("(", field, "\\s+).*")
    )

    for (i in header$range[1]:header$range[2]) {
      for (pattern in patterns) {
        if (grepl(pattern, content[i], ignore.case = TRUE)) {
          replacement <- paste0("\\1", header$fields[[field]])
          content[i] <- sub(pattern, replacement, content[i], ignore.case = TRUE)
          break  # Stop after first successful replacement
        }
      }
    }
  }

  # Write back with original encoding and line endings
  # Ensure there's a newline at the end of the file
  if (!endsWith(content[length(content)], "\n")) {
    content[length(content)] <- paste0(content[length(content)], "\n")
  }

  # Write to file
  con <- file(file, "wb")
  on.exit(close(con))

  # Use writeBin to ensure proper line endings
  text <- paste(content, collapse = file_info$line_ending)
  writeBin(charToRaw(text), con)

  invisible(TRUE)
}

#' Preview header update
#'
#' @param file Character. Path to file.
#' @param header List. Header information from extract_header.
#'
#' @return stamp_update_preview object.
#' @keywords internal
preview_update <- function(file, header) {
  file_info <- header_file_info(file)

  structure(
    list(
      file = file,
      fields = header$fields,
      range = header$range,
      encoding = file_info$encoding,
      line_ending = file_info$line_ending,
      read_only = file_info$read_only
    ),
    class = "stamp_update_preview"
  )
}

#' Helper for extending copyright years
#'
#' @param initial_year Character or NULL. Initial year to use if no year is found.
#'
#' @return Function to update copyright field.
#' @export
stamp_update_helper_copyright_extend <- function(initial_year = NULL) {
  function(current) {
    years <- extract_years(current)
    if (length(years) == 0 && is.null(initial_year)) {
      return(format(Sys.Date(), "%Y"))
    } else if (length(years) == 0) {
      return(paste0(initial_year, "-", format(Sys.Date(), "%Y")))
    }
    paste0(min(years), "-", format(Sys.Date(), "%Y"))
  }
}

#' Helper for adding authors
#'
#' @param new_author Character. New author to add.
#'
#' @return Function to update author field.
#' @export
stamp_update_helper_author_add <- function(new_author) {
  function(current) {
    if (is.null(current) || current == "") {
      return(new_author)
    }

    authors <- unlist(strsplit(current, ",\\s*|\\s+and\\s+"))

    if (new_author %in% authors) {
      return(current)  # Author already exists
    }

    if (length(authors) == 1) {
      return(paste(current, "and", new_author))
    } else {
      authors <- c(authors, new_author)
      last <- authors[length(authors)]
      rest <- authors[-length(authors)]
      return(paste0(paste(rest, collapse = ", "), ", and ", last))
    }
  }
}

#' Extract years from a string
#'
#' @param text Character. Text to extract years from.
#'
#' @return Numeric vector of years.
#' @keywords internal
extract_years <- function(text) {
  # Extract 4-digit numbers
  matches <- regmatches(text, gregexpr("\\b\\d{4}\\b", text))
  as.numeric(unlist(matches))
}
