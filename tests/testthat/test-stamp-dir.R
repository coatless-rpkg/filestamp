# Helper function to set up a test directory
setup_test_dir <- function() {
  # Create a temporary directory structure
  temp_dir <- file.path(tempdir(), paste0("filestamp_test_", format(Sys.time(), "%Y%m%d%H%M%S")))
  dir.create(temp_dir, recursive = TRUE)

  # Create subdirectories
  subdir <- file.path(temp_dir, "subdir")
  dir.create(subdir)

  # Create various file types
  writeLines("# R script\n", file.path(temp_dir, "script1.R"))
  writeLines("print('Python script')\n", file.path(temp_dir, "script2.py"))
  writeLines("// JavaScript\n", file.path(temp_dir, "script3.js"))
  writeLines("# Nested R script\n", file.path(subdir, "nested.R"))

  # Return the directory path
  temp_dir
}

# Helper function to clean up a test directory
cleanup_test_dir <- function(dir) {
  if (dir.exists(dir)) {
    unlink(dir, recursive = TRUE)
  }
}

# Test stamp_dir() ----

test_that("stamp_dir(): stamps all files in a directory", {
  # Setup: Create a test directory
  test_dir <- setup_test_dir()

  # Execute: Stamp the directory
  result <- stamp_dir(test_dir)

  # Verify: Check that all files in the directory have headers
  files <- list.files(test_dir, full.names = TRUE)
  files <- files[!file.info(files)$isdir]  # Filter out directories

  for (file in files) {
    expect_true(has_header(file))
  }

  # Verify the result object
  expect_s3_class(result, "stamp_dir_results")
  expect_equal(length(result$results), length(files))

  # All operations should be successful
  success_count <- sum(sapply(result$results, function(r) r$status == "success"))
  expect_equal(success_count, length(files))

  # Cleanup
  cleanup_test_dir(test_dir)
})

test_that("stamp_dir(): respects file pattern filter", {
  # Setup: Create a test directory
  test_dir <- setup_test_dir()

  # Execute: Stamp only R files
  result <- stamp_dir(test_dir, pattern = "\\.R$")

  # Verify: Check that only R files have headers
  r_files <- list.files(test_dir, pattern = "\\.R$", full.names = TRUE)
  non_r_files <- list.files(test_dir, pattern = "\\.(py|js)$", full.names = TRUE)

  for (file in r_files) {
    expect_true(has_header(file))
  }

  for (file in non_r_files) {
    expect_false(has_header(file))
  }

  # Cleanup
  cleanup_test_dir(test_dir)
})

test_that("stamp_dir(): supports recursive mode", {
  # Setup: Create a test directory
  test_dir <- setup_test_dir()
  subdir <- file.path(test_dir, "subdir")

  # Execute: Stamp recursively
  result <- stamp_dir(test_dir, recursive = TRUE)

  # Verify: Check that files in subdirectories have headers
  nested_file <- file.path(subdir, "nested.R")
  expect_true(has_header(nested_file))

  # Cleanup
  cleanup_test_dir(test_dir)
})

test_that("stamp_dir(): handles custom templates", {
  # Setup: Create a test directory
  test_dir <- setup_test_dir()

  # Create a custom template
  custom_template <- stamp_template_create(
    name = "dir_test",
    fields = stamp_template_describe(
      project = stamp_template_field("project", "Test Project", required = TRUE)
    ),
    content = stamp_template_content("Project: {{project}}")
  )

  # Execute: Stamp with custom template
  result <- stamp_dir(test_dir, template = custom_template)

  # Verify: Check that files have the custom header
  files <- list.files(test_dir, full.names = TRUE)
  files <- files[!file.info(files)$isdir]  # Filter out directories

  for (file in files) {
    content <- readLines(file)
    # The format will depend on the file type, but all should have "Project: Test Project"
    header_line <- grep("Project: Test Project", content, fixed = TRUE)
    expect_true(length(header_line) > 0)
  }

  # Cleanup
  cleanup_test_dir(test_dir)
})

test_that("stamp_dir(): performs dry run without modifying files", {
  # Setup: Create a test directory
  test_dir <- setup_test_dir()

  # Remember original content
  files <- list.files(test_dir, full.names = TRUE)
  files <- files[!file.info(files)$isdir]  # Filter out directories
  original_content <- lapply(files, readLines)
  names(original_content) <- files

  # Execute: Stamp with dry run
  result <- stamp_dir(test_dir, action = "dryrun")

  # Verify: Check that no files were modified
  for (file in files) {
    current_content <- readLines(file)
    expect_equal(current_content, original_content[[file]])
  }

  # Cleanup
  cleanup_test_dir(test_dir)
})

test_that("stamp_dir(): creates backups when requested", {
  # Setup: Create a test directory
  test_dir <- setup_test_dir()

  # Execute: Stamp with backup
  result <- stamp_dir(test_dir, action = "backup")

  # Verify: Check that backup files exist
  files <- list.files(test_dir, full.names = TRUE)
  files <- files[!file.info(files)$isdir]  # Filter out directories

  # Filter out files that are already backups (ending with .bck)
  original_files <- files[!grepl("\\.bck$", files)]

  for (file in original_files) {
    backup_file <- paste0(file, ".bck")
    expect_true(file.exists(backup_file))
  }

  # Cleanup
  cleanup_test_dir(test_dir)
})

test_that("stamp_dir(): handles non-existent directories", {
  # Setup: Define a non-existent directory
  non_existent_dir <- file.path(tempdir(), "non_existent_dir")

  # Execute & Verify: Expect error
  expect_error(stamp_dir(non_existent_dir), "does not exist")
})

# Test header_find_files() ----

test_that("header_find_files(): finds correct files", {
  # Setup: Create a test directory with various files
  test_dir <- setup_test_dir()

  # Execute: Find all files
  all_files <- header_find_files(test_dir)

  # Verify: Check that all files are found
  expected_files <- list.files(test_dir, full.names = TRUE)
  expected_files <- expected_files[!file.info(expected_files)$isdir]  # Filter out directories

  expect_equal(sort(all_files), sort(expected_files))

  # Execute: Find files with pattern
  r_files <- header_find_files(test_dir, pattern = "\\.R$")

  # Verify: Check that only R files are found
  expected_r_files <- list.files(test_dir, pattern = "\\.R$", full.names = TRUE)

  expect_equal(sort(r_files), sort(expected_r_files))

  # Execute: Find files recursively
  recursive_files <- header_find_files(test_dir, recursive = TRUE)

  # Verify: Check that files in subdirectories are found
  subdir_file <- file.path(test_dir, "subdir", "nested.R")
  expect_true(subdir_file %in% recursive_files)

  # Cleanup
  cleanup_test_dir(test_dir)
})
