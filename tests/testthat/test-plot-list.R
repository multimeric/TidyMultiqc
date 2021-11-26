test_that("We can list plot IDs", {
  plots <- list_plots(system.file("extdata", "HG00096/multiqc_data.json", package = "TidyMultiqc"))
  expect_s3_class(plots, "tbl")
  # We have 6 plots
  expect_equal(nrow(plots), 6)
  # There are only ever 2 columns
  expect_equal(ncol(plots), 2)
  # Check column names
  expect_named(plots, c("id", "title"))
  # The id column should never contain spaces
  stringr::str_detect(plots$id, " ", negate = TRUE) %>%
    all() %>%
    expect_true()
  # The title column should never contain underscores (well it could, but that would be unusual)
  stringr::str_detect(plots$title, "_", negate = TRUE) %>%
    all() %>%
    expect_true()
})
