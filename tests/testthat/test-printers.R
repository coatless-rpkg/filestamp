# Test S3 print methods ----

cli::test_that_cli("print.stamp_template(): prints template information", {
  testthat::local_edition(3)
  
  # Setup: Create a template
  template <- stamp_template_create(
    name = "print_test",
    fields = stamp_template_describe(
      copyright = stamp_template_field("copyright", "Test 2025", TRUE),
      author = stamp_template_field("author", "Test Author", FALSE)
    ),
    content = stamp_template_content("Copyright: {{copyright}}\nAuthor: {{author}}")
  )
  
  # Execute and verify: Snapshot the output
  testthat::expect_snapshot({
    print(template)
  })
}, configs = c("plain", "ansi", "unicode", "fancy"))

cli::test_that_cli("print.stamp_preview(): prints preview information", {
  testthat::local_edition(3)
  
  # Setup: Create a preview object
  preview <- structure(
    list(
      file = "test.R",
      header = "# Copyright (c) Test 2025\n# Author: Test Author",
      insert_position = 0,
      encoding = "UTF-8",
      line_ending = "\n",
      read_only = FALSE
    ),
    class = "stamp_preview"
  )
  
  # Execute and verify: Snapshot the output
  testthat::expect_snapshot({
    print(preview)
  })
}, configs = c("plain", "ansi", "unicode", "fancy"))

cli::test_that_cli("print.stamp_language(): prints language information", {
  testthat::local_edition(3)
  
  # Setup: Create a language object
  language <- structure(
    list(
      name = "print_lang",
      extensions = c("pl", "prl"),
      comment_single = "#",
      comment_multi_start = "=begin",
      comment_multi_end = "=end"
    ),
    class = "stamp_language"
  )
  
  # Execute and verify: Snapshot the output
  testthat::expect_snapshot({
    print(language)
  })
}, configs = c("plain", "ansi", "unicode", "fancy"))

cli::test_that_cli("print.stamp_dir_results(): prints directory results", {
  testthat::local_edition(3)
  
  # Setup: Create a directory results object
  results <- structure(
    list(
      results = list(
        list(file = "file1.R", status = "success"),
        list(file = "file2.R", status = "success"),
        list(file = "file3.R", status = "error", message = "Error message")
      ),
      dir = "test_dir",
      action = "modify"
    ),
    class = "stamp_dir_results"
  )
  
  # Execute and verify: Snapshot the output
  testthat::expect_snapshot({
    print(results)
  })
}, configs = c("plain", "ansi", "unicode", "fancy"))

cli::test_that_cli("print.stamp_file_info(): prints file information", {
  testthat::local_edition(3)
  
  # Setup: Create a file info object
  file_info <- structure(
    list(
      path = "test.R",
      encoding = "UTF-8",
      line_ending = "\n",
      read_only = FALSE
    ),
    class = "stamp_file_info"
  )
  
  # Execute and verify: Snapshot the output
  testthat::expect_snapshot({
    print(file_info)
  })
}, configs = c("plain", "ansi", "unicode", "fancy"))

cli::test_that_cli("print.stamp_update_preview(): prints update preview", {
  testthat::local_edition(3)
  
  # Setup: Create an update preview object
  update_preview <- structure(
    list(
      file = "test.R",
      fields = list(
        copyright = "Test 2025",
        author = "Test Author"
      ),
      range = c(1, 3),
      encoding = "UTF-8",
      line_ending = "\n",
      read_only = FALSE
    ),
    class = "stamp_update_preview"
  )
  
  # Execute and verify: Snapshot the output
  testthat::expect_snapshot({
    print(update_preview)
  })
}, configs = c("plain", "ansi", "unicode", "fancy"))

# Test print.stamp_dir_results() with empty results ----

test_that("print.stamp_dir_results(): handles empty results", {
  # Setup: Stamp a directory containing no files
  empty_dir <- file.path(tempdir(), "filestamp_empty_dir")
  dir.create(empty_dir, showWarnings = FALSE)

  # Execute & Verify: printing the result must not error
  result <- suppressMessages(stamp_dir(empty_dir))
  expect_no_error(suppressMessages(print(result)))

  # Cleanup
  unlink(empty_dir, recursive = TRUE)
})

# Print-method display branches (non-snapshot) ----

# Helper: render a print method's output as plain text (ANSI stripped)
print_text <- function(x) {
  cli::ansi_strip(paste(cli::cli_fmt(print(x)), collapse = "\n"))
}

test_that("print.stamp_preview(): shows non-default insertion points and endings", {
  # After a prologue line (shebang/php/doctype -> position 1)
  preview_shebang <- structure(
    list(file = "s.sh", header = "# H", insert_position = 1,
         encoding = "UTF-8", line_ending = "\r\n", read_only = TRUE),
    class = "stamp_preview"
  )
  out <- print_text(preview_shebang)
  expect_match(out, "After line 1")
  expect_match(out, "CRLF")
  expect_match(out, "Read-only:\\s*Yes")
})

test_that("print.stamp_file_info(): shows CR line endings", {
  info <- structure(
    list(path = "f.R", encoding = "UTF-8", has_bom = FALSE,
         line_ending = "\r", read_only = FALSE),
    class = "stamp_file_info"
  )
  expect_match(print_text(info), "CR")
})

test_that("print.stamp_language(): omits multi-line rows for single-line languages", {
  single <- language_get("r")       # comment_single only
  out <- print_text(single)
  expect_match(out, "Single line")
  expect_no_match(out, "Multi-line")

  multi <- language_get("c")        # has multi-line comments
  expect_match(print_text(multi), "Multi-line")
})

test_that("print.stamp_dir_results(): reports errors and skips", {
  results <- structure(
    list(
      results = list(
        list(file = "a.R", status = "success"),
        list(file = "b.json", status = "skipped"),
        list(file = "c.R", status = "error", message = "boom")
      ),
      dir = "d", action = "modify"
    ),
    class = "stamp_dir_results"
  )
  out <- print_text(results)
  expect_match(out, "1 files successfully processed")
  expect_match(out, "1 files skipped")
  expect_match(out, "1 files had errors")
  expect_match(out, "boom")
})
