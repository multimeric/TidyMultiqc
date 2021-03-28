# Tests for single plot types

test_that("we can extract bar graphs", {
  # The "fastqc_per_base_sequence_quality_plot" plots the read position against
  # the mean quality score at that position, so if we just ignore the position
  # we can calculate the overall mean quality score
  report = jsonlite::read_json('snpeff_variant_effects_region.json') %>%
    parse_bar_graph(prefix = "effects") %>%
    dplyr::bind_rows()

  # We have 6 samples
  expect_equal(nrow(report), 6)
  # We have 13 types of region
  expect_equal(ncol(report), 13)
  # The regions should be correctly named
  expect_true('effects.None' %in% colnames(report))
  expect_true('effects.Downstream' %in% colnames(report))
  expect_true('effects.Exon' %in% colnames(report))
})
