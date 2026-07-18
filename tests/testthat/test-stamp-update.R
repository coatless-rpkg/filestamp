# Helper to create a file with a header
create_file_with_header <- function(path, header) {
  header_lines <- strsplit(header, "\n")[[1]]
  content <- c(header_lines, "", "# Code starts here", "x <- 1 + 2")

  # Ensure the file has a proper newline at the end to avoid warnings
  writeLines(content, path, sep = "\n")
}

# Test stamp_update() ----

test_that("stamp_update(): updates header fields", {
  # Setup: Create a temporary file with a header
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "update_test.R")
  header <- "# Copyright (c) Test Company 2020\n# Author: Original Author\n# License: All rights reserved.\n"
  create_file_with_header(test_file, header)

  # Execute: Update copyright year
  updates <- list(
    copyright = function(current) sub("2020", "2025", current)
  )

  result <- do.call(stamp_update, c(list(test_file), updates))

  # Verify: Check that copyright was updated
  content <- readLines(test_file)
  copyright_line <- grep("Copyright", content, value = TRUE)
  expect_match(copyright_line, "2025", fixed = TRUE)

  # Cleanup
  file.remove(test_file)
})

test_that("stamp_update(): handles files without headers", {
  # Setup: Create a temporary file without a header
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "no_header.R")
  writeLines("# Just a regular script\nx <- 1 + 2\n", test_file)

  # Execute & Verify: Expect warning
  expect_warning(
    stamp_update(test_file, copyright = "New Copyright")
  )

  # Cleanup
  file.remove(test_file)
})

test_that("stamp_update(): creates backups when requested", {
  # Setup: Create a temporary file with a header
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "backup_test.R")
  header <- "# Copyright (c) Test Company 2020\n# Author: Original Author\n"
  create_file_with_header(test_file, header)

  # Execute: Update with backup
  updates <- list(
    copyright = "Test Company 2025"
  )

  result <- do.call(stamp_update, c(list(test_file), updates, list(action = "backup")))

  # Verify: Check that backup file exists with original content
  backup_file <- paste0(test_file, ".bck")
  expect_true(file.exists(backup_file))

  backup_content <- readLines(backup_file)
  expect_match(backup_content[1], "2020", fixed = TRUE)

  # Verify: Check that original file was updated
  content <- readLines(test_file)
  expect_match(content[1], "2025", fixed = TRUE)

  # Cleanup
  file.remove(test_file, backup_file)
})

test_that("stamp_update(): performs dry run without modifying", {
  # Setup: Create a temporary file with a header
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "dryrun_test.R")
  header <- "# Copyright (c) Test Company 2020\n# Author: Original Author"
  create_file_with_header(test_file, header)

  # Execute: Update with dryrun
  updates <- list(
    copyright = "Test Company 2025"
  )

  result <- do.call(stamp_update, c(list(test_file), updates, list(action = "dryrun")))

  # Verify: Check that file wasn't modified
  content <- readLines(test_file)
  expect_match(content[1], "2020", fixed = TRUE)

  # Verify: Check result object
  expect_s3_class(result, "stamp_update_preview")
  expect_equal(result$fields$copyright, "Test Company 2025")

  # Cleanup
  file.remove(test_file)
})

# Test extract_header() ----

test_that("extract_header(): extracts header fields correctly", {
  # Setup: Create a temporary file with a header
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "extract_test.R")
  header <- "# Copyright (c) Test Company 2025\n# Author: Test Author\n# License: MIT"
  create_file_with_header(test_file, header)

  # Execute: Extract header
  header_info <- extract_header(test_file)

  # Verify: Check header fields
  expect_equal(header_info$fields$copyright, "Test Company 2025")
  expect_equal(header_info$fields$author, "Test Author")
  expect_equal(header_info$fields$license, "MIT")

  # Verify: Check header range
  expect_equal(header_info$range, c(1, 3))

  # Cleanup
  file.remove(test_file)
})

test_that("extract_header(): returns NULL for files without headers", {
  # Setup: Create a temporary file without a header
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "no_header_extract.R")
  writeLines("# Just a regular script\nx <- 1 + 2", test_file)

  # Execute: Extract header
  header_info <- extract_header(test_file)

  # Verify: Check result is NULL
  expect_null(header_info)

  # Cleanup
  file.remove(test_file)
})

