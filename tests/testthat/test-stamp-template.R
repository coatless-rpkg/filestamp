# Test stamp_template_create() ----

test_that("stamp_template_create(): creates valid template object", {
  # Execute: Create a template
  template <- stamp_template_create(
    name = "test_template",
    fields = stamp_template_describe(
      copyright = stamp_template_field("copyright", "Test Company 2025", required = TRUE),
      author = stamp_template_field("author", "Test Author", required = FALSE)
    ),
    content = stamp_template_content("Copyright: {{copyright}}\nAuthor: {{author}}")
  )

  # Verify: Check template structure
  expect_s3_class(template, "stamp_template")
  expect_equal(template$name, "test_template")
  expect_s3_class(template$fields, "stamp_template_fields")
  expect_s3_class(template$content, "stamp_template_content")

  # Check fields
  expect_true("copyright" %in% names(template$fields))
  expect_true("author" %in% names(template$fields))
  expect_true(template$fields$copyright$required)
  expect_false(template$fields$author$required)

  # Check content
  expect_match(template$content, "Copyright: \\{\\{copyright\\}\\}")
  expect_match(template$content, "Author: \\{\\{author\\}\\}")
})

test_that("stamp_template_create(): works with minimal arguments", {
  # Execute: Create a minimal template
  template <- stamp_template_create(name = "minimal")

  # Verify: Check template structure
  expect_s3_class(template, "stamp_template")
  expect_equal(template$name, "minimal")
  expect_null(template$fields)
  expect_null(template$content)
})

# Test stamp_template_describe() ----

test_that("stamp_template_describe(): creates valid fields object", {
  # Execute: Create fields
  fields <- stamp_template_describe(
    field1 = stamp_template_field("field1", "value1", TRUE),
    field2 = stamp_template_field("field2", "value2", FALSE)
  )

  # Verify: Check fields structure
  expect_s3_class(fields, "stamp_template_fields")
  expect_true("field1" %in% names(fields))
  expect_true("field2" %in% names(fields))
  expect_equal(fields$field1$name, "field1")
  expect_equal(fields$field1$default, "value1")
  expect_true(fields$field1$required)
  expect_false(fields$field2$required)
})

test_that("stamp_template_describe(): works with no arguments", {
  # Execute: Create empty fields
  fields <- stamp_template_describe()

  # Verify: Check fields structure
  expect_s3_class(fields, "stamp_template_fields")
  expect_equal(length(fields), 0)
})

# Test stamp_template_field() ----

test_that("stamp_template_field(): creates valid field object", {
  # Execute: Create field
  field <- stamp_template_field("test_field", "default_value", TRUE)

  # Verify: Check field structure
  expect_s3_class(field, "stamp_template_field")
  expect_equal(field$name, "test_field")
  expect_equal(field$default, "default_value")
  expect_true(field$required)
})

test_that("stamp_template_field(): handles NULL default", {
  # Execute: Create field with NULL default
  field <- stamp_template_field("test_field")

  # Verify: Check field structure
  expect_s3_class(field, "stamp_template_field")
  expect_equal(field$name, "test_field")
  expect_null(field$default)
  expect_false(field$required)
})

# Test stamp_template_content() ----

test_that("stamp_template_content(): concatenates strings", {
  # Execute: Create content
  content <- stamp_template_content(
    "Line 1\n",
    "Line 2\n",
    "Line 3"
  )

  # Verify: Check content structure
  expect_s3_class(content, "stamp_template_content")
  expect_equal(unclass(content), "Line 1\nLine 2\nLine 3")
})

test_that("stamp_template_content(): works with single string", {
  # Execute: Create content with single string
  content <- stamp_template_content("Single line content")

  # Verify: Check content structure
  expect_s3_class(content, "stamp_template_content")
  expect_equal(unclass(content), "Single line content")
})

# Test stamp_template_default() ----

test_that("stamp_template_default(): returns valid default template", {
  # Execute: Get default template
  template <- stamp_template_default()

  # Verify: Check template structure
  expect_s3_class(template, "stamp_template")
  expect_true("copyright" %in% names(template$fields))
  expect_true("author" %in% names(template$fields))
  expect_true("license" %in% names(template$fields))

  # Check content
  expect_match(template$content, "Copyright \\(c\\) \\{\\{copyright\\}\\}")
})

# Test stamp_template_load() ----

# This test requires mocking as it depends on system.file
# or having the package installed with templates in inst/templates

test_that("stamp_template_load(): handles non-existent templates", {
  # Execute & Verify: Expect error for non-existent template
  expect_error(stamp_template_load("non_existent_template"), "Template not found")
})

# Test render_template() ----

test_that("render_template(): replaces variables correctly", {
  # Setup: Create a template
  template <- stamp_template_create(
    name = "test",
    fields = stamp_template_describe(
      copyright = stamp_template_field("copyright", "{{company}} {{year}}", required = TRUE),
      author = stamp_template_field("author", "{{user}}", required = TRUE)
    ),
    content = stamp_template_content(
      "Copyright (c) {{copyright}}\n",
      "Author: {{author}}\n",
      "File: {{filename}}"
    )
  )

  # Setup: Set environment variables and options
  old_options <- options(filestamp.company = "TestCompany")
  on.exit(options(old_options), add = TRUE)

  # Clear any cached variables to ensure our changes take effect
  options(filestamp.variables = NULL)

  # Setup variables
  # We'll use with_mocked_bindings to ensure predictable output
  withr::with_envvar(c("USER" = "TestUser"), {
    test_file <- "test_script.R"

    # Execute: Render the template
    rendered <- render_template(template, test_file)

    # Verify: Check variables were replaced
    expect_match(rendered, "Copyright \\(c\\) TestCompany \\d{4}")
    expect_match(rendered, "Author: TestUser")
    expect_match(rendered, "File: test_script\\.R")
  })
})

test_that("render_template(): handles custom variables", {
  # Setup: Create a template
  template <- stamp_template_create(
    name = "test",
    content = stamp_template_content("Custom: {{custom_var}}")
  )

  # Execute: Render with custom variable
  rendered <- render_template(template, "test.R", custom_var = "Custom Value")

  # Verify: Check custom variable was replaced
  expect_equal(unclass(rendered), "Custom: Custom Value")
})

test_that("render_template(): maintains unreplaced variables", {
  # Setup: Create a template with an unknown variable
  template <- stamp_template_create(
    name = "test",
    content = stamp_template_content("Unknown: {{unknown_var}}")
  )

  # Execute: Render the template
  rendered <- render_template(template, "test.R")

  # Verify: Check unknown variable wasn't replaced
  expect_equal(unclass(rendered), "Unknown: {{unknown_var}}")
})
