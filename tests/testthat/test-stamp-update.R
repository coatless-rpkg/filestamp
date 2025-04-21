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

  result <- stamp_update(test_file, updates)

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
    stamp_update(test_file, list(copyright = "New Copyright"))
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

  result <- stamp_update(test_file, updates, action = "backup")

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

  result <- stamp_update(test_file, updates, action = "dryrun")

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

# Test stamp_update_helper_copyright_extend() ----

test_that("stamp_update_helper_copyright_extend(): extends single year", {
  # Setup: Create helper
  helper <- stamp_update_helper_copyright_extend()

  # Execute and verify with single year
  current_year <- format(Sys.Date(), "%Y")
  result <- helper("Test Company 2020")
  expect_equal(result, paste0("2020-", current_year))
})

test_that("stamp_update_helper_copyright_extend(): handles existing year range", {
  # Setup: Create helper
  helper <- stamp_update_helper_copyright_extend()

  # Execute and verify with year range
  current_year <- format(Sys.Date(), "%Y")
  result <- helper("Test Company 2018-2022")
  expect_equal(result, paste0("2018-", current_year))
})

test_that("stamp_update_helper_copyright_extend(): handles missing years", {
  # Setup: Create helper
  helper <- stamp_update_helper_copyright_extend()

  # Execute and verify with no years
  current_year <- format(Sys.Date(), "%Y")
  result <- helper("Test Company")
  expect_equal(result, current_year)

  # Execute and verify with initial year
  initial_helper <- stamp_update_helper_copyright_extend("2015")
  result <- initial_helper("Test Company")
  expect_equal(result, paste0("2015-", current_year))
})

# Test stamp_update_helper_author_add() ----

test_that("stamp_update_helper_author_add(): adds to single author", {
  # Setup: Create helper
  helper <- stamp_update_helper_author_add("New Author")

  # Execute and verify
  result <- helper("Original Author")
  expect_equal(result, "Original Author and New Author")
})

test_that("stamp_update_helper_author_add(): adds to multiple authors", {
  # Setup: Create helper
  helper <- stamp_update_helper_author_add("New Author")

  # Execute and verify
  result <- helper("Author 1, Author 2")
  expect_equal(result, "Author 1, Author 2, and New Author")
})

test_that("stamp_update_helper_author_add(): handles empty author field", {
  # Setup: Create helper
  helper <- stamp_update_helper_author_add("New Author")

  # Execute and verify
  result <- helper(NULL)
  expect_equal(result, "New Author")

  result <- helper("")
  expect_equal(result, "New Author")
})

test_that("stamp_update_helper_author_add(): doesn't duplicate authors", {
  # Setup: Create helper
  helper <- stamp_update_helper_author_add("Existing Author")

  # Execute and verify
  result <- helper("Existing Author")
  expect_equal(result, "Existing Author")

  result <- helper("Author 1 and Existing Author")
  expect_equal(result, "Author 1 and Existing Author")
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