test_that("extract_header(): selects the file header, not roxygen doc blocks", {
  # Setup: A short header followed by a longer roxygen block that
  # mentions authors/licenses on several consecutive lines
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "extract_roxygen.R")
  writeLines(c(
    "# Copyright (c) 2020",
    "# Author: James J Balamuta",
    "",
    "#' Helper for adding authors",
    "#'",
    "#' @param new_author Character. New author to add.",
    "#' @return Function to update author field.",
    "#' @author Someone Else",
    "#' The license section mentions authors too",
    "author_add <- function(new_author) new_author"
  ), test_file)

  # Execute
  header_info <- extract_header(test_file)

  # Verify: The real header was chosen, not the roxygen block
  expect_equal(header_info$range, c(1, 2))
  expect_equal(header_info$fields$copyright, "2020")
  expect_equal(header_info$fields$author, "James J Balamuta")

  # Cleanup
  file.remove(test_file)
})

test_that("extract_header(): ignores license mentions in header prose", {
  # Setup: An AGPL-style header whose body text mentions the license name
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "extract_agpl.R")
  writeLines(c(
    "# Copyright (c) 2025",
    "# Author: James J Balamuta",
    "# License: GNU Affero General Public License v3.0 or later",
    "#",
    "# This program is free software: you can redistribute it and/or modify",
    "# it under the terms of the GNU Affero General Public License as published",
    "# by the Free Software Foundation, either version 3 of the License, or",
    "# (at your option) any later version.",
    "",
    "x <- 1"
  ), test_file)

  # Execute
  header_info <- extract_header(test_file)

  # Verify: Only the field lines form the header range
  expect_equal(header_info$range, c(1, 3))
  expect_equal(header_info$fields$copyright, "2025")
  expect_equal(header_info$fields$author, "James J Balamuta")
  expect_equal(header_info$fields$license,
               "GNU Affero General Public License v3.0 or later")

  # Cleanup
  file.remove(test_file)
})

test_that("extract_header(): returns NULL for roxygen-only files", {
  # Setup: A file whose only "header-like" text is roxygen documentation
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "extract_roxygen_only.R")
  writeLines(c(
    "#' Compute a value",
    "#'",
    "#' @author Jane Doe",
    "#' @export",
    "f <- function() NULL"
  ), test_file)

  # Execute & Verify
  expect_null(extract_header(test_file))

  # Cleanup
  file.remove(test_file)
})

test_that("extract_header(): includes adjacent template fields like Last updated", {
  # Setup: A default-template-style header with a Last updated field
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "extract_updated.R")
  writeLines(c(
    "# Copyright (c) 2025",
    "# Author: Jane Doe",
    "# License: All rights reserved.",
    "# Last updated: 2025-01-01 00:00:00",
    "",
    "x <- 1"
  ), test_file)

  # Execute
  header_info <- extract_header(test_file)

  # Verify: The Last updated line is part of the header
  expect_equal(header_info$range, c(1, 4))
  expect_equal(header_info$fields$last_updated, "2025-01-01 00:00:00")

  # Execute: Updating the field must change the file
  stamp_update(test_file, last_updated = "2026-12-31 23:59:59")

  # Verify
  content <- readLines(test_file)
  expect_equal(content[4], "# Last updated: 2026-12-31 23:59:59")

  # Cleanup
  file.remove(test_file)
})

test_that("extract_header(): prefers the topmost header block", {
  # Setup: A real header at the top plus a larger header-shaped block below
  # (e.g. an example in documentation)
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "extract_topmost.md")
  writeLines(c(
    "<!--",
    "Copyright (c) 2020",
    "Author: Jane",
    "-->",
    "",
    "Example header:",
    "",
    "<!--",
    "Copyright (c) 1999",
    "Author: Old Example",
    "License: Example",
    "All rights reserved.",
    "-->"
  ), test_file)

  # Execute
  header_info <- extract_header(test_file)

  # Verify: The topmost block wins even though the example block is larger
  expect_equal(header_info$range, c(2, 3))
  expect_equal(header_info$fields$author, "Jane")

  # Cleanup
  file.remove(test_file)
})

