# Internal plot parsing functions

#' Takes the JSON dictionary for an xyline plot, and returns a list of lists
#' of quality metrics
#' @keywords internal
#' @noRd
parse_xyline_plot <- function(plot_data,
                              prefix,
                              extractor,
                              summary = list(mean = mean)) {
  plot_data$datasets %>%
    purrr::map(function(dataset) {
      # For some reason there are two levels of nesting here
      dataset %>%
        kv_map(function(subdataset) {
          # Extract the data once
          extracted <- extractor(subdataset$data)
          # And then apply each summary statistic over the extracted data
          stats <- summary %>%
            kv_map(function(summariser, key) {
              # We let the user rename this plot
              # Also, combine the plot name with the summary stat name
              new_key <- stringr::str_c("plot", prefix, key, sep = ".")
              list(
                key = new_key,
                value = summariser(extracted)
              )
            }, map_keys = TRUE)
          list(
            key = subdataset$name,
            value = stats
          )
        })
    }) %>%
    purrr::reduce(~ purrr::list_merge(.x, !!!.y))
}

#' Takes the JSON dictionary for a bar graph, and returns a list of lists
#' of quality metrics
#' @keywords internal
#' @noRd
parse_bar_graph <- function(plot_data,
                            prefix,
                            extractor,
                            summary) {
  # This only works on bar_graphs
  assertthat::assert_that(plot_data$plot_type == "bar_graph")

  # Make a list of samples
  samples <- plot_data$samples[[1]] %>% purrr::flatten_chr()

  plot_data$datasets[[1]] %>%
    purrr::map(function(dataset) {
      segment_name <- dataset$name
      dataset$data %>%
        # For this segment, each sample has a value
        kv_map(function(value, idx) {
          list(
            key = samples[[idx]],
            value = list(value) %>% purrr::set_names(stringr::str_c("plot", sanitise_column_name(prefix), sanitise_column_name(segment_name), sep = "."))
          )
        }, map_keys = TRUE)
    }) %>%
    purrr::reduce(utils::modifyList)
}

#' Returns a list of summary statistics for a plotly plot, provided as a list
#' e.g. from jsonlite.
#' @details This is an internal function that may be of some use to
#' those who want to extract data from plotly JSON, outside of the context of
#' MultiQC. If you are trying to extract data from a MultiQC report, please
#' use the normal [load_multiqc()] function instead.
#' Please also refer to [load_multiqc()] for more information on these arguments, as
#' they are identical to the elements of the `plot_opts` list.
#' @param plot_data A list containing the names `plot_type`, `datasets` and
#' `config`.
#' @param extractor A function which converts the raw plot JSON into a vector
#' @param summary A function that maps a vector to a scalar
#' @param prefix The prefix for this plot type in the final data frame
#' @returns A list of samples, each containing a list of plots, each containing
#' a list of summary stats
#' @export
#' @examples
#' parse_plot_features(
#'   plot_data=jsonlite::read_json(
#'     system.file(
#'       "extdata", "wgs/multiqc_data.json", package = "TidyMultiqc"
#'     )
#'   )$report_plot_data$snpeff_effects,
#'   prefix='effects'
#' )
parse_plot_features <- function(plot_data,
                                prefix,
                                extractor = extract_ignore_x,
                                summary = list(mean = mean)) {
  assertthat::has_name(plot_data, "datasets")
  assertthat::not_empty(names(summary))
  assertthat::is.string(prefix)
  assertthat::assert_that(rlang::is_callable(extractor))

  args <- as.list(match.call())[-1]
  # Switch case to handle each plot type differently
  switch(plot_data$plot_type,
    # For unknown plots, do nothing
    function() {},
    xy_line = purrr::partial(parse_xyline_plot, !!!args),
    bar_graph = purrr::partial(parse_bar_graph, !!!args)
  )()
}

#' Parses the "report_saved_raw_data" section
#'
#' @param parsed The full parsed multiqc JSON file
#'
#' @return A list of samples, each of which has a list of metrics
#' @keywords internal
#' @noRd
parse_plots <- function(parsed, options) {

  # Plot data is more complex
  parsed$report_plot_data %>%
    purrr::imap(function(plot_data, plot_name) {
      # Skip any plot not explicitly in this list, it's impossible to infer
      # what type of plot each is
      if (plot_name %in% names(options)) {
        opts <- options[[plot_name]]
        # By default, we use the plot's name in the JSON as the prefix
        if (!"prefix" %in% names(opts)) {
          opts$prefix <- sanitise_column_name(plot_name)
        }
        rlang::exec(parse_plot_features, plot_data = plot_data, !!!opts)
      }
    }) %>%
    purrr::flatten() %>%
    purrr::discard(is.null)
}
