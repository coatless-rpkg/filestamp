# Test stamp_file() ----

test_that("stamp_file(): correctly stamps a file with default template", {
  # Setup: Create a temporary file
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "test_script.R")
  writeLines("# A simple R script\n\nx <- 1 + 2\n", test_file)

  # Execute: Stamp the file
  result <- stamp_file(test_file)

  # Verify: Check that the file now has a header
  content <- readLines(test_file)
  expect_true(has_header(test_file))
  expect_match(content[1], "Copyright", ignore.case = TRUE)
  expect_match(content[grep("Author", content)], "Author", ignore.case = TRUE)

  # Cleanup
  file.remove(test_file)
})

test_that("stamp_file(): uses the specified template", {
  # Setup: Create a temporary file and custom template
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "test_custom.R")
  writeLines("# A simple R script\n\nx <- 1 + 2\n", test_file)

  custom_template <- stamp_template_create(
    name = "test_custom",
    fields = stamp_template_describe(
      project = stamp_template_field("project", "Test Project", required = TRUE)
    ),
    content = stamp_template_content("Project: {{project}}")
  )

  # Execute: Stamp the file with custom template
  result <- stamp_file(test_file, template = custom_template)

  # Verify: Check that the file has the custom header
  content <- readLines(test_file)
  expect_match(content[1], "# Project: Test Project")

  # Cleanup
  file.remove(test_file)
})

test_that("stamp_file(): creates a backup when requested", {
  # Setup: Create a temporary file
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "test_backup.R")
  original_content <- "# Original content\n\nx <- 1 + 2\n"

  # Write content without adding a trailing newline
  con <- file(test_file, "wb")
  cat(original_content, file = con)
  close(con)

  # Execute: Stamp the file with backup action
  result <- stamp_file(test_file, action = "backup")

  # Verify: Check that a backup file exists with the original content
  backup_file <- paste0(test_file, ".bck")
  expect_true(file.exists(backup_file))

  # Read backup content and compare with original
  backup_content <- readChar(backup_file, file.info(backup_file)$size)
  expect_equal(backup_content, original_content)

  # Cleanup
  file.remove(test_file, backup_file)
})


test_that("stamp_file(): performs dry run without modifying file", {
  # Setup: Create a temporary file
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "test_dryrun.R")
  original_content <- "# Original content\n\nx <- 1 + 2\n"

  # Write content without adding a trailing newline
  con <- file(test_file, "wb")
  cat(original_content, file = con)
  close(con)

  # Execute: Stamp the file with dryrun action
  result <- stamp_file(test_file, action = "dryrun")

  # Verify: Check that the file wasn't modified
  file_content <- readChar(test_file, file.info(test_file)$size)
  expect_equal(file_content, original_content)

  # Check result object
  expect_s3_class(result, "stamp_preview")
  expect_match(result$header, "Copyright", ignore.case = TRUE)

  # Cleanup
  file.remove(test_file)
})

test_that("stamp_file(): handles non-existent files", {
  # Setup: Define a non-existent file
  non_existent_file <- tempfile(fileext = ".R")

  # Execute & Verify: Expect error for non-existent file
  expect_error(stamp_file(non_existent_file), "does not exist")
})

test_that("stamp_file(): doesn't re-stamp a file with a header", {
  # Setup: Create a temporary file with a header
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "test_existing.R")
  header_content <- "# Copyright (c) Test Company 2025\n# Author: Test Author\n\nx <- 1 + 2"
  writeLines(header_content, test_file)

  # Execute: Try to stamp the file again
  expect_warning(stamp_file(test_file))

  # Verify: Check that the file content is unchanged
  content <- readLines(test_file)
  expect_equal(content, strsplit(header_content, "\n")[[1]])

  # Cleanup
  file.remove(test_file)
})

# Test modify_file() ----

test_that("modify_file(): correctly inserts header at beginning", {
  # Setup: Create a temporary file
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "test_modify.R")
  original_content <- "x <- 1 + 2\ny <- x * 3\n"
  writeLines(original_content, test_file)

  # Create a simple template
  template <- stamp_template_create(
    name = "test",
    fields = stamp_template_describe(
      note = stamp_template_field("note", "Test Note", required = TRUE)
    ),
    content = stamp_template_content("Note: {{note}}")
  )

  # Detect language
  language <- detect_language(test_file)

  # Execute: Modify the file
  result <- modify_file(test_file, template, language)

  # Verify: Check that the header was inserted at the beginning
  content <- readLines(test_file)
  expect_match(content[1], "# Note: Test Note")
  expect_equal(content[2], "x <- 1 + 2")

  # Cleanup
  file.remove(test_file)
})

# Test backup_file() ----

test_that("backup_file(): creates backup with correct content", {
  # Setup: Create a temporary file
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "test_backup.txt")
  original_content <- "This is the original content"
  writeLines(original_content, test_file)

  # Execute: Create a backup
  backup_path <- backup_file(test_file)

  # Verify: Check backup exists and has the correct content
  expect_true(file.exists(backup_path))
  expect_equal(backup_path, paste0(test_file, ".bck"))

  backup_content <- readLines(backup_path)
  expect_equal(backup_content, original_content)

  # Cleanup
  file.remove(test_file, backup_path)
})

# Test preview_stamp() ----

test_that("preview_stamp(): returns correct preview object", {
  # Setup: Create a temporary file
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "test_preview.py")
  writeLines("print('Hello, world!')", test_file)

  # Create a template
  template <- stamp_template_create(
    name = "test",
    fields = stamp_template_describe(
      copyright = stamp_template_field("copyright", "Test 2025", required = TRUE)
    ),
    content = stamp_template_content("Copyright (c) {{copyright}}")
  )

  # Detect language
  language <- detect_language(test_file)

  # Execute: Create a preview
  preview <- preview_stamp(test_file, template, language)

  # Verify: Check preview object
  expect_s3_class(preview, "stamp_preview")
  expect_equal(preview$file, test_file)
  expect_match(preview$header, "Copyright \\(c\\) Test 2025")
  expect_equal(preview$insert_position, 0)  # At beginning of file
  expect_false(preview$read_only)

  # Cleanup
  file.remove(test_file)
})

# Test determine_insert_position() ----

test_that("determine_insert_position(): handles shebang correctly", {
  # Setup: Create content with shebang
  content_with_shebang <- c("#!/usr/bin/env python", "", "print('Hello')")

  # Execute & Verify
  position <- determine_insert_position(content_with_shebang)
  expect_equal(position, 1)  # After shebang line
})

test_that("determine_insert_position(): handles YAML header correctly", {
  # Setup: Create content with YAML header
  content_with_yaml <- c(
    "---",
    "title: Test Document",
    "author: Test Author",
    "---",
    "",
    "# Content starts here"
  )

  # Execute & Verify
  position <- determine_insert_position(content_with_yaml)
  expect_equal(position, 4)  # After YAML header
})

test_that("determine_insert_position(): handles regular content correctly", {
  # Setup: Create regular content
  regular_content <- c("# First line", "# Second line")

  # Execute & Verify
  position <- determine_insert_position(regular_content)
  expect_equal(position, 0)  # At beginning of file
})
