# Test is_file() ----

test_that("is_file(): returns TRUE for files", {
  # Setup: Create a temporary file
  temp_file <- tempfile()
  writeLines("Test content", temp_file)

  # Execute & Verify
  expect_true(is_file(temp_file))

  # Cleanup
  file.remove(temp_file)
})

test_that("is_file(): returns FALSE for directories", {
  # Setup: Create a temporary directory
  temp_dir <- tempfile()
  dir.create(temp_dir)

  # Execute & Verify
  expect_false(is_file(temp_dir))

  # Cleanup
  unlink(temp_dir, recursive = TRUE)
})

test_that("is_file(): returns FALSE for non-existent paths", {
  # Setup: Define a non-existent path
  non_existent <- tempfile()

  # Execute & Verify
  expect_false(is_file(non_existent))
})

# Test has_header() ----

test_that("has_header(): detects copyright header", {
  # Setup: Create a file with a copyright header
  temp_file <- tempfile()
  writeLines("# Copyright (c) 2025\n# Some content", temp_file)

  # Execute & Verify
  expect_true(has_header(temp_file))

  # Cleanup
  file.remove(temp_file)
})

test_that("has_header(): detects author header", {
  # Setup: Create a file with an author header
  temp_file <- tempfile()
  writeLines("// Author: Test Author\n// Some content", temp_file)

  # Execute & Verify
  expect_true(has_header(temp_file))

  # Cleanup
  file.remove(temp_file)
})

test_that("has_header(): detects license header", {
  # Setup: Create a file with a license header
  temp_file <- tempfile()
  writeLines("/* License: MIT */\n/* Some content */", temp_file)

  # Execute & Verify
  expect_true(has_header(temp_file))

  # Cleanup
  file.remove(temp_file)
})

test_that("has_header(): returns FALSE for files without headers", {
  # Setup: Create a file without a header
  temp_file <- tempfile()
  writeLines("# Just a regular comment\n# No header here", temp_file)

  # Execute & Verify
  expect_false(has_header(temp_file))

  # Cleanup
  file.remove(temp_file)
})

# Test ensure_file_exists() ----

test_that("ensure_file_exists(): returns TRUE for existing files", {
  # Setup: Create a temporary file
  temp_file <- tempfile()
  writeLines("Test content", temp_file)

  # Execute & Verify
  expect_invisible(ensure_file_exists(temp_file))

  # Cleanup
  file.remove(temp_file)
})

test_that("ensure_file_exists(): errors for non-existent files", {
  # Setup: Define a non-existent file
  non_existent <- tempfile()

  # Execute & Verify
  expect_error(ensure_file_exists(non_existent), "does not exist")
})

test_that("ensure_file_exists(): errors for directories", {
  # Setup: Create a temporary directory
  temp_dir <- tempfile()
  dir.create(temp_dir)

  # Execute & Verify
  expect_error(ensure_file_exists(temp_dir), "is a directory")

  # Cleanup
  unlink(temp_dir, recursive = TRUE)
})

# Test ensure_directory_exists() ----

test_that("ensure_directory_exists(): returns TRUE for existing directories", {
  # Setup: Create a temporary directory
  temp_dir <- tempfile()
  dir.create(temp_dir)

  # Execute & Verify
  expect_invisible(ensure_directory_exists(temp_dir))

  # Cleanup
  unlink(temp_dir, recursive = TRUE)
})

test_that("ensure_directory_exists(): errors for non-existent directories", {
  # Setup: Define a non-existent directory
  non_existent <- tempfile()

  # Execute & Verify
  expect_error(ensure_directory_exists(non_existent), "does not exist")
})

# Test ensure_valid_action() ----

test_that("ensure_valid_action(): returns TRUE for valid actions", {
  # Execute & Verify
  expect_invisible(ensure_valid_action("modify"))
  expect_invisible(ensure_valid_action("dryrun"))
  expect_invisible(ensure_valid_action("backup"))
})

test_that("ensure_valid_action(): errors for invalid actions", {
  # Execute & Verify
  expect_error(ensure_valid_action("invalid"), "Invalid action")
  expect_error(ensure_valid_action(123), "Invalid action")
  expect_error(ensure_valid_action(NULL), "Invalid action")
})

# Test ensure_valid_template() ----

test_that("ensure_valid_template(): returns TRUE for valid templates", {
  # Setup: Create a valid template
  template <- structure(
    list(
      name = "test",
      fields = NULL,
      content = NULL
    ),
    class = "stamp_template"
  )

  # Execute & Verify
  expect_invisible(ensure_valid_template(template))
})

test_that("ensure_valid_template(): errors for invalid templates", {
  # Setup: Create invalid templates
  not_a_template <- list(name = "not_a_template")
  wrong_class <- structure(list(), class = "not_a_stamp_template")

  # Execute & Verify
  expect_error(ensure_valid_template(not_a_template), "Invalid template")
  expect_error(ensure_valid_template(wrong_class), "Invalid template")
  expect_error(ensure_valid_template(NULL), "Invalid template")
})
