test_that("The package works when no data is returned", {
  # This test passes if the following command doesn't fail
  report <- load_multiqc(
    paths = system.file("extdata", "wgs/multiqc_data.json", package = "TidyMultiqc"),
    sections = NULL
  )
})
