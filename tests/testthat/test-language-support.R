# Test language_register() ----

test_that("language_register(): registers a new language", {
  # Setup: Ensure clean state
  old_options <- options(filestamp.languages = NULL)
  on.exit(options(old_options), add = TRUE)

  # Execute: Register a test language
  result <- language_register(
    name = "test_lang",
    extensions = c("test", "tst"),
    comment_single = "//",
    comment_multi_start = "/*",
    comment_multi_end = "*/"
  )

  # Verify: Check result
  expect_s3_class(result, "stamp_language")
  expect_equal(result$name, "test_lang")
  expect_equal(result$extensions, c("test", "tst"))
  expect_equal(result$comment_single, "//")
  expect_equal(result$comment_multi_start, "/*")
  expect_equal(result$comment_multi_end, "*/")

  # Verify: Check persistence
  langs <- languages()
  expect_true("test_lang" %in% names(langs))
  expect_equal(langs$test_lang, result)
})

test_that("language_register(): handles minimal arguments", {
  # Setup: Ensure clean state
  old_options <- options(filestamp.languages = NULL)
  on.exit(options(old_options), add = TRUE)

  # Execute: Register a minimal language
  result <- language_register(
    name = "minimal_lang",
    extensions = "min",
    comment_single = "#"
  )

  # Verify: Check result
  expect_s3_class(result, "stamp_language")
  expect_equal(result$name, "minimal_lang")
  expect_equal(result$extensions, "min")
  expect_equal(result$comment_single, "#")
  expect_null(result$comment_multi_start)
  expect_null(result$comment_multi_end)

  # Verify: Check persistence
  langs <- languages()
  expect_true("minimal_lang" %in% names(langs))
})

test_that("language_register(): overwrites existing language", {
  # Setup: Ensure clean state
  old_options <- options(filestamp.languages = NULL)
  on.exit(options(old_options), add = TRUE)

  # Register initial language
  language_register(
    name = "override_lang",
    extensions = "old",
    comment_single = "#"
  )

  # Execute: Register with same name
  result <- language_register(
    name = "override_lang",
    extensions = "new",
    comment_single = "//"
  )

  # Verify: Check result
  expect_equal(result$extensions, "new")
  expect_equal(result$comment_single, "//")

  # Verify: Check persistence
  langs <- languages()
  expect_equal(langs$override_lang$extensions, "new")
})

# Test language_get() ----

test_that("language_get(): retrieves registered language", {
  # Setup: Ensure clean state
  old_options <- options(filestamp.languages = NULL)
  on.exit(options(old_options), add = TRUE)

  # Register a test language
  test_lang <- language_register(
    name = "get_test",
    extensions = "get",
    comment_single = "#"
  )

  # Execute: Get the language
  result <- language_get("get_test")

  # Verify: Check result
  expect_s3_class(result, "stamp_language")
  expect_equal(result, test_lang)
})

test_that("language_get(): handles non-existent language", {
  # Execute & Verify: Expect error
  expect_error(language_get("non_existent"), "Language not found")
})

# Test languages() ----

test_that("languages(): returns all registered languages", {
  # Setup: Ensure clean state
  old_options <- options(filestamp.languages = NULL)
  on.exit(options(old_options), add = TRUE)

  # Register test languages
  lang1 <- language_register(
    name = "lang1",
    extensions = "l1",
    comment_single = "#"
  )

  lang2 <- language_register(
    name = "lang2",
    extensions = "l2",
    comment_single = "//"
  )

  # Execute: Get all languages
  result <- languages()

  # Verify: Check result
  expect_type(result, "list")
  expect_equal(names(result), c("lang1", "lang2"))
  expect_equal(result$lang1, lang1)
  expect_equal(result$lang2, lang2)
})

test_that("languages(): returns empty list when no languages registered", {
  # Setup: Ensure clean state
  old_options <- options(filestamp.languages = NULL)
  on.exit(options(old_options), add = TRUE)

  # Execute: Get languages
  result <- languages()

  # Verify: Check result
  expect_equal(result, list())
})

