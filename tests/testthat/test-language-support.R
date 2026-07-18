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

  # Execute & Verify: Unknown extension returns NULL so callers can skip it
  # rather than silently stamping it with the wrong comment syntax
  unknown_file <- "script.unknown"
  expect_null(detect_language(unknown_file))

  # Execute & Verify: No extension also returns NULL
  expect_null(detect_language("Makefile"))
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

# Per-language stamping round-trip ----

test_that("stamp_file(): round-trips every registered language", {
  # For each language, stamp a representative file and confirm the comment
  # style is applied and the header is detected afterward. Pins format_header
  # and has_header against a regression in any language's comment definition.
  cases <- list(
    list(ext = "R",    marker = "# ",     block = FALSE),
    list(ext = "py",   marker = '"""',    block = TRUE),
    list(ext = "c",    marker = "/*",     block = TRUE),
    list(ext = "cpp",  marker = "/*",     block = TRUE),
    list(ext = "java", marker = "/*",     block = TRUE),
    list(ext = "js",   marker = "/*",     block = TRUE),
    list(ext = "ts",   marker = "/*",     block = TRUE),
    list(ext = "rs",   marker = "/*",     block = TRUE),
    list(ext = "rb",   marker = "=begin", block = TRUE),
    list(ext = "pl",   marker = "# ",     block = FALSE),
    list(ext = "sh",   marker = "# ",     block = FALSE),
    list(ext = "sql",  marker = "/*",     block = TRUE),
    list(ext = "yml",  marker = "# ",     block = FALSE),
    list(ext = "md",   marker = "<!--",   block = TRUE),
    list(ext = "html", marker = "<!--",   block = TRUE),
    list(ext = "css",  marker = "/*",     block = TRUE),
    list(ext = "txt",  marker = "# ",     block = FALSE),
    # Newly added languages
    list(ext = "go",   marker = "/*",     block = TRUE),
    list(ext = "kt",   marker = "/*",     block = TRUE),
    list(ext = "swift",marker = "/*",     block = TRUE),
    list(ext = "cs",   marker = "/*",     block = TRUE),
    list(ext = "scala",marker = "/*",     block = TRUE),
    list(ext = "dart", marker = "/*",     block = TRUE),
    list(ext = "mm",   marker = "/*",     block = TRUE),
    list(ext = "jl",   marker = "#=",     block = TRUE),
    list(ext = "ex",   marker = "# ",     block = FALSE),
    list(ext = "hs",   marker = "{-",     block = TRUE),
    list(ext = "lua",  marker = "--[[",   block = TRUE),
    list(ext = "ps1",  marker = "<#",     block = TRUE),
    list(ext = "tex",  marker = "% ",     block = FALSE),
    list(ext = "f90",  marker = "! ",     block = FALSE),
    list(ext = "toml", marker = "# ",     block = FALSE),
    list(ext = "scss", marker = "/*",     block = TRUE),
    list(ext = "less", marker = "/*",     block = TRUE),
    list(ext = "sass", marker = "// ",    block = FALSE),
    list(ext = "rmd",  marker = "<!--",   block = TRUE),
    list(ext = "qmd",  marker = "<!--",   block = TRUE)
  )

  for (case in cases) {
    test_file <- withr::local_tempfile(fileext = paste0(".", case$ext))
    writeLines("body content", test_file)
    suppressWarnings(stamp_file(test_file, copyright = "2025", author = "Jane"))
    content <- readLines(test_file)

    if (case$block) {
      expect_equal(content[1], case$marker,
                   info = paste(case$ext, "block-comment opener"))
    } else {
      expect_match(content[1], paste0("^", case$marker, "Copyright"),
                   info = paste(case$ext, "single-line comment"))
    }
    expect_true(has_header(test_file),
                info = paste(case$ext, "detected after stamping"))
  }
})

test_that("stamp_file(): stamps a PHP file with no open tag using a block comment", {
  test_file <- withr::local_tempfile(fileext = ".php")
  writeLines("echo 'hi';", test_file)
  suppressWarnings(stamp_file(test_file, copyright = "2025", author = "Jane"))
  expect_equal(readLines(test_file)[1], "/*")
  expect_true(has_header(test_file))
})

test_that("detect_language(): follows file-extension semantics", {
  expect_equal(detect_language("my.script.R")$name, "r")
  expect_equal(detect_language("a.b.c.py")$name, "python")
  expect_equal(detect_language("SCRIPT.PY")$name, "python")   # case-folded
  expect_null(detect_language("Makefile"))                    # no extension
  expect_null(detect_language(".Rprofile"))                   # dotfile, no ext
})

test_that("detect_language(): recognizes new languages and R-ecosystem files", {
  expect_equal(detect_language("main.go")$name, "go")
  expect_equal(detect_language("App.kt")$name, "kotlin")
  expect_equal(detect_language("Model.swift")$name, "swift")
  expect_equal(detect_language("Program.cs")$name, "csharp")
  expect_equal(detect_language("analysis.jl")$name, "julia")
  expect_equal(detect_language("script.lua")$name, "lua")
  expect_equal(detect_language("deploy.ps1")$name, "powershell")
  expect_equal(detect_language("config.toml")$name, "toml")
  expect_equal(detect_language("paper.tex")$name, "latex")
  # R-ecosystem files that used to be silently skipped
  expect_equal(detect_language("vignette.Rmd")$name, "rmarkdown")
  expect_equal(detect_language("report.qmd")$name, "quarto")
  expect_equal(detect_language("sweave.Rnw")$name, "latex")
})

test_that("detect_language(): leaves ambiguous extensions unregistered (safe skip)", {
  # .m (Objective-C vs MATLAB vs Mathematica), .cls (LaTeX vs Apex vs VBA),
  # and fixed-form Fortran (.f/.for) all have conflicting comment syntax,
  # so they must fall through to NULL -> skip+warn rather than be corrupted.
  expect_null(detect_language("matrix.m"))
  expect_null(detect_language("MyClass.cls"))
  expect_null(detect_language("legacy.f"))
  expect_null(detect_language("legacy.for"))

  # Objective-C++ (.mm) is unambiguous and IS registered
  expect_equal(detect_language("View.mm")$name, "objective-c")
})

test_that("stamp_file(): stamps an R Markdown file after its YAML front matter", {
  test_file <- withr::local_tempfile(fileext = ".Rmd")
  writeLines(c(
    "---",
    "title: \"My Vignette\"",
    "output: html_document",
    "---",
    "",
    "# Introduction",
    "",
    "Some prose."
  ), test_file)

  suppressWarnings(stamp_file(test_file, copyright = "2025", author = "Jane"))
  content <- readLines(test_file)

  # YAML front matter stays first; header is an HTML comment block after it
  expect_equal(content[1:4], c("---", "title: \"My Vignette\"",
                               "output: html_document", "---"))
  expect_equal(content[5], "<!--")
  expect_true(any(grepl("Copyright \\(c\\) 2025", content)))
  expect_true(has_header(test_file))
})
