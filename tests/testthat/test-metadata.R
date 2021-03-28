test_that("metadata is parsed correctly", {
  report <- load_multiqc(
    "wgs/multiqc_data.json",
    sections = 'general',
    find_metadata = function(sample, parsed){
      # Split the sample ID to obtain some metadata
      segments = stringr::str_split(sample, '_')[[1]]
      list(
        batch=segments[[1]],
        sample=segments[[2]]
      )
    }
  )

  expect_equal(nrow(report), 6)
  expect_true('metadata.batch' %in% colnames(report))
  expect_true('metadata.sample' %in% colnames(report))
  expect_equal(report$metadata.batch %>% unique, 'P4107')
  expect_equal(report$metadata.sample %>% sort, c('1001', '1002', '1003', '1004', '1005', '1006'))
})
