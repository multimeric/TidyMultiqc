# Tests for the stat_ functions

test_that("the Q30 function works", {
  expect_equal(
    stat_q30(c(20, 30, 30, 40)),
    0.75
  )
})
