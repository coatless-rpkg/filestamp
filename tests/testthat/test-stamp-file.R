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

  # Verify: Check that the header was inserted at the beginning,
  # separated from the code by a blank line
  content <- readLines(test_file)
  expect_match(content[1], "# Note: Test Note")
  expect_equal(content[2], "")
  expect_equal(content[3], "x <- 1 + 2")

  # Cleanup
  file.remove(test_file)
})

test_that("stamp_file(): stamps files whose only comments are roxygen docs", {
  # Setup: An R file documented with roxygen, including an @author tag
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "test_roxygen.R")
  roxygen_lines <- c(
    "#' Add two numbers",
    "#'",
    "#' @param x Numeric. First number.",
    "#' @param y Numeric. Second number.",
    "#' @author Jane Doe",
    "#' @export",
    "add <- function(x, y) x + y"
  )
  writeLines(roxygen_lines, test_file)

  # Execute: Stamp the file (must not be mistaken for an existing header)
  expect_no_warning(
    stamp_file(test_file, action = "modify",
               copyright = "2025", author = "Test Author")
  )

  # Verify: Header inserted at the top, roxygen docs untouched, valid R
  content <- readLines(test_file)
  expect_match(content[1], "^# Copyright \\(c\\) 2025")
  expect_equal(tail(content, length(roxygen_lines)), roxygen_lines)
  expect_no_error(parse(test_file))

  # Cleanup
  file.remove(test_file)
})

test_that("stamp_file(): stamps a file containing only a shebang line", {
  # Setup: A one-line script
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "test_shebang.sh")
  writeLines("#!/bin/bash", test_file)

  # Execute
  stamp_file(test_file, action = "modify",
             copyright = "2025", author = "Test Author")

  # Verify: Shebang stays first and appears exactly once, header follows,
  # and no NA lines are written
  content <- readLines(test_file, warn = FALSE)
  expect_equal(content[1], "#!/bin/bash")
  expect_equal(sum(content == "#!/bin/bash"), 1)
  expect_match(content[2], "^# Copyright \\(c\\) 2025")
  expect_false(any(content == "NA"))

  # Cleanup
  file.remove(test_file)
})

test_that("stamp_file(): stamps an empty file", {
  # Setup: An empty file
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "test_empty.R")
  file.create(test_file)

  # Execute
  stamp_file(test_file, action = "modify",
             copyright = "2025", author = "Test Author")

  # Verify: Header written, no stray lines
  content <- readLines(test_file, warn = FALSE)
  expect_match(content[1], "^# Copyright \\(c\\) 2025")
  expect_false(any(content == "NA"))
  expect_false(any(is.na(content)))

  # Cleanup
  file.remove(test_file)
})

test_that("stamp_file(): stamps fence-less YAML config files", {
  # Setup: A pkgdown-style YAML config (data keys, no header)
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "test_config.yml")
  yaml_lines <- c(
    "url: https://example.com",
    "authors:",
    "  Jane Doe:",
    "    href: https://example.com/jane",
    "license: MIT"
  )
  writeLines(yaml_lines, test_file)

  # Execute: Must not be mistaken for an already-stamped file
  expect_no_warning(
    stamp_file(test_file, action = "modify",
               copyright = "2025", author = "Test Author")
  )

  # Verify: Stamped with # comments, original data intact, now detected
  content <- readLines(test_file)
  expect_match(content[1], "^# Copyright \\(c\\) 2025")
  expect_equal(tail(content, length(yaml_lines)), yaml_lines)
  expect_true(has_header(test_file))

  # Cleanup
  file.remove(test_file)
})

test_that("stamp_file(): stamps markdown files with bold metadata", {
  # Setup: A README with **Author:**/**License:** metadata but no header
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "test_readme.md")
  md_lines <- c(
    "# My Project",
    "",
    "**Author:** Jane Doe",
    "**License:** MIT"
  )
  writeLines(md_lines, test_file)

  # Execute
  expect_no_warning(
    stamp_file(test_file, action = "modify",
               copyright = "2025", author = "Test Author")
  )

  # Verify: Stamped with an HTML comment block, detected afterwards
  content <- readLines(test_file)
  expect_equal(content[1], "<!--")
  expect_equal(tail(content, length(md_lines)), md_lines)
  expect_true(has_header(test_file))

  # Cleanup
  file.remove(test_file)
})

