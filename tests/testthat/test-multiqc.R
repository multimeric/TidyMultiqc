test_that("parsing a single report works", {
  report = load_multiqc_file('HG00096/multiqc_data.json')

  expect_s3_class(report, 'tbl')
  expect_s3_class(report, 'data.frame')
  expect_equal(nrow(report), 1)
  expect_equal(ncol(report), 5)
})

test_that("the `extract_histogram` extractor works", {
  report = load_multiqc_file(
    'HG00096/multiqc_data.json',
    sections = 'plots',
    plot_opts=list(
      `fastqc_per_sequence_quality_scores_plot` = list(
        extractor=extract_histogram,
        summary=mean
      )
    )
  )

  # We only have one sample
  expect_equal(nrow(report), 1)
  # We only extracted one statistic from one plot
  expect_equal(ncol(report), 1)
})