# Test detect_language() ----

test_that("detect_language(): identifies language by extension", {
  # Setup: Ensure clean state and register test languages
  old_options <- options(filestamp.languages = NULL)
  on.exit(options(old_options), add = TRUE)

  language_register(
    name = "r_test",
    extensions = c("r", "R"),
    comment_single = "#"
  )

  language_register(
    name = "python_test",
    extensions = c("py"),
    comment_single = "#"
  )

  language_register(
    name = "text",
    extensions = c("txt"),
    comment_single = "#"
  )

  # Execute & Verify: R file
  r_file <- "script.r"
  r_result <- detect_language(r_file)
  expect_equal(r_result$name, "r_test")

  # Execute & Verify: R file with uppercase extension
  r_upper_file <- "script.R"
  r_upper_result <- detect_language(r_upper_file)
  expect_equal(r_upper_result$name, "r_test")

  # Execute & Verify: Python file
  py_file <- "script.py"
  py_result <- detect_language(py_file)
  expect_equal(py_result$name, "python_test")

  # Execute & Verify: Unknown extension
  unknown_file <- "script.unknown"
  unknown_result <- detect_language(unknown_file)
  expect_equal(unknown_result$name, "text")  # Default to text
})

# Test format_header() ----

test_that("format_header(): formats with single-line comments", {
  # Setup: Create content and language
  content <- "Copyright (c) 2025\nAuthor: Test"

  language <- structure(
    list(
      name = "single_line_test",
      extensions = "sl",
      comment_single = "#",
      comment_multi_start = NULL,
      comment_multi_end = NULL
    ),
    class = "stamp_language"
  )

  # Execute: Format header
  result <- format_header(content, language)

  # Verify: Check result
  expected <- "# Copyright (c) 2025\n# Author: Test"
  expect_equal(result, expected)
})

test_that("format_header(): formats with multi-line comments", {
  # Setup: Create content and language
  content <- "Copyright (c) 2025\nAuthor: Test"

  language <- structure(
    list(
      name = "multi_line_test",
      extensions = "ml",
      comment_single = "//",
      comment_multi_start = "/*",
      comment_multi_end = "*/"
    ),
    class = "stamp_language"
  )

  # Execute: Format header
  result <- format_header(content, language)

  # Verify: Check result
  expected <- "/*\nCopyright (c) 2025\nAuthor: Test\n*/"
  expect_equal(result, expected)
})

test_that("format_header(): prioritizes multi-line comments if available", {
  # Setup: Create content and language with both comment types
  content <- "Copyright (c) 2025\nAuthor: Test"

  language <- structure(
    list(
      name = "both_comment_types",
      extensions = "bc",
      comment_single = "//",
      comment_multi_start = "/*",
      comment_multi_end = "*/"
    ),
    class = "stamp_language"
  )

  # Execute: Format header
  result <- format_header(content, language)

  # Verify: Check result (should use multi-line)
  expected <- "/*\nCopyright (c) 2025\nAuthor: Test\n*/"
  expect_equal(result, expected)
})

# Test initial language registration in .onLoad ----

test_that(".onLoad registers default languages", {
  # Setup: Create a mock environment
  env <- new.env()

  # Execute: Call .onLoad (directly or via with_mocked_bindings)
  withr::with_options(list(filestamp.languages = NULL), {
    .onLoad("", "")

    # Verify: Check default languages are registered
    langs <- languages()

    # Check some common languages
    expect_true("r" %in% names(langs))
    expect_true("python" %in% names(langs))
    expect_true("c" %in% names(langs))
    expect_true("text" %in% names(langs))

    # Check R language details
    r_lang <- langs$r
    expect_equal(r_lang$extensions, c("r", "R"))
    expect_equal(r_lang$comment_single, "#")

    # Check C language details
    c_lang <- langs$c
    expect_equal(c_lang$extensions, c("c", "h"))
    expect_equal(c_lang$comment_single, "//")
    expect_equal(c_lang$comment_multi_start, "/*")
    expect_equal(c_lang$comment_multi_end, "*/")
  })
})
