test_that("We can parse the general section", {
  report <- load_multiqc_file("HG00096/multiqc_data.json", sections = 'general')

  expect_s3_class(report, "tbl")
  expect_s3_class(report, "data.frame")
  expect_equal(nrow(report), 1)
  expect_equal(ncol(report), 6)
  expect_true('metadata.sample_id' %in% colnames(report))
  expect_equal(report[[1, 'metadata.sample_id']], 'HG00096.mapped.ILLUMINA.bwa.GBR.low_coverage.20101123')
})


test_that("We can parse the raw section", {
  report <- load_multiqc_file("HG00096/multiqc_data.json", sections='raw')
  expect_s3_class(report, "tbl")
  expect_s3_class(report, "data.frame")
  expect_equal(nrow(report), 1)
  expect_equal(ncol(report), 26)
  expect_true('metadata.sample_id' %in% colnames(report))
})

test_that("the `extract_histogram` extractor works", {
  # The "fastqc_per_sequence_quality_scores_plot" plots the read quality against
  # the number of reads with that average score, so we have to treat it has
  # "histogram" data by replicating the quality score `count` times
  report <- load_multiqc_file(
    "HG00096/multiqc_data.json",
    sections = "plots",
    plot_opts = list(
      `fastqc_per_sequence_quality_scores_plot` = list(
        extractor = extract_histogram,
        summary = list(mean=mean),
        prefix = "quality"
      )
    )
  )

  # We only have one sample
  expect_equal(nrow(report), 1)
  # We only extracted one statistic from one plot, plus the sample name
  expect_equal(ncol(report), 2)
  # The column should have been renamed
  expect_true('quality.mean' %in% colnames(report))
  # We want the right result
  expect_equal(report[[1, 'quality.mean']], 32, tolerance = 0.5)
})

test_that("the `extract_ignore_x` extractor works", {
  # The "fastqc_per_base_sequence_quality_plot" plots the read position against
  # the mean quality score at that position, so if we just ignore the position
  # we can calculate the overall mean quality score

  report <- load_multiqc_file(
    "HG00096/multiqc_data.json",
    sections = "plots",
    plot_opts = list(
      `fastqc_per_base_sequence_quality_plot` = list(
        extractor = extract_ignore_x,
        summary = list(mean=mean),
        prefix = "quality"
      )
    )
  )

  # We only have one sample
  expect_equal(nrow(report), 1)
  # We only extracted one statistic from one plot, plus the sample name
  expect_equal(ncol(report), 2)
  # The column should have been renamed
  expect_true('quality.mean' %in% colnames(report))
  # We want the right result
  expect_equal(report[[1, 'quality.mean']], 32.4, tolerance = 0.5)
})


test_that("we can extract bar graphs", {
  # The "fastqc_per_base_sequence_quality_plot" plots the read position against
  # the mean quality score at that position, so if we just ignore the position
  # we can calculate the overall mean quality score
  report = jsonlite::read_json('snpeff_variant_effects_region.json') %>%
    parse_bar_graph(prefix = "effects") %>%
    bind_rows()

  # We have 6 samples
  expect_equal(nrow(report), 6)
  # We have 13 types of region
  expect_equal(ncol(report), 13)
  # The regions should be correctly named
  expect_true('effects.None' %in% colnames(report))
  expect_true('effects.Downstream' %in% colnames(report))
  expect_true('effects.Exon' %in% colnames(report))
})

test_that("We can enable all sections at once", {
  # The "fastqc_per_base_sequence_quality_plot" plots the read position against
  # the mean quality score at that position, so if we just ignore the position
  # we can calculate the overall mean quality score

  report <- load_multiqc_file(
    "HG00096/multiqc_data.json",
    sections = c("plots", 'general', 'raw'),
    plot_opts = list(
      `fastqc_per_base_sequence_quality_plot` = list(
        extractor = extract_ignore_x,
        summary = list(mean=mean),
        prefix = "quality"
      )
    )
  )

  # We only have one sample
  expect_equal(nrow(report), 1)
  expect_equal(ncol(report), 32)
  # The column should have been renamed
  expect_true('quality.mean' %in% colnames(report))
  # We want the right result
  expect_equal(report[[1, 'quality.mean']], 32.4, tolerance = 0.5)
})