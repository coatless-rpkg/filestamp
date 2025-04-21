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
