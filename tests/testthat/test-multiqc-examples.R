# Tests for the MultiQC website reports

test_that("We can read the MultiQC example WGS file", {
  # The "fastqc_per_base_sequence_quality_plot" plots the read position against
  # the mean quality score at that position, so if we just ignore the position
  # we can calculate the overall mean quality score

  report <- load_multiqc(
    "wgs/multiqc_data.json",
    sections = c("plots", 'general', 'raw'),
    plot_opts=list(
      fastqc_per_sequence_quality_scores_plot = list(
        summary=list(`%q30`=stat_q30),
        extractor=extract_histogram,
        prefix='quality'
      )
    )
  )

  # Sample IDs should be unique
  expect_equal(
    report$metadata.sample_id %>% unique %>% length,
    report$metadata.sample_id %>% length
  )
  expect_equal(nrow(report), 6)
  expect_true(ncol(report) > 100)
  expect_true('quality.%q30' %in% colnames(report))
})

test_that("We get the same number of rows with only general", {
  report <- load_multiqc(
    "wgs/multiqc_data.json",
    sections = 'general'
  )

  expect_equal(nrow(report), 6)
  expect_true(ncol(report) > 100)
})

test_that("We can read the MultiQC example WGS file, using load_multiqc", {
  report = load_multiqc(
    paths = "wgs/multiqc_data.json",
    sections = c("plots", 'general', 'raw'),
    plot_opts=list(
      fastqc_per_sequence_quality_scores_plot = list(
        summary=list(`%q30`=stat_q30),
        extractor=extract_histogram,
        prefix='quality'
      )
    )
  )

  # Expect the same results to above
  expect_equal(nrow(report), 6)
  expect_true(ncol(report) > 100)
  expect_true('quality.%q30' %in% colnames(report))
})
