#' Summary statistic for finding the Q30 of a dataset of quality scores
#' @export
stat_q30 = function(vec){
  cdf = as.cdf(vec)
  # We use just less than 30, because we want P(X >= 30) but 1 - CDF gives us
  # P(X > 30)
  1 - cdf(29.9999)
}

#' Extractor function that ignores the x-axis and applies statistics over the
#' y-values. For example this might be relevant for a mean per-base fastq
#' quality score. This will let you then calculate the overall mean quality of
#' the reads.
#' @export
extract_ignore_x <- function(data) {
  purrr::map_dbl(
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

#' Extractor function that calculates statistics for a histogram. For example
#' this might be relevant for the
#' @export
extract_histogram <- function(data, as_hist_dat=T) {
  df = unlist(data) %>% matrix(byrow=T, ncol=2)
  his = hist_dat(vals=df[, 1], counts = df[, 2])
  
  if (as_hist_dat){
    his
  }
  else {
    as.vector(his)
  }
}


#' Takes the JSON dictionary for an xyline plot, and returns a list of lists
#' of quality metrics
#' @keywords internal
parse_xyline_plot = function(
  plot_data,
  prefix,
  extractor,
  summary = list(mean=mean)
) {
  plot_data$datasets %>%
    purrr::map(function(dataset) {
      # For some reason there are two levels of nesting here
      dataset %>%
        kv_map(function(subdataset) {
          # Extract the data once
          extracted = extractor(subdataset$data)
          # And then apply each summary statistic over the extracted data
          stats = summary %>%
            kv_map(function(summariser, key){
              # We let the user rename this plot
              # Also, combine the plot name with the summary stat name
              new_key = str_c(prefix, key, sep='.')
              list(
                key=new_key,
                value = summariser(extracted)
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
#' @keywords internal
parse_bar_graph = function(
  plot_data,
  prefix,
  extractor,
  summary
){
  # This only works on bar_graphs
  assertthat::assert_that(plot_data$plot_type == 'bar_graph')

  # Make a list of samples
  samples = plot_data$samples[[1]] %>% flatten_chr()

  plot_data$datasets[[1]] %>%
    purrr::map(function(dataset){
      segment_name = dataset$name
      dataset$data %>%
        # For this segment, each sample has a value
        kv_map(function(value, idx){
          list(
            key=samples[[idx]],
            value=list(value) %>% set_names(str_c(prefix, segment_name, sep='.'))
          )
        }, map_keys = T)
    }) %>%
      purrr::reduce(modifyList)
}

#' Returns a list of summary statistics for a plotly plot, provided as a list
#' e.g. from jsonlite
#'
#' @param plot_data A list containing the keys $plot_type, $datasets and $config
#' @param extractor A function which converts the raw plot JSON into a vector
#' @param summary A function that maps a vector to a scalar
#' @param prefix The prefix for this plot type in the final data frame
#' @returns A list of samples, each containing a list of plots, each containing
#' a list of summary stats
#' @export
parse_plot_features <- function(
  plot_data,
  prefix,
  extractor=extract_ignore_x,
  summary=list(mean=mean)
) {
  assertthat::has_name(plot_data, 'datasets')
  assertthat::not_empty(names(summary))
  assertthat::is.string(prefix)
  assertthat::assert_that(is_callable(extractor))
  
  args = as.list(match.call())[-1]
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
#' @keywords internal
parse_plots <- function(parsed, options) {

  # Plot data is more complex
  parsed$report_plot_data %>%
    purrr::imap(function(plot_data, plot_name) {
      # Skip any plot not explicitly given an extractor, it's impossible to infer
      # what type of plot each is
      if (plot_name %in% names(options)) {
        opts = options[[plot_name]]
        # By default, we use the plot's name in the JSON as the prefix
        if (!'prefix' %in% names(opts)){
          opts$prefix = plot_name
        }
        exec(parse_plot_features, plot_data=plot_data, !!!opts)
      }
    }) %>%
    purrr::flatten() %>%
    purrr::discard(is.null)
}