test_that("extract_header(): skips YAML front matter metadata", {
  # Setup: An Rmd with author metadata and a real header after the fence
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "extract_rmd.Rmd")
  writeLines(c(
    "---",
    "title: \"My Document\"",
    "author: \"Metadata Author\"",
    "---",
    "<!--",
    "Copyright (c) 2025",
    "Author: Header Author",
    "-->",
    "",
    "# Introduction"
  ), test_file)

  # Execute
  header_info <- extract_header(test_file)

  # Verify: The header, not the YAML metadata, was extracted
  expect_equal(header_info$range, c(6, 7))
  expect_equal(header_info$fields$author, "Header Author")

  # Cleanup
  file.remove(test_file)
})

test_that("stamp_update(): tolerates regex metacharacters in field names", {
  # Setup: A stamped file
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "update_meta.R")
  lines <- c("# Copyright (c) 2020", "# Author: Jane", "", "x <- 1")
  writeLines(lines, test_file)

  # Execute & Verify: A field name like "c++" must not abort; it warns
  # because no such field exists in the header
  expect_warning(stamp_update(test_file, "c++" = "value"))

  # Verify: File content unchanged (no such field in the header)
  expect_equal(readLines(test_file), lines)

  # Cleanup
  file.remove(test_file)
})

test_that("stamp_update(): writes backslash values literally", {
  # Setup: A stamped file
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "update_backslash.R")
  writeLines(c("# Copyright (c) 2020", "# Author: Old", "", "x <- 1"), test_file)

  # Execute: Values with backslashes and backreference-like text
  stamp_update(test_file, author = "C:\\Users\\jane \\1")

  # Verify: Written literally, not interpreted by the regex engine
  content <- readLines(test_file)
  expect_equal(content[2], "# Author: C:\\Users\\jane \\1")

  # Cleanup
  file.remove(test_file)
})

test_that("stamp_update(): preserves CRLF line endings and final newline", {
  # Setup: A stamped file with CRLF line endings
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "update_crlf.R")
  con <- file(test_file, "wb")
  writeBin(charToRaw("# Copyright (c) 2020\r\n# Author: Old\r\n\r\nx <- 1\r\n"), con)
  close(con)

  # Execute
  stamp_update(test_file, author = "New Author")

  # Verify: All newlines CRLF, file ends with a newline
  raw_text <- rawToChar(readBin(test_file, "raw", n = file.info(test_file)$size))
  expect_false(grepl("(?<!\r)\n", raw_text, perl = TRUE))
  expect_match(raw_text, "# Author: New Author\r\n", fixed = TRUE)
  expect_match(raw_text, "\r\n$")

  # Cleanup
  file.remove(test_file)
})

test_that("stamp_update(): updates the header without touching roxygen docs", {
  # Setup: A stamped file with roxygen docs that mention authors
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "update_roxygen.R")
  roxygen_lines <- c(
    "#' Helper for adding authors",
    "#'",
    "#' @param new_author Character. New author to add.",
    "#' @return Function to update author field.",
    "#' @author Someone Else",
    "#' The license section mentions authors too",
    "author_add <- function(new_author) new_author"
  )
  writeLines(c(
    "# Copyright (c) 2020",
    "# Author: James J Balamuta",
    "",
    roxygen_lines
  ), test_file)

  # Execute: Extend the copyright range
  stamp_update(test_file, copyright = "2020-2025")

  # Verify: Header updated, roxygen block byte-for-byte identical
  content <- readLines(test_file)
  expect_equal(content[1], "# Copyright (c) 2020-2025")
  expect_equal(content[2], "# Author: James J Balamuta")
  expect_equal(tail(content, length(roxygen_lines)), roxygen_lines)

  # Cleanup
  file.remove(test_file)
})

test_that("stamp_update(): warns instead of silently succeeding on an absent field", {
  # Setup: A header with only copyright + author
  test_file <- withr::local_tempfile(fileext = ".R")
  writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "x <- 1"), test_file)
  before <- readLines(test_file)

  # Execute & Verify: updating a field that isn't present warns, not silent success
  expect_warning(stamp_update(test_file, license = "MIT"), "license")

  # Verify: file left unchanged (nothing was silently written)
  expect_equal(readLines(test_file), before)
})

