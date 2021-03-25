require('purrr')

#' Extractor function that ignores the x-axis and applies statistics over the
#' y-values
extract_ignore_x = function(data){
  purrr::map_dbl(
    data, function(point){
      if (length(point) == 1){
        point[[1]]
      }
      else if (length(point) == 2){
        point[[2]]
      }
      else {
        NaN
      }
    })
}

#' Extractor function that calculates statistics for a histogram
extract_histogram = function(data){
  flatten_dbl(purrr::map(data, function(datum){
    # If the histogram has the coordinate 10, 20 it means we have seen the
    # number 10, 20 times, so we duplicate it
    rep(datum[[1]], datum[[2]])
  }))
}

#' Returns a list of summary statistics for the provided plot data
#'
#' @param plot_data A list containing the keys $plot_type, $datasets and $config
#' @param type The name of this plot, e.g. "fastqc_per_base_n_content_plot"
#' @param extractor A function that purrr::maps the "data" array to a list of summary
#' statistics
#' @returns A list of samples, each containing a list of plots, each containing
#' a list of summary stats
plot_features = function(plot_data, plot_name, extractor, summary_stats){
  ret = list()

  switch (plot_data$plot_type,
          function(){},
          xy_line = function(){
            for (dataset in plot_data$datasets){
              for (subdataset in dataset){
                extracted = extractor(subdataset$data)
                stats = calc_summary_stats(extracted, summary_stats)
                # Add the plot type as a prefix to the stat
                names(stats) = str_c(plot_name, names(stats), sep='.')
                sample_name = sanitise_plot_name(subdataset$name)
                ret <<- ensure_key(ret, sample_name)
                ret[[sample_name]] <<- modifyList(ret[[sample_name]], stats)
              }
            }
          }
  )()

  ret
}

#' Parses the "report_saved_raw_data" section
#'
#' @param parsed The full parsed multiqc JSON file
#'
#' @return A list of samples, each of which has a list of metrics
parse_plots = function(parsed, options){

  # Plot data is more complex
  parsed$report_plot_data %>% imap(function(plot_data, plot_name){
    # Skip any plot not explicitly given an extractor, it's impossible to infer
    # what type of plot each is
    if (plot_name %in% names(options)){
      opts = options[[plot_name]]
      plot_features(plot_data, plot_name, extractor=opts$extractor, summary_stats=opts$summary_stats)
    }
  }) %>%
    discard(is.null) %>%
    flatten()
}
