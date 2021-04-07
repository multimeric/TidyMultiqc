# Tests for the 1000 genomes test files

test_that("We can parse the general section", {
  report <- load_multiqc(system.file("extdata", "HG00096/multiqc_data.json", package = "TidyMultiqc"), sections = "general")

  expect_s3_class(report, "tbl")
  expect_s3_class(report, "data.frame")
  expect_equal(nrow(report), 1)
  expect_equal(ncol(report), 6)
  expect_true("metadata.sample_id" %in% colnames(report))
  expect_equal(report[[1, "metadata.sample_id"]], "HG00096.mapped.ILLUMINA.bwa.GBR.low_coverage.20101123")
})


test_that("We can parse the raw section", {
  report <- load_multiqc(system.file("extdata", "HG00096/multiqc_data.json", package = "TidyMultiqc"), sections = "raw")
  # Check that we have the "raw" prefix
  expect_true(all(c(
    "raw.fastqc.per_base_sequence_quality",
    "raw.fastqc.sequences_flagged_as_poor_quality",
    "raw.fastqc.%gc"
  ) %in% colnames(report)))
  expect_s3_class(report, "tbl")
  expect_s3_class(report, "data.frame")
  expect_equal(nrow(report), 1)
  expect_equal(ncol(report), 26)
  expect_true("metadata.sample_id" %in% colnames(report))
})

test_that("the `extract_histogram` extractor works", {
  # The "fastqc_per_sequence_quality_scores_plot" plots the read quality against
  # the number of reads with that average score, so we have to treat it has
  # "histogram" data by replicating the quality score `count` times
  report <- load_multiqc(
    system.file("extdata", "HG00096/multiqc_data.json", package = "TidyMultiqc"),
    sections = "plots",
    plot_opts = list(
      `fastqc_per_sequence_quality_scores_plot` = list(
        extractor = extract_histogram,
        summary = list(mean = mean),
        prefix = "quality"
      )
    )
  )

  # We only have one sample
  expect_equal(nrow(report), 1)
  # We only extracted one statistic from one plot, plus the sample name
  expect_equal(ncol(report), 2)
  # The column should have been renamed
  expect_true("plot.quality.mean" %in% colnames(report))
  # We want the right result
  expect_equal(report[[1, "plot.quality.mean"]], 32, tolerance = 0.5)
})

test_that("the `extract_ignore_x` extractor works", {
  # The "fastqc_per_base_sequence_quality_plot" plots the read position against
  # the mean quality score at that position, so if we just ignore the position
  # we can calculate the overall mean quality score

  report <- load_multiqc(
    system.file("extdata", "HG00096/multiqc_data.json", package = "TidyMultiqc"),
    sections = "plots",
    plot_opts = list(
      `fastqc_per_base_sequence_quality_plot` = list(
        extractor = extract_ignore_x,
        summary = list(mean = mean),
        prefix = "quality"
      )
    )
  )

  # We only have one sample
  expect_equal(nrow(report), 1)
  # We only extracted one statistic from one plot, plus the sample name
  expect_equal(ncol(report), 2)
  # The column should have been renamed
  expect_true("plot.quality.mean" %in% colnames(report))
  # We want the right result
  expect_equal(report[[1, "plot.quality.mean"]], 32.4, tolerance = 0.5)
})


test_that("We can enable all sections at once", {
  # The "fastqc_per_base_sequence_quality_plot" plots the read position against
  # the mean quality score at that position, so if we just ignore the position
  # we can calculate the overall mean quality score

  report <- load_multiqc(
    system.file("extdata", "HG00096/multiqc_data.json", package = "TidyMultiqc"),
    sections = c("plots", "general", "raw"),
    plot_opts = list(
      `fastqc_per_base_sequence_quality_plot` = list(
        extractor = extract_ignore_x,
        summary = list(mean = mean),
        prefix = "quality"
      )
    )
  )

  # We only have one sample
  expect_equal(nrow(report), 1)
  expect_equal(ncol(report), 32)
  # The column should have been renamed
  expect_true("plot.quality.mean" %in% colnames(report))
  # We want the right result
  expect_equal(report[[1, "plot.quality.mean"]], 32.4, tolerance = 0.5)
})