test_that("stamp_update(): warns when a gpl-3 program-author line cannot be located", {
  # Setup: A file stamped with gpl-3, whose author lives on the label-less
  # "program - author" line
  test_file <- withr::local_tempfile(fileext = ".R")
  writeLines("x <- 1", test_file)
  suppressWarnings(
    stamp_file(test_file, template = "gpl-3", copyright = "ACME 2025", author = "Jane")
  )
  before <- readLines(test_file)

  # Execute & Verify: author cannot be located by field label -> warn, no silent success
  expect_warning(
    stamp_update(test_file, author = author_add("Bob")),
    "author"
  )
  expect_equal(readLines(test_file), before)
})

# Test update_header_field() ----

test_that("update_header_field(): updates with string value", {
  # Setup: Create a header
  header <- list(
    fields = list(
      copyright = "Old Copyright",
      author = "Old Author"
    ),
    range = c(1, 2)
  )

  # Execute: Update with string
  updated <- update_header_field(header, "copyright", "New Copyright")

  # Verify: Check updated field
  expect_equal(updated$fields$copyright, "New Copyright")
  expect_equal(updated$fields$author, "Old Author")  # Unchanged
})

test_that("update_header_field(): updates with function", {
  # Setup: Create a header
  header <- list(
    fields = list(
      copyright = "Old Copyright",
      author = "Old Author"
    ),
    range = c(1, 2)
  )

  # Execute: Update with function
  updater <- function(current) paste("Updated", current)
  updated <- update_header_field(header, "author", updater)

  # Verify: Check updated field
  expect_equal(updated$fields$author, "Updated Old Author")
  expect_equal(updated$fields$copyright, "Old Copyright")  # Unchanged
})

# Test update_file_header() ----

test_that("update_file_header(): updates file content correctly", {
  # Setup: Create a temporary file with a header
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "update_content.R")
  header <- "# Copyright: Old Copyright\n# Author: Old Author\n\nx <- 1 + 2\n"
  writeLines(header, test_file)

  # Setup: Create updated header info
  header_info <- list(
    fields = list(
      copyright = "New Copyright",
      author = "New Author"
    ),
    range = c(1, 2),
    content = strsplit(header, "\n")[[1]]
  )

  # Execute: Update file header
  result <- update_file_header(test_file, header_info)

  # Verify: Check file content
  content <- readLines(test_file)
  expect_equal(content[1], "# Copyright: New Copyright")
  expect_equal(content[2], "# Author: New Author")
  expect_equal(content[4], "x <- 1 + 2")  # Unchanged

  # Cleanup
  file.remove(test_file)
})

# Test year_extend() ----

test_that("year_extend(): extends single year, keeping owner", {
  # Setup: Create helper
  helper <- year_extend()

  # Execute and verify with single year (owner name must be preserved)
  current_year <- format(Sys.Date(), "%Y")
  result <- helper("Test Company 2020")
  expect_equal(result, paste0("Test Company 2020-", current_year))
})

test_that("year_extend(): handles existing year range, keeping owner", {
  # Setup: Create helper
  helper <- year_extend()

  # Execute and verify with year range
  current_year <- format(Sys.Date(), "%Y")
  result <- helper("Test Company 2018-2022")
  expect_equal(result, paste0("Test Company 2018-", current_year))
})

test_that("year_extend(): handles missing years, keeping owner", {
  # Setup: Create helper
  helper <- year_extend()

  # Execute and verify with no years
  current_year <- format(Sys.Date(), "%Y")
  result <- helper("Test Company")
  expect_equal(result, paste("Test Company", current_year))

  # Execute and verify with initial year
  initial_helper <- year_extend("2015")
  result <- initial_helper("Test Company")
  expect_equal(result, paste0("Test Company 2015-", current_year))
})

test_that("year_extend(): does not emit a degenerate same-year range", {
  # Setup: A freshly stamped header whose only year is the current year
  helper <- year_extend()
  current_year <- format(Sys.Date(), "%Y")

  # Execute: extending "Owner <thisyear>" must not become "<thisyear>-<thisyear>"
  result <- helper(paste("Your Company", current_year))
  expect_equal(result, paste("Your Company", current_year))
})

