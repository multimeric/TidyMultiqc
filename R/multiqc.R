require('jsonlite')
require('purrr')
require('stringr')
require('moments')
require('dplyr')
require('rlang')


#' Parses the "general_stats_data_ section
#'
#' @param parsed The full parsed multiqc JSON file
#'
#' @return A list of samples, each of which has a list of metrics
parse_general = function(parsed){
  parsed$report_general_stats_data %>%
    map(function(inner){
      inner %>% imap(function(sample_data, sample){
        sample_data %>% kv_map(function(mvalue, mname){
          list(
            key=str_c('general', mname, sep='.'),
            value=mvalue
          )
        }, map_keys = T)
      })
    }) %>% flatten()
}

#' Parses the "report_saved_raw_data" section
#'
#' @param parsed The full parsed multiqc JSON file
#'
#' @return A list of samples, each of which has a list of metrics
parse_raw = function(parsed){
  results = list()

  # For each tool
  imap(parsed$report_saved_raw_data, function(tool, samples){
    # For each sample
    imap(samples, function(sample, metrics){
      # Each sample has a sub-list
      results <<- ensure_key(results, sample)

      # For each metric in the above tool
      imap(metrics, function(mname, mvalue){
        # Sanitise metric names
        mname = last(str_split(mname, '-')[[1]])
        combined_metric = paste(tool, mname, sep='.')
        results[[sample]][[combined_metric]] <<- mvalue
      })
    })
  })

  results
}




#' Parses metadata using a user-supplied function
#'
#' @param parsed The parsed multiqc.json
#' @param samples A list of known sample names
#'
#' @return
#' @export
#'
#' @examples
parse_metadata = function(parsed, samples, find_metadata){
  results = list()
  for (sample in samples){
    results = ensure_key(results, sample)
    # Find metadata using a user-defined function
    metadata = find_metadata(sample, parsed)
    names(metadata) = str_c('metadata', names(metadata), sep='.')
    results[[sample]] = modifyList(results[[sample]], metadata)
  }
  results
}

#' Loads a MultiQC report into a data frame
#'
#' @param path The filepath of the multiqc_data.json
#' @param plot_opts A list mapping the internal MultiQC plot name, e.g.
#' "fastqc_per_sequence_quality_scores_plot" to a list of options for that plot.
#' The list can have the following keys:
#' \describe{
#'   \item{$extractor}{Mandatory. A function which converts the raw plot JSON
#'   into a vector. Often you will want to use a built-in `extract_x`
#'   function provided by this package}
#'   \item{$summary}{A function that maps a vector to a scalar, to "summarise"
#'   it. For example, you might want to use the `mean` function}
#'   \item{$rename}{A new name for this plot. MultiQC sometimes has some
#'   unwieldy names for its plot, so this lets you rename it}
#' }
#' @param find_metadata A function that will be called with a sample name and the
#' parsed JSON and returns a list of metadata fields for the sample
#' @param sections List of the sections to include in the output: 'plots'
#' in the list means parse plot data, 'general' means parse the general stats
#' section, and 'raw' means parse the raw data section
#'
#' @return A tibble with QC data and metadata as columns, and samples as rows
load_multiqc_file = function(
  path,
  plot_opts=list(),
  find_metadata=list,
  sections=c('general'),
){
  parsed = read_json(path)

  sections %>%
    map(~switch(.,
      general=parse_general,
      raw=parse_raw,
      plots=partial(parse_plots, extractors=plot_extractors, summary_stats=summary_stats)
    )(parsed)) %>%
      reduce(list_merge) %>%
      bind_rows()
}


#' Loads a collection of MultiQC JSON files
#'
#' @param paths A vector of paths to MultiQC JSON files
#' @param ... Args to pass to load_multiqc_file
#' @return A tibble, see load_multiqc_file
load_multiqc = function(paths, ...){
  purrr::map(paths, load_multiqc_file, ...) %>%
    flatten() %>%
    bind_rows()
}
