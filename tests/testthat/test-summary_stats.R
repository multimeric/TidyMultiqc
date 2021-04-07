# Tests for the summary_ functions

test_that("the Q30 function works", {
  expect_equal(
    summary_q30(c(20, 30, 30, 40)),
    0.75
  )
})


test_that("the summary_extract_df function works", {
  df <- bind_cols(
    x = 1:5,
    y = 1:5
  )
  expect_equal(
    summary_extract_df(df = df, row_select = x == 2),
    2
  )
})