test_that("year_extend(): works end-to-end on a stamped header", {
  # Setup: A file stamped with the default template (copyright = "Owner <year>")
  test_file <- withr::local_tempfile(fileext = ".R")
  writeLines(c("# Copyright (c) ACME Inc. 2020", "# Author: Jane", "", "x <- 1"),
             test_file)

  # Execute: the headline yearly-maintenance call
  stamp_update(test_file, copyright = year_extend())

  # Verify: owner kept, year extended
  current_year <- format(Sys.Date(), "%Y")
  content <- readLines(test_file)
  expect_equal(content[1], paste0("# Copyright (c) ACME Inc. 2020-", current_year))
})

# Test author_add() ----

test_that("author_add(): adds to single author", {
  # Setup: Create helper
  helper <- author_add("New Author")

  # Execute and verify
  result <- helper("Original Author")
  expect_equal(result, "Original Author and New Author")
})

test_that("author_add(): adds to multiple authors", {
  # Setup: Create helper
  helper <- author_add("New Author")

  # Execute and verify
  result <- helper("Author 1, Author 2")
  expect_equal(result, "Author 1, Author 2, and New Author")
})

test_that("author_add(): handles empty author field", {
  # Setup: Create helper
  helper <- author_add("New Author")

  # Execute and verify
  result <- helper(NULL)
  expect_equal(result, "New Author")

  result <- helper("")
  expect_equal(result, "New Author")
})

test_that("author_add(): doesn't duplicate authors", {
  # Setup: Create helper
  helper <- author_add("Existing Author")

  # Execute and verify
  result <- helper("Existing Author")
  expect_equal(result, "Existing Author")

  result <- helper("Author 1 and Existing Author")
  expect_equal(result, "Author 1 and Existing Author")
})

test_that("author_add(): round-trips its own Oxford-comma output", {
  # Setup: A 3-author list in the exact format the helper itself produces
  existing <- "Ann, Bob, and Cara"

  # Execute: adding a 4th author must not double the "and" or mangle the list
  expect_equal(author_add("Dan")(existing),
               "Ann, Bob, Cara, and Dan")

  # Execute: re-adding an existing author from a 3+ list must be idempotent
  expect_equal(author_add("Cara")(existing), existing)
})

# Test extract_years() ----

test_that("extract_years(): extracts years correctly", {
  # Execute and verify various cases
  expect_equal(extract_years("Copyright 2020"), 2020)
  expect_equal(extract_years("Copyright 2018-2022"), c(2018, 2022))
  expect_equal(extract_years("Copyright (c) 2015, 2018, 2020"), c(2015, 2018, 2020))
  expect_equal(extract_years("No years here"), numeric(0))
  expect_equal(extract_years("Year 20 and 202 are not 4 digits"), numeric(0))
})

# New update API: verbs + composable named updates ----

test_that("stamp_bump_year(): extends the copyright year in place", {
  f <- withr::local_tempfile(fileext = ".R")
  writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "x <- 1"), f)
  stamp_bump_year(f)
  yr <- format(Sys.Date(), "%Y")
  expect_equal(readLines(f)[1], paste0("# Copyright (c) 2020-", yr))
})

test_that("stamp_add_author(): appends an author in place", {
  f <- withr::local_tempfile(fileext = ".R")
  writeLines(c("# Copyright (c) 2020", "# Author: Jane Doe", "", "x <- 1"), f)
  stamp_add_author(f, "Sam Smith")
  expect_equal(readLines(f)[2], "# Author: Jane Doe and Sam Smith")
})

test_that("stamp_update(): accepts named updates without list()", {
  f <- withr::local_tempfile(fileext = ".R")
  writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "x <- 1"), f)
  stamp_update(f, copyright = year_extend(), author = author_add("Sam"))
  yr <- format(Sys.Date(), "%Y")
  content <- readLines(f)
  expect_equal(content[1], paste0("# Copyright (c) 2020-", yr))
  expect_equal(content[2], "# Author: Jane and Sam")
})

