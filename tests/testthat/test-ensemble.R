# Tests for simultaneously loading multiple files from different sources

test_that("We can combine two multiqc reports with unrelated columns", {
  report = load_multiqc(
    paths = c("wgs/multiqc_data.json", "HG00096/multiqc_data.json"),
    sections='general'
  )

  # Sample IDs should be unique
  expect_equal(
    report$metadata.sample_id %>% unique %>% length,
    report$metadata.sample_id %>% length
  )
  expect_gt(ncol(report), 100)
  expect_equal(nrow(report), 6 + 1)
})
