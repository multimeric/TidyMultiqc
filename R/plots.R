require("purrr")

#' Extractor function that ignores the x-axis and applies statistics over the
#' y-values
extract_ignore_x <- function(data) {
  map_dbl(
    data, function(point) {
      if (length(point) == 1) {
        point[[1]]
      }
      else if (length(point) == 2) {
        point[[2]]
      }
      else {
        NaN
      }
    }
  )
}

#' Extractor function that calculates statistics for a histogram
extract_histogram <- function(data) {
  flatten_dbl(purrr::map(data, function(datum) {
    # If the histogram has the coordinate 10, 20 it means we have seen the
    # number 10, 20 times, so we duplicate it
    rep(datum[[1]], datum[[2]])
  }))
}


#' Takes the JSON dictionary for an xyline plot, and returns a list of lists
#' of quality metrics
parse_xyline_plot = function(
  plot_data,
  plot_name,
  extractor,
  summary = list(mean=mean),
  rename = NULL
) {
  plot_data$datasets %>%
    map(function(dataset) {
      # For some reason there are two levels of nesting here
      dataset %>%
        kv_map(function(subdataset) {
          # Extract the data once
          exatracted = extractor(subdataset$data)
          # And then apply each summary statistic over the extracted data
          stats = summary %>%
            kv_map(function(summariser, key){
              # We let the user rename this plot
              # Also, combine the plot name with the summary stat name
              new_key = str_c(if_else(is.null(rename), plot_name, rename), key, sep='.')
              list(
                key=new_key,
                value = summariser(exatracted)
              )
            }, map_keys = T)
          list(
            key = sanitise_plot_name(subdataset$name),
            value = stats
          )
        })
    }) %>%
    purrr::flatten()
}

#' Takes the JSON dictionary for a bar graph, and returns a list of lists
#' of quality metrics
parse_bar_graph = function(
  plot_data,
  plot_name,
  extractor,
  summary = list(mean=mean),
  rename = NULL
){
  # This only works on bar_graphs
  assert_that(plot_data$plot_type == 'bar_graph')
  # Allow plot renaming
  plot_name = if_else(is.null(rename), plot_name, rename)
  # Make a list of samples
  samples = plot_data$samples[[1]] %>% flatten_chr()

  plot_data$datasets[[1]] %>%
    map(function(dataset){
      segment_name = dataset$name
      dataset$data %>%
        # For this segment, each sample has a value
        kv_map(function(value, idx){
          list(
            key=samples[[idx]],
            value=list(value) %>% set_names(str_c(plot_name, segment_name, sep='.'))
          )
        }, map_keys = T)
    }) %>% reduce(modifyList)
}

#' Returns a list of summary statistics for the provided plot data
#'
#' @param plot_data A list containing the keys $plot_type, $datasets and $config
#' @param type The name of this plot, e.g. "fastqc_per_base_n_content_plot"
#' @param extractor A function which converts the raw plot JSON into a vector
#' @param summary A function that maps a vector to a scalar
#' @param rename A new name for this plot
#' @returns A list of samples, each containing a list of plots, each containing
#' a list of summary stats
plot_features <- function(...) {
  args = list(...)
  # Switch case to handle each plot type differently
  switch(args$plot_data$plot_type,
    # For unknown plots, do nothing
    function() {},
    xy_line = partial(parse_xyline_plot, !!!args),
    bar_graph = partial(parse_bar_graph, !!!args)
  )()
}

#' Parses the "report_saved_raw_data" section
#'
#' @param parsed The full parsed multiqc JSON file
#'
#' @return A list of samples, each of which has a list of metrics
parse_plots <- function(parsed, options) {

  # Plot data is more complex
  parsed$report_plot_data %>%
    imap(function(plot_data, plot_name) {
      # Skip any plot not explicitly given an extractor, it's impossible to infer
      # what type of plot each is
      if (plot_name %in% names(options)) {
        exec(plot_features, plot_data=plot_data, plot_name=plot_name, !!!options[[plot_name]])
      }
    }) %>%
    purrr::flatten() %>%
    discard(is.null)
}
