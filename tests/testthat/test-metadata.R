test_that("metadata is parsed correctly", {
  report <- load_multiqc(
    system.file("extdata", "wgs/multiqc_data.json", package = "TidyMultiqc"),
    sections = "general",
    find_metadata = function(sample, parsed) {
      # Split the sample ID to obtain some metadata
      segments <- stringr::str_split(sample, "_")[[1]]
      list(
        batch = segments[[1]],
        sample = segments[[2]]
      )
    }
  )

  expect_equal(nrow(report), 6)
  expect_true("metadata.batch" %in% colnames(report))
  expect_true("metadata.sample" %in% colnames(report))

  # The metadata should be sorted to the start, and general to the end
  expect_true(colnames(report[, 1]) %>% stringr::str_starts("metadata"))
  expect_true(report %>% dplyr::select(last_col()) %>% colnames() %>% stringr::str_starts("general"))

  # We now always put the sample ID first
  expect_equal(colnames(report[, 1]), "metadata.sample_id")

  expect_equal(report$metadata.batch %>% unique(), "P4107")
  expect_equal(report$metadata.sample %>% sort(), c("1001", "1002", "1003", "1004", "1005", "1006"))
})
