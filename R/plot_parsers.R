#' Takes the JSON dictionary for an xyline plot, and returns a named list of
#' data frames, one for each sample.
#' @keywords internal
#' @import rlang
#' @keywords plot_parser
#' @return A list of data frames, one for each sample.
#' Each data frame will have two columns: x, and y.
#' These correspond to the x and y coordinates in the plot.
#' For example, for histogram data, the x values are values of the random
#' variable, and the y values are the number of counts for that value.
parse_xyline_plot <- function(plot_data, name) {
  # This only works on xyline plots
  assertthat::assert_that(plot_data$plot_type == "xy_line")

  plot_data$datasets %>%
    purrr::map(function(dataset) {
      # For some reason there are two levels of nesting here
      dataset %>%
        kv_map(function(subdataset) {
          name <- stringr::str_c("plot", name, sep = ".")
          list(
            key = subdataset$name,
            value = subdataset$data %>%
              purrr::map_dfr(~ list(x = .[[1]], y = .[[2]])) %>%
              # Chop the multi-row data frame into one row
              tidyr::nest({{ name }} := tidyr::everything()) # %>%
          )
        })
    }) %>%
    purrr::reduce(~ purrr::list_merge(.x, !!!.y))
}

#' Takes the JSON dictionary for a bar graph, and returns a named list of
#' data frames, one for each sample.
#' @keywords internal
#' @import rlang
#' @keywords plot_parser
#' @return A list of data frames, one for each sample.
#' Each data frame will have one column corresponding to each category in the bar chart.
#' For example, for the plot "SnpEff: Counts by Genomic Region", we will have
#' one column for the number of intron variants, one column for the number of exon variants, etc.
#' This means that the number of columns will be fairly variable for different plots.
parse_bar_graph <- function(plot_data, name) {
  # This only works on bar_graphs
  assertthat::assert_that(plot_data$plot_type == "bar_graph")

  # Make a list of samples
  samples <- plot_data$samples[[1]] %>% purrr::flatten_chr()

  colname <- stringr::str_c("plot", sanitise_column_name(name), sep = ".")

  plot_data$datasets[[1]] %>%
    # First, build up a dictionary of samples -> dictionary of quality metrics
    purrr::map(function(dataset) {
      segment_name <- dataset$name
      dataset$data %>%
        # For this segment, each sample has a value
        kv_map(function(value, idx) {
          list(
            key = samples[[idx]],
            value = list(value) %>% purrr::set_names(sanitise_column_name(segment_name))
          )
        }, map_keys = TRUE)
    }) %>%
    purrr::reduce(utils::modifyList) %>%
    # Then, convert each inner dictionary to a tibble row
    purrr::map(tibble::as_tibble_row) %>%
    # And nest each df so that we only have 1 cell of output per sample
    purrr::map(~ tidyr::nest(., {{ colname }} := tidyr::everything()))
}
