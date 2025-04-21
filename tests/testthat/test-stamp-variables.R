# Test stamp_variables() ----

test_that("stamp_variables(): returns environment with built-in variables", {
  # Setup: Ensure clean state
  old_options <- options(filestamp.variables = NULL)
  on.exit(options(old_options), add = TRUE)

  # Execute: Get variables
  vars <- stamp_variables()

  # Verify: Check result type
  expect_type(vars, "environment")

  # Verify: Check built-in variables
  expect_true("cwd" %in% ls(vars))
  expect_true("date" %in% ls(vars))
  expect_true("date_full" %in% ls(vars))
  expect_true("year" %in% ls(vars))
  expect_true("user" %in% ls(vars))
  expect_true("company" %in% ls(vars))
  expect_true("file_ext" %in% ls(vars))
  expect_true("filename" %in% ls(vars))

  # Verify: Check function variables
  expect_type(vars$cwd, "closure")
  expect_type(vars$date, "closure")
  expect_type(vars$year, "closure")

  # Verify: Check function output
  expect_equal(vars$year(), format(Sys.time(), "%Y"))
})

test_that("stamp_variables(): returns cached variables if available", {
  # Setup: Create a test environment
  test_env <- new.env()
  test_env$test_var <- "test_value"

  # Set as cached variables
  options(filestamp.variables = test_env)

  # Execute: Get variables
  vars <- stamp_variables()

  # Verify: Check it's the same environment
  expect_identical(vars, test_env)
  expect_equal(vars$test_var, "test_value")

  # Cleanup
  options(filestamp.variables = NULL)
})

# Test stamp_variables_add() ----

test_that("stamp_variables_add(): adds scalar value", {
  # Setup: Ensure clean state
  old_options <- options(filestamp.variables = NULL)
  on.exit(options(old_options), add = TRUE)

  # Execute: Add a variable
  result <- stamp_variables_add("test_scalar", "test_value")

  # Verify: Check result
  expect_type(result, "environment")
  expect_equal(result$test_scalar, "test_value")

  # Verify: Check persistence
  vars <- stamp_variables()
  expect_equal(vars$test_scalar, "test_value")
})

test_that("stamp_variables_add(): adds function value", {
  # Setup: Ensure clean state
  old_options <- options(filestamp.variables = NULL)
  on.exit(options(old_options), add = TRUE)

  # Execute: Add a function variable
  test_func <- function() "function_result"
  result <- stamp_variables_add("test_func", test_func)

  # Verify: Check result
  expect_type(result, "environment")
  expect_type(result$test_func, "closure")
  expect_equal(result$test_func(), "function_result")

  # Verify: Check persistence
  vars <- stamp_variables()
  expect_equal(vars$test_func(), "function_result")
})

test_that("stamp_variables_add(): overwrites existing variable", {
  # Setup: Ensure clean state
  old_options <- options(filestamp.variables = NULL)
  on.exit(options(old_options), add = TRUE)

  # Add initial variable
  stamp_variables_add("test_var", "initial_value")

  # Execute: Overwrite variable
  result <- stamp_variables_add("test_var", "new_value")

  # Verify: Check result
  expect_equal(result$test_var, "new_value")

  # Verify: Check persistence
  vars <- stamp_variables()
  expect_equal(vars$test_var, "new_value")
})

# Test stamp_variables_list() ----

test_that("stamp_variables_list(): returns all variable names", {
  # Setup: Ensure clean state
  old_options <- options(filestamp.variables = NULL)
  on.exit(options(old_options), add = TRUE)

  # Add custom variables
  stamp_variables_add("test_var1", "value1")
  stamp_variables_add("test_var2", "value2")

  # Execute: List variables
  var_list <- stamp_variables_list()

  # Verify: Check built-in variables
  expect_true("cwd" %in% var_list)
  expect_true("date" %in% var_list)
  expect_true("year" %in% var_list)

  # Verify: Check custom variables
  expect_true("test_var1" %in% var_list)
  expect_true("test_var2" %in% var_list)
})

# Test built-in variables functionality ----

test_that("cwd variable returns working directory", {
  # Setup: Get variables
  vars <- stamp_variables()

  # Execute and verify
  expect_equal(vars$cwd(), getwd())
})

test_that("file_ext variable returns file extension", {
  # Setup: Get variables
  vars <- stamp_variables()

  # Set up file variable in parent frame
  file <- "test_file.txt"

  # Execute and verify
  expect_equal(vars$file_ext(), "txt")

  # Test with different extension
  file <- "script.R"
  expect_equal(vars$file_ext(), "R")
})

test_that("filename variable returns file basename", {
  # Setup: Get variables
  vars <- stamp_variables()

  # Set up file variable in parent frame
  file <- "path/to/test_file.txt"

  # Execute and verify
  expect_equal(vars$filename(), "test_file.txt")

  # Test with simple filename
  file <- "script.R"
  expect_equal(vars$filename(), "script.R")
})

test_that("date variables return correct format", {
  # Setup: Get variables
  vars <- stamp_variables()

  # Execute and verify date
  expect_equal(vars$date(), format(Sys.time(), "%Y-%m-%d"))

  # Execute and verify date_full
  expect_equal(vars$date_full(), format(Sys.time(), "%Y-%m-%d %H:%M:%S"))

  # Execute and verify year
  expect_equal(vars$year(), format(Sys.time(), "%Y"))
})

test_that("company variable returns option or default", {
  # Setup: Get variables
  vars <- stamp_variables()

  # Test default
  old_options <- options(filestamp.company = NULL)
  on.exit(options(old_options), add = TRUE)

  expect_equal(vars$company(), "Your Company")

  # Test custom
  options(filestamp.company = "Test Company")
  expect_equal(vars$company(), "Test Company")
})

test_that("user variable returns system username", {
  # Setup: Get variables
  vars <- stamp_variables()

  # Execute and verify
  withr::with_envvar(c("USER" = "TestUser"), {
    expect_equal(vars$user(), "TestUser")
  })
})
