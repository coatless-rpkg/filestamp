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

test_that("has_header(): ignores roxygen documentation comments", {
  # Setup: Create an R file whose only comments are roxygen docs
  temp_file <- tempfile(fileext = ".R")
  writeLines(c(
    "#' Add two numbers",
    "#'",
    "#' @param x Numeric. First number.",
    "#' @param y Numeric. Second number.",
    "#' @author Jane Doe",
    "#' @export",
    "add <- function(x, y) x + y"
  ), temp_file)

  # Execute & Verify: roxygen tags are documentation, not a file header
  expect_false(has_header(temp_file))

  # Cleanup
  file.remove(temp_file)
})

test_that("has_header(): ignores keyword mentions inside comment prose", {
  # Setup: Comments that mention licenses/authors mid-sentence
  temp_file <- tempfile(fileext = ".R")
  writeLines(c(
    "# it under the terms of the GNU Affero General Public License as published",
    "# author_add appends an author to the field",
    "x <- 1"
  ), temp_file)

  # Execute & Verify
  expect_false(has_header(temp_file))

  # Cleanup
  file.remove(temp_file)
})

test_that("has_header(): ignores keywords inside code", {
  # Setup: Code that manipulates header keywords (filestamp's own source!)
  temp_file <- tempfile(fileext = ".R")
  writeLines(c(
    "has_header <- function(file) {",
    "  content <- readLines(file, n = 20)",
    "  any(grepl(\"copyright|author|license\", content, ignore.case = TRUE))",
    "}"
  ), temp_file)

  # Execute & Verify
  expect_false(has_header(temp_file))

  # Cleanup
  file.remove(temp_file)
})

test_that("has_header(): detects bare header lines from multi-line comment blocks", {
  # Setup: Python-style docstring header (body lines have no comment marker)
  temp_file <- tempfile(fileext = ".py")
  writeLines(c(
    '"""',
    "Copyright (c) 2025",
    "Author: Jane Doe",
    '"""',
    "def f():",
    "    pass"
  ), temp_file)

  # Execute & Verify
  expect_true(has_header(temp_file))

  # Cleanup
  file.remove(temp_file)
})

test_that("has_header(): ignores YAML front matter metadata", {
  # Setup: R Markdown file with author metadata but no header
  temp_file <- tempfile(fileext = ".Rmd")
  writeLines(c(
    "---",
    "title: \"My Document\"",
    "author: \"Jane Doe\"",
    "---",
    "",
    "# Introduction"
  ), temp_file)

  # Execute & Verify: YAML metadata is not a file header
  expect_false(has_header(temp_file))

  # Cleanup
  file.remove(temp_file)
})

test_that("has_header(): detects header following YAML front matter", {
  # Setup: R Markdown file with a real header after the front matter
  temp_file <- tempfile(fileext = ".Rmd")
  writeLines(c(
    "---",
    "title: \"My Document\"",
    "---",
    "<!-- Copyright (c) 2025 -->",
    "",
    "# Introduction"
  ), temp_file)

  # Execute & Verify
  expect_true(has_header(temp_file))

  # Cleanup
  file.remove(temp_file)
})

test_that("has_header(): ignores bare metadata in fence-less YAML config files", {
  # Setup: A pkgdown-style config with author/license keys but no header
  temp_file <- tempfile(fileext = ".yml")
  writeLines(c(
    "url: https://example.com",
    "authors:",
    "  Jane Doe:",
    "    href: https://example.com/jane",
    "license: MIT",
    "template:",
    "  bootstrap: 5"
  ), temp_file)

  # Execute & Verify: data keys are not a file header
  expect_false(has_header(temp_file))

  # Cleanup
  file.remove(temp_file)
})

test_that("has_header(): ignores markdown emphasis and bullet metadata", {
  # Setup: A README with bold/bullet metadata but no header
  temp_file <- tempfile(fileext = ".md")
  writeLines(c(
    "# My Project",
    "",
    "**Author:** Jane Doe",
    "**License:** MIT",
    "",
    "- Author: John Smith",
    "",
    "## License-related notes"
  ), temp_file)

  # Execute & Verify
  expect_false(has_header(temp_file))

  # Cleanup
  file.remove(temp_file)
})

test_that("has_header(): detects prose-style license headers", {
  # Setup: Apache boilerplate without a Copyright line
  apache_file <- tempfile(fileext = ".py")
  writeLines(c(
    "# Licensed under the Apache License, Version 2.0 (the \"License\");",
    "# you may not use this file except in compliance with the License.",
    "x = 1"
  ), apache_file)

  # Setup: Year-less copyright with owner name
  yearless_file <- tempfile(fileext = ".R")
  writeLines(c(
    "# Copyright ACME Inc. All rights reserved.",
    "x <- 1"
  ), yearless_file)

  # Execute & Verify
  expect_true(has_header(apache_file))
  expect_true(has_header(yearless_file))

  # Cleanup
  file.remove(apache_file, yearless_file)
})

test_that("has_header(): tolerates non-UTF-8 bytes in header lines", {
  # Setup: A latin-1 encoded header line (0xE9 = e-acute)
  temp_file <- tempfile(fileext = ".R")
  con <- file(temp_file, "wb")
  writeBin(charToRaw("# Copyright (c) 2024 Jos\xe9\nx <- 1\n"), con)
  close(con)

  # Execute & Verify: invalid UTF-8 must not hide the header
  expect_no_warning(expect_true(has_header(temp_file)))

  # Cleanup
  file.remove(temp_file)
})