test_that("year_extend(): keeps owner and extends to current year", {
  yr <- format(Sys.Date(), "%Y")
  expect_equal(year_extend()("ACME Inc. 2020"), paste0("ACME Inc. 2020-", yr))
  expect_equal(year_extend("2015")("ACME Inc."), paste0("ACME Inc. 2015-", yr))
})

test_that("author_add(): appends without duplicating", {
  expect_equal(author_add("Sam")("Jane"), "Jane and Sam")
  expect_equal(author_add("Jane")("Jane"), "Jane")
})

test_that("stamp_bump_year()/stamp_add_author(): honor dryrun and backup", {
  f <- withr::local_tempfile(fileext = ".R")
  writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "x <- 1"), f)
  before <- readLines(f)

  preview <- stamp_bump_year(f, action = "dryrun")
  expect_s3_class(preview, "stamp_update_preview")
  expect_equal(readLines(f), before)

  stamp_add_author(f, "Sam", action = "backup")
  expect_true(file.exists(paste0(f, ".bck")))
})

test_that("the old stamp_update_helper_*() names are gone", {
  expect_false(exists("stamp_update_helper_copyright_extend"))
  expect_false(exists("stamp_update_helper_author_add"))
})

# stamp_edits() bundle + directory-aware updates ----

test_that("stamp_edits(): bundles named updates and applies to a file", {
  e <- stamp_edits(copyright = year_extend(), author = author_add("Sam"))
  expect_s3_class(e, "stamp_edits")
  expect_named(e, c("copyright", "author"))

  f <- withr::local_tempfile(fileext = ".R")
  writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "x <- 1"), f)
  stamp_update(f, e)
  yr <- format(Sys.Date(), "%Y")
  content <- readLines(f)
  expect_equal(content[1], paste0("# Copyright (c) 2020-", yr))
  expect_equal(content[2], "# Author: Jane and Sam")
})

test_that("stamp_edits(): requires every edit to be named", {
  expect_error(stamp_edits(year_extend()), "name")
})

test_that("stamp_edits(): prints the fields it changes", {
  e <- stamp_edits(copyright = year_extend(), license = "MIT")
  out <- cli::ansi_strip(paste(cli::cli_fmt(print(e)), collapse = "\n"))
  expect_match(out, "copyright")
  expect_match(out, "license")
})

test_that("stamp_update(): updates every stamped file in a directory", {
  d <- withr::local_tempdir()
  dir.create(file.path(d, "sub"))
  writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "a <- 1"), file.path(d, "a.R"))
  writeLines(c("# Copyright (c) 2019", "# Author: Ada", "", "b <- 2"), file.path(d, "sub", "b.R"))
  writeLines("c <- 3", file.path(d, "c.R"))          # no header -> left alone

  res <- suppressMessages(stamp_update(d, copyright = year_extend(), recursive = TRUE))
  expect_s3_class(res, "stamp_dir_results")

  yr <- format(Sys.Date(), "%Y")
  expect_equal(readLines(file.path(d, "a.R"))[1], paste0("# Copyright (c) 2020-", yr))
  expect_equal(readLines(file.path(d, "sub", "b.R"))[1], paste0("# Copyright (c) 2019-", yr))
  expect_equal(readLines(file.path(d, "c.R")), "c <- 3")
})

test_that("stamp_bump_year()/stamp_add_author(): work on a directory", {
  d <- withr::local_tempdir()
  writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "a <- 1"), file.path(d, "a.R"))
  suppressMessages(stamp_bump_year(d))
  suppressMessages(stamp_add_author(d, "Sam"))
  yr <- format(Sys.Date(), "%Y")
  content <- readLines(file.path(d, "a.R"))
  expect_equal(content[1], paste0("# Copyright (c) 2020-", yr))
  expect_equal(content[2], "# Author: Jane and Sam")
})

test_that("stamp_update(): a stamp_edits bundle updates a directory in one call", {
  d <- withr::local_tempdir()
  writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "a <- 1"), file.path(d, "a.R"))
  writeLines(c("# Copyright (c) 2018", "# Author: Ada", "", "b <- 2"), file.path(d, "b.R"))

  e <- stamp_edits(copyright = year_extend(), author = author_add("Sam"))
  res <- suppressMessages(stamp_update(d, e))
  expect_equal(sum(vapply(res$results, function(r) r$status == "success", logical(1))), 2)
  expect_equal(readLines(file.path(d, "a.R"))[2], "# Author: Jane and Sam")
})

