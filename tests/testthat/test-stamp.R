# Test stamp() ----

test_that("stamp(): calls stamp_file for files", {
  # Setup: Create a temporary file
  temp_file <- tempfile(fileext = ".R")
  writeLines("# Test script\n", temp_file)

  # Execute: Stamp the file
  result <- stamp(temp_file)

  # Verify: Check that the file has a header
  expect_true(has_header(temp_file))

  # Cleanup
  file.remove(temp_file)
})

test_that("stamp(): calls stamp_dir for directories", {
  # Setup: Create a temporary directory with a file
  temp_dir <- tempfile()
  dir.create(temp_dir)
  test_file <- file.path(temp_dir, "test.R")
  writeLines("# Test script\n", test_file)

  # Execute: Stamp the directory
  result <- stamp(temp_dir)

  # Verify: Check that the file in the directory has a header
  expect_true(has_header(test_file))

  # Cleanup
  unlink(temp_dir, recursive = TRUE)
})

test_that("stamp(): passes arguments to appropriate functions", {
  # Setup: Create a custom template
  template <- stamp_template_create(
    name = "test_template",
    fields = stamp_template_describe(
      note = stamp_template_field("note", "Test Note", TRUE)
    ),
    content = stamp_template_content("Note: {{note}}")
  )

  # Setup: Create a temporary file
  temp_file <- tempfile(fileext = ".R")
  writeLines("# Test script", temp_file)

  # Execute: Stamp the file with custom template
  result <- stamp(temp_file, template = template, action = "dryrun")

  # Verify: Check that it's a preview (dryrun worked)
  expect_s3_class(result, "stamp_preview")
  expect_match(result$header, "# Note: Test Note")

  # Cleanup
  file.remove(temp_file)
})