test_that("has_header(): stays fast on pathological whitespace lines", {
  # Setup: A file whose first line is 200k spaces
  temp_file <- tempfile(fileext = ".txt")
  writeLines(c(strrep(" ", 200000), "data"), temp_file)

  # Execute & Verify: completes quickly (no quadratic regex backtracking)
  elapsed <- system.time(result <- has_header(temp_file))["elapsed"]
  expect_false(result)
  expect_lt(elapsed, 1)

  # Cleanup
  file.remove(temp_file)
})

test_that("has_header(): scans only the first 30 lines", {
  # Setup: One file with a header at line 28, one at line 35
  near_file <- tempfile(fileext = ".R")
  writeLines(c(rep("x <- 1", 27), "# Copyright (c) 2025"), near_file)
  far_file <- tempfile(fileext = ".R")
  writeLines(c(rep("x <- 1", 34), "# Copyright (c) 2025"), far_file)

  # Execute & Verify
  expect_true(has_header(near_file))
  expect_false(has_header(far_file))

  # Cleanup
  file.remove(near_file, far_file)
})

test_that("has_header(): handles empty files quietly", {
  # Setup: An empty file and a file without a trailing newline
  empty_file <- tempfile()
  file.create(empty_file)
  no_newline_file <- tempfile()
  writeChar("x <- 1", no_newline_file, eos = NULL)

  # Execute & Verify: no warnings, correct results
  expect_no_warning(expect_false(has_header(empty_file)))
  expect_no_warning(expect_false(has_header(no_newline_file)))

  # Cleanup
  file.remove(empty_file, no_newline_file)
})

# Test is_header_line() ----

test_that("is_header_line(): matches header fields across comment styles", {
  # Execute & Verify: header fields in each supported comment style
  expect_true(is_header_line("# Copyright (c) 2025"))
  expect_true(is_header_line("// Author: Test Author"))
  expect_true(is_header_line("/* License: MIT */"))
  expect_true(is_header_line("-- Copyright (c) 2024"))
  expect_true(is_header_line("<!-- License: MIT -->"))
  expect_true(is_header_line(" * Copyright (c) 2020"))
  expect_true(is_header_line("Copyright (C) 2025"))
  expect_true(is_header_line("# Copyright 2020-2024 ACME"))
  expect_true(is_header_line("# Copyright: ACME"))
})

test_that("is_header_line(): rejects documentation and prose mentions", {
  # Execute & Verify: roxygen and mid-sentence mentions are not headers
  expect_false(is_header_line("#' @author Jane Doe"))
  expect_false(is_header_line("#' Author: not a header"))
  expect_false(is_header_line("#' @param new_author Character. New author to add."))
  expect_false(is_header_line("# You should have received a copy of the GNU Affero General Public License"))
  expect_false(is_header_line("author <- \"Jane\""))
  expect_false(is_header_line("x <- \"License: MIT\""))
  expect_false(is_header_line("# Just a regular comment"))
})

test_that("is_header_line(): rejects markdown syntax", {
  # Execute & Verify: emphasis, bullets, and headings are not comments
  expect_false(is_header_line("**License:** MIT"))
  expect_false(is_header_line("**Author:** Jane Doe"))
  expect_false(is_header_line("- Author: John Smith"))
  expect_false(is_header_line("## License-related notes"))
})

test_that("is_header_line(): accepts prose-style header fields", {
  # Execute & Verify: Apache boilerplate and year-less copyright lines
  expect_true(is_header_line("# Licensed under the Apache License, Version 2.0 (the \"License\");"))
  expect_true(is_header_line("# Copyright ACME Inc."))
  expect_true(is_header_line("# Copyright The Kubernetes Authors."))
  expect_true(is_header_line("# All rights reserved."))
})

# Test header_field_lines() ----

test_that("header_field_lines(): bare fields count only inside comment blocks", {
  # Execute & Verify: a bare metadata line on its own is not a header...
  expect_equal(header_field_lines(c("author: Jane Doe", "license: MIT")),
               c(FALSE, FALSE))

  # ...but the same lines inside a docstring/block comment are
  expect_equal(header_field_lines(c('"""', "Author: Jane Doe", '"""')),
               c(FALSE, TRUE, FALSE))
  expect_equal(header_field_lines(c("/*", "Copyright (c) 2025", "*/")),
               c(FALSE, TRUE, FALSE))

  # Comment-marked fields need no block context
  expect_equal(header_field_lines("# Author: Jane"), TRUE)
})

test_that("is_header_line(): is vectorized", {
  # Setup
  lines <- c("# Copyright (c) 2025", "#' @author Jane", "# Author: X")

  # Execute & Verify
  expect_equal(is_header_line(lines), c(TRUE, FALSE, TRUE))
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

test_that("is_header_line(): recognizes Lisp (;) and TeX (%) comment markers", {
  expect_true(is_header_line("; Copyright (c) 2025"))
  expect_true(is_header_line(";; Author: Jane"))
  expect_true(is_header_line("% Copyright (c) 2025"))
  expect_true(is_header_line("% License: MIT"))
})
