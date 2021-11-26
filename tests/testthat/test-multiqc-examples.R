# Tests for the MultiQC website reports

library(magrittr)
library(dplyr)

n_samples <- 6

test_that("We can read all sections of the MultiQC example WGS file", {
  # The "fastqc_per_base_sequence_quality_plot" plots the read position against
  # the mean quality score at that position, so if we just ignore the position
  # we can calculate the overall mean quality score

  report <- load_multiqc(
    system.file("extdata", "wgs/multiqc_data.json", package = "TidyMultiqc"),
    sections = c("plot", "general", "raw"),
    plots = "fastqc_per_sequence_quality_scores_plot"
  )

  # Sample IDs should be unique
  expect_equal(
    report$metadata.sample_id %>% unique() %>% length(),
    report$metadata.sample_id %>% length()
  )
  expect_equal(nrow(report), n_samples)
  expect_true(ncol(report) > 100)

  # Check for the plot list column
  expect_type(report$plot.fastqc_per_sequence_quality_scores_plot, "list")
  report$plot.fastqc_per_sequence_quality_scores_plot %>% purrr::map(function(df) {
    expect_equal(ncol(df), 2)
  })

  # The metadata should be sorted to the start, and raw to the end
  expect_true(colnames(report[, 1]) %>% stringr::str_starts("metadata"))
  expect_true(report %>% dplyr::select(last_col()) %>% colnames() %>% stringr::str_starts("raw"))
})


test_that("We can parse the general stats section", {
  report <- load_multiqc(
    system.file("extdata", "wgs/multiqc_data.json", package = "TidyMultiqc"),
    sections = "general"
  )

  expect_equal(nrow(report), n_samples)
  expect_true(ncol(report) > 100)
  expect_true(all(
    c(
      "general.avg_gc",
      "general.high",
      "general.3_prime_utr_variant",
      "general.sequence_feature",
      "general.intergenic",
      "general.insertions",
      "general.percent_gc"
    ) %in% colnames(report)
  ))
})

test_that("We can parse the qualimap coverage histogram", {
  report <- load_multiqc(
    system.file("extdata", "wgs/multiqc_data.json", package = "TidyMultiqc"),
    sections = "plot",
    plots = "qualimap_coverage_histogram"
  )

  expect_true("plot.qualimap_coverage_histogram" %in% colnames(report))

  # Check that we can easily extract the median, and that its value is roughly
  # where it should be
  expect_equal(
    report %>%
      filter(metadata.sample_id == "P4107_1001") %>%
      pull(plot.qualimap_coverage_histogram) %>%
      purrr::flatten_df() %>%
      {
        HistDat::HistDat(vals = .$x, counts = .$y)
      } %>%
      HistDat::median(),
    35,
    tolerance = 1
  )
  expect_equal(nrow(report), n_samples)
  expect_equal(ncol(dplyr::select(report, where(is.list))), 1)
})

test_that("We can parse the qualimap cumulative coverage histogram", {
  report <- load_multiqc(
    system.file("extdata", "wgs/multiqc_data.json", package = "TidyMultiqc"),
    sections = "plot",
    plots = "qualimap_genome_fraction"
  )

  expect_true("plot.qualimap_genome_fraction" %in% colnames(report))

  # This plot is already cumulative so instead of calculating the CDF
  # we just pull out the row corresponding to 30
  expect_equal(
    report %>%
      filter(metadata.sample_id == "P4107_1001") %>%
      pull("plot.qualimap_genome_fraction") %>%
      purrr::flatten_df() %>%
      dplyr::filter(x == 30) %>%
      dplyr::pull(y),
    74.66,
    tolerance = 0.01
  )
  expect_equal(nrow(report), n_samples)
  expect_equal(ncol(dplyr::select(report, where(is.list))), 1)
})

test_that("We can parse the snpeff bar chart", {
  report <- load_multiqc(
    system.file("extdata", "wgs/multiqc_data.json", package = "TidyMultiqc"),
    sections = "plot",
    plots = "snpeff_variant_effects_region"
  )

  expect_equal(nrow(report), n_samples)
  # Each plot is 1 column, plus the metadata
  expect_equal(ncol(report), 2)
  expect_true("plot.snpeff_variant_effects_region" %in% colnames(report))

  report <- tidyr::unnest(report, cols = plot.snpeff_variant_effects_region, names_sep = ".")

  # After unnesting, we have many more columns
  expect_equal(ncol(dplyr::select(report, where(is.numeric))), 13) # There are 13 regions reported in this plot
  expect_true(all(c(
    "plot.snpeff_variant_effects_region.exon",
    "plot.snpeff_variant_effects_region.utr_3_prime",
    "plot.snpeff_variant_effects_region.splice_site_acceptor"
  ) %in% colnames(report)))
  expect_equal(
    report %>% filter(metadata.sample_id == "P4107_1001") %>% pull("plot.snpeff_variant_effects_region.exon"),
    191454
  )
})
