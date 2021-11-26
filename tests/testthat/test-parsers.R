test_that("We can provide custom plot parsers", {
  report <- load_multiqc(
    system.file("extdata", "wgs/multiqc_data.json", package = "TidyMultiqc"),
    sections = "plot",
    plots = "fastqc_per_sequence_quality_scores_plot",
    plot_parsers = list(
      # This fake parser function takes a plot and just returns the iris dataset
      xy_line = function(plot_data, name) {
        list(
          sample_1 = list(
            plot_name = list(iris)
          )
        )
      }
    )
  )

  report$plot_name %>%
    purrr::map(~ expect_equal(., iris))
})