test_that("stamp_file(): preserves CRLF line endings in inserted header", {
  # Setup: A file with CRLF line endings
  temp_dir <- tempdir()
  test_file <- file.path(temp_dir, "test_crlf.R")
  con <- file(test_file, "wb")
  writeBin(charToRaw("x <- 1\r\ny <- 2\r\n"), con)
  close(con)

  # Execute
  stamp_file(test_file, action = "modify",
             copyright = "2025", author = "Test Author")

  # Verify: Every newline in the file, including the header's, is CRLF
  raw_text <- rawToChar(readBin(test_file, "raw", n = file.info(test_file)$size))
  expect_false(grepl("(?<!\r)\n", raw_text, perl = TRUE))
  expect_match(raw_text, "Copyright \\(c\\) 2025")

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

test_that("determine_insert_position(): handles language prologues", {
  # A header must go AFTER these lines, never before them
  expect_equal(determine_insert_position(c("<?php", "echo 1;")), 1)
  expect_equal(determine_insert_position(c("<?php echo 1;", "$x = 2;")), 1)
  expect_equal(determine_insert_position(c("<!DOCTYPE html>", "<html></html>")), 1)
  expect_equal(determine_insert_position(c("<?xml version=\"1.0\"?>", "<root/>")), 1)
})

test_that("stamp_file(): inserts a PHP header after the <?php open tag", {
  # Setup: A PHP file whose first line is the open tag
  test_file <- withr::local_tempfile(fileext = ".php")
  writeLines(c("<?php", "echo 'hello';"), test_file)

  # Execute
  stamp_file(test_file, copyright = "2025", author = "Jane")

  # Verify: <?php stays first, the block-comment header follows it
  content <- readLines(test_file)
  expect_equal(content[1], "<?php")
  expect_equal(content[2], "/*")
  expect_true(any(grepl("Copyright \\(c\\) 2025", content)))
  # The open tag must appear exactly once and never after the header
  expect_equal(sum(content == "<?php"), 1)
})

test_that("stamp_file(): inserts an HTML header after the doctype", {
  # Setup: An HTML file starting with a doctype
  test_file <- withr::local_tempfile(fileext = ".html")
  writeLines(c("<!DOCTYPE html>", "<html></html>"), test_file)

  # Execute
  stamp_file(test_file, copyright = "2025", author = "Jane")

  # Verify: doctype stays first
  content <- readLines(test_file)
  expect_equal(content[1], "<!DOCTYPE html>")
  expect_true(any(grepl("Copyright \\(c\\) 2025", content)))
})

test_that("stamp_file(): preserves a UTF-8 byte-order mark", {
  # Setup: A UTF-8 file that begins with a BOM
  test_file <- withr::local_tempfile(fileext = ".R")
  con <- file(test_file, "wb")
  writeBin(c(as.raw(c(0xEF, 0xBB, 0xBF)), charToRaw("x <- 1\n")), con)
  close(con)

  # Execute
  stamp_file(test_file, copyright = "2025", author = "Jane")

  # Verify: the file still starts with exactly one BOM, header present
  bytes <- readBin(test_file, "raw", n = file.info(test_file)$size)
  expect_equal(bytes[1:3], as.raw(c(0xEF, 0xBB, 0xBF)))
  # BOM appears only once (not re-emitted mid-file)
  bom_hits <- gregexpr(rawToChar(as.raw(c(0xEF, 0xBB, 0xBF))),
                       rawToChar(bytes), fixed = TRUE)[[1]]
  expect_equal(sum(bom_hits > 0), 1)
  expect_match(rawToChar(bytes), "Copyright \\(c\\) 2025")
})

# File-safety: unknown formats, backups ----

test_that("stamp_file(): skips comment-less / unknown formats with a warning", {
  # Setup: A JSON file (no comment syntax; unknown extension)
  test_file <- withr::local_tempfile(fileext = ".json")
  original <- '{"name": "demo", "value": 1}'
  writeLines(original, test_file)

  # Execute & Verify: warns and does NOT modify the file
  expect_warning(
    result <- stamp_file(test_file, copyright = "2025", author = "J"),
    "[Ss]kip"
  )
  expect_false(result)

  # Verify: file is untouched (byte-for-byte), so still valid JSON
  expect_equal(readLines(test_file), original)
})

test_that("stamp_file(): backup action leaves no orphan .bck when nothing is written", {
  # Case 1: already-stamped file (no-op) must not create a backup
  headed <- withr::local_tempfile(fileext = ".R")
  writeLines(c("# Copyright (c) 2025", "# Author: J", "", "x <- 1"), headed)
  suppressWarnings(stamp_file(headed, action = "backup", copyright = "2025", author = "J"))
  expect_false(file.exists(paste0(headed, ".bck")))

  # Case 2: read-only file must abort without creating a backup
  ro <- withr::local_tempfile(fileext = ".R")
  writeLines("x <- 1", ro)
  Sys.chmod(ro, "0444")
  expect_error(stamp_file(ro, action = "backup", copyright = "2025", author = "J"),
               "read-only")
  expect_false(file.exists(paste0(ro, ".bck")))
  Sys.chmod(ro, "0644")  # restore so tempfile cleanup can remove it
})

test_that("stamp_file(): aborts on a read-only file (modify)", {
  test_file <- withr::local_tempfile(fileext = ".R")
  writeLines("x <- 1", test_file)
  Sys.chmod(test_file, "0444")

  expect_error(
    stamp_file(test_file, copyright = "2025", author = "J"),
    "read-only"
  )
  # File untouched
  expect_equal(readLines(test_file), "x <- 1")

  Sys.chmod(test_file, "0644")  # allow tempfile cleanup
})
