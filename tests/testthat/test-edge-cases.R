test_that("The package works when no data is returned", {
  # This test passes if the following command doesn't fail
  report <- load_multiqc(
    paths = system.file("extdata", "wgs/multiqc_data.json", package = "TidyMultiqc"),
    sections = NULL
  )

  # In this case we should output an empty tibble
  expect_equal(report, dplyr::tibble())
})

test_that("The package throws a reasonable error when no plots are provided", {
  # This test passes if the following command doesn't fail
  testthat::expect_error(
    load_multiqc(
      paths = system.file("extdata", "wgs/multiqc_data.json", package = "TidyMultiqc"),
      sections = "plot"
    ),
    regexp = "one or more plots"
  )
})
