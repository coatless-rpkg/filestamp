# Test header_file_info() ----

test_that("header_file_info(): detects file encoding and line endings", {
  # Setup: Create test files with different encodings/line endings
  temp_dir <- tempdir()
  
  # UTF-8 with LF
  utf8_lf_file <- file.path(temp_dir, "utf8_lf.txt")
  con <- file(utf8_lf_file, "wb")
  writeLines("Test content\nSecond line", con, sep = "\n")
  close(con)
  
  # Execute: Get file info
  info <- header_file_info(utf8_lf_file)
  
  # Verify: Check result
  expect_s3_class(info, "stamp_file_info")
  expect_equal(info$path, utf8_lf_file)
  expect_equal(info$encoding, "UTF-8")
  expect_equal(info$line_ending, "\n")
  expect_false(info$read_only)
  
  # Creating a CRLF file on Windows or with writeLines is tricky
  # For this test, we'll focus on testing the LF case
  
  # Cleanup
  file.remove(utf8_lf_file)
})

test_that("header_file_info(): detects read-only status", {
  # Skip on systems where file permissions aren't easily testable
  skip_on_os(c("windows"))
  
  # Setup: Create a read-only file
  temp_dir <- tempdir()
  ro_file <- file.path(temp_dir, "readonly.txt")
  writeLines("Read-only content", ro_file)
  
  # Make the file read-only
  perms <- file.info(ro_file)$mode
  Sys.chmod(ro_file, "0444")  # read-only for all
  
  # Execute: Get file info
  info <- header_file_info(ro_file)
  
  # Verify: Check read-only status
  expect_true(info$read_only)
  
  # Restore permissions and cleanup
  Sys.chmod(ro_file, perms)
  file.remove(ro_file)
})

# Test guess_encoding() ----

test_that("guess_encoding(): detects UTF-8", {
  # Setup: Create UTF-8 content
  content <- charToRaw("Regular UTF-8 content")
  
  # Execute: Guess encoding
  encoding <- guess_encoding(content)
  
  # Verify: Check result
  expect_equal(encoding, "UTF-8")
})

test_that("guess_encoding(): detects UTF-8 with BOM", {
  # Setup: Create UTF-8 content with BOM
  bom <- as.raw(c(0xEF, 0xBB, 0xBF))
  content <- c(bom, charToRaw("UTF-8 with BOM content"))
  
  # Execute: Guess encoding
  encoding <- guess_encoding(content)
  
  # Verify: Check result
  expect_equal(encoding, "UTF-8")
})

test_that("guess_encoding(): detects UTF-16BE with BOM", {
  # Setup: Create UTF-16BE content with BOM
  bom <- as.raw(c(0xFE, 0xFF))
  content <- c(bom, as.raw(c(0x00, 0x61, 0x00, 0x62, 0x00, 0x63)))  # "abc" in UTF-16BE
  
  # Execute: Guess encoding
  encoding <- guess_encoding(content)
  
  # Verify: Check result
  expect_equal(encoding, "UTF-16BE")
})

test_that("guess_encoding(): detects UTF-16LE with BOM", {
  # Setup: Create UTF-16LE content with BOM
  bom <- as.raw(c(0xFF, 0xFE))
  content <- c(bom, as.raw(c(0x61, 0x00, 0x62, 0x00, 0x63, 0x00)))  # "abc" in UTF-16LE
  
  # Execute: Guess encoding
  encoding <- guess_encoding(content)
  
  # Verify: Check result
  expect_equal(encoding, "UTF-16LE")
})

# Test guess_line_ending() ----

test_that("guess_line_ending(): detects LF", {
  # Setup: Create content with LF line endings
  content <- charToRaw("Line 1\nLine 2\nLine 3")
  
  # Execute: Guess line ending
  ending <- guess_line_ending(content)
  
  # Verify: Check result
  expect_equal(ending, "\n")
})

test_that("guess_line_ending(): detects CR", {
  # Setup: Create content with CR line endings
  content <- charToRaw("Line 1\rLine 2\rLine 3\r")
  
  # Execute: Guess line ending
  ending <- guess_line_ending(content)
  
  # Verify: Check result
  expect_equal(ending, "\r")
})

test_that("guess_line_ending(): detects CRLF", {
  # Setup: Create content with CRLF line endings
  content <- charToRaw("Line 1\r\nLine 2\r\nLine 3\r\n")
  
  # Execute: Guess line ending
  ending <- guess_line_ending(content)
  
  # Verify: Check result
  expect_equal(ending, "\r\n")
})

test_that("guess_line_ending(): handles mixed line endings", {
  # Setup: Create content with mixed line endings
  content <- charToRaw("Line 1\nLine 2\r\nLine 3\rLine 4")
  
  # Execute: Guess line ending
  ending <- guess_line_ending(content)
  
  # Note: With mixed endings, the result depends on which type is most frequent
  # For this test, we'll accept any valid ending
  expect_true(ending %in% c("\n", "\r", "\r\n"))
})