test_that("directory update results print as 'Updating', stamping as 'Stamping'", {
  d <- withr::local_tempdir()
  writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "a <- 1"), file.path(d, "a.R"))
  res <- suppressMessages(stamp_update(d, copyright = year_extend()))
  out <- cli::ansi_strip(paste(cli::cli_fmt(print(res)), collapse = "\n"))
  expect_match(out, "Directory Updating Results")
})

# Edge cases: bundles, mixing, and directory action variants ----

test_that("collect_edits: a bundle and inline args merge in one call", {
  f <- withr::local_tempfile(fileext = ".R")
  writeLines(c("# Copyright (c) 2020", "# Author: Jane", "# License: GPL-2", "", "x <- 1"), f)
  e <- stamp_edits(copyright = year_extend())
  stamp_update(f, e, license = "MIT")            # bundle + inline value
  content <- readLines(f)
  yr <- format(Sys.Date(), "%Y")
  expect_equal(content[1], paste0("# Copyright (c) 2020-", yr))
  expect_equal(content[3], "# License: MIT")
})

test_that("stamp_edits(): empty bundle is allowed and prints 'No edits'", {
  e <- stamp_edits()
  expect_s3_class(e, "stamp_edits")
  expect_length(e, 0)
  out <- cli::ansi_strip(paste(cli::cli_fmt(print(e)), collapse = "\n"))
  expect_match(out, "No edits")
})

test_that("print.stamp_edits(): describes a bare updater function", {
  e <- stamp_edits(author = function(x) x)       # a function with no desc attr
  out <- cli::ansi_strip(paste(cli::cli_fmt(print(e)), collapse = "\n"))
  expect_match(out, "a function of the current value")
})

test_that("stamp_update(): directory backup makes a .bck per updated file", {
  d <- withr::local_tempdir()
  writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "a <- 1"), file.path(d, "a.R"))
  suppressMessages(stamp_update(d, copyright = year_extend(), action = "backup"))
  expect_true(file.exists(file.path(d, "a.R.bck")))
})

test_that("stamp_update(): directory dryrun changes nothing", {
  d <- withr::local_tempdir()
  writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "a <- 1"), file.path(d, "a.R"))
  before <- readLines(file.path(d, "a.R"))
  res <- suppressMessages(stamp_update(d, copyright = year_extend(), action = "dryrun"))
  expect_s3_class(res, "stamp_dir_results")
  expect_equal(readLines(file.path(d, "a.R")), before)
})

test_that("stamp_update(): directory pattern limits which files are updated", {
  d <- withr::local_tempdir()
  writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "a <- 1"), file.path(d, "a.R"))
  writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "b = 2"), file.path(d, "b.py"))
  suppressMessages(stamp_update(d, copyright = year_extend(), pattern = "\\.R$"))
  yr <- format(Sys.Date(), "%Y")
  expect_equal(readLines(file.path(d, "a.R"))[1], paste0("# Copyright (c) 2020-", yr))
  expect_equal(readLines(file.path(d, "b.py"))[1], "# Copyright (c) 2020")  # untouched
})

test_that("stamp_update(): a read-only file in a directory is reported as an error", {
  d <- withr::local_tempdir()
  ro <- file.path(d, "a.R")
  writeLines(c("# Copyright (c) 2020", "# Author: Jane", "", "a <- 1"), ro)
  Sys.chmod(ro, "0444")
  res <- suppressMessages(stamp_update(d, copyright = year_extend()))
  statuses <- vapply(res$results, function(r) r$status, character(1))
  expect_true("error" %in% statuses)
  Sys.chmod(ro, "0644")
})

test_that("stamp_update(): a directory with no stamped files returns empty results", {
  d <- withr::local_tempdir()
  writeLines("x <- 1", file.path(d, "plain.R"))   # no header
  res <- suppressMessages(stamp_update(d, copyright = year_extend()))
  expect_s3_class(res, "stamp_dir_results")
  expect_length(res$results, 0)
  expect_no_error(suppressMessages(print(res)))
})
