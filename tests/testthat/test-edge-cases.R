test_that("The package can handle general stats with different lengths", {
  df = load_multiqc(
    paths = system.file("extdata", "general_list/multiqc_data.json", package = "TidyMultiqc"),
    sections = c("general", "raw")
  )

  expect_equal(length(df$general.salmon_version[[1]]), 1)
  expect_equal(length(df$general.length_classes[[1]]), 5)
  expect_equal(length(df$general.eq_class_properties[[1]]), 2)
})

test_that("The package works when no data is returned", {
  report <- load_multiqc(
    paths = system.file("extdata", "wgs/multiqc_data.json", package = "TidyMultiqc"),
    sections = NULL
  )

  # In this case we should output an empty tibble
  expect_equal(report, dplyr::tibble())
})

test_that("The package throws a reasonable error when no plots are provided", {
  testthat::expect_error(
    load_multiqc(
      paths = system.file("extdata", "wgs/multiqc_data.json", package = "TidyMultiqc"),
      sections = "plot"
    ),
    regexp = "one or more plots"
  )
})
