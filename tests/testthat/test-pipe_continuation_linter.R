context("pipe_continuation_linter")

pipe_error <- rex(
  paste(
    "`%>%` should always have a space before it and a new line after it,",
    "unless the full pipeline fits on one line."
  ))

test_that("pipe-continuation correctly handles stand-alone expressions", {

  # Expressions without pipes are ignored
  expect_lint("blah", NULL, pipe_continuation_linter)

  # Pipe expressions on a single line are ignored
  expect_lint("foo %>% bar() %>% baz()", NULL, pipe_continuation_linter)

  # Pipe expressions spanning multiple lines with each expression on a line are ignored
  expect_lint("foo %>%\n  bar() %>%\n  baz()", NULL, pipe_continuation_linter)

  # Pipe expressions with multiple expression on a line are linted
  expect_lint("foo %>% bar() %>%\n  baz()", pipe_error,
    pipe_continuation_linter)

  expect_lint("foo %>% bar() %>% baz() %>%\n qux()",
    list(pipe_error),
    pipe_continuation_linter)
})

test_that("pipe-continuation linter correctly handles nesting", {

  valid_code <- c(
    # all on one line
    "my_fun <- function(){\n  a %>% b()\n}\n",
    "my_fun <- function(){\n  a %>% b() %>% c()\n}\n",
    "with(\n  diamonds,\n  x %>% head(10) %>% tail(5)\n)\n",
    "test_that('blah', {\n  test_data <- diamonds %>% head(10) %>% tail(5)\n})",

    # two different single-line pipelines
    "{\nx <- a %>% b %>% c\ny <- c %>% b %>% a \n}\n",

    # at most one pipe-character per line
    "my_fun <- function(){\n  a %>%\n    b() %>%\n    c()\n}\n"
  )

  for (code_string in valid_code) {
    expect_lint(code_string, NULL, pipe_continuation_linter)
  }

  expect_lint(
    "my_fun <- function(){\n  a %>% b() %>%\n    c()\n}\n",
    list(list(message=pipe_error, line_number=2L)),
    pipe_continuation_linter)

  expect_lint(
    "my_fun <- function(){\n  a %>%\n    b() %>% c()\n}\n",
    list(list(message=pipe_error, line_number=3L)),
    pipe_continuation_linter)
})
