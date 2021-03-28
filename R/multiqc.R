#' MultiqcAnalyse: A package for computating the notorious bar statistic
#'
#' The foo package provides three categories of important functions:
#' foo, bar and baz.
#'
#' @section Foo functions:
#' The foo functions ...
#' @importFrom magrittr `%>%`
#' @docType package
#' @name MultiqcAnalyse
NULL

#' Parses the "general_stats_data" section
#'
#' @param parsed The full parsed multiqc JSON file
#'
#' @return A list of samples, each of which has a list of metrics
#' @keywords internal
parse_general <- function(parsed) {
  parsed$report_general_stats_data %>%
    purrr::map(function(inner) {
      inner %>% purrr::imap(function(sample_data, sample) {
        sample_data %>% kv_map(function(mvalue, mname) {
          list(
            key = stringr::str_c("general", mname, sep = "."),
            value = mvalue
          )
        }, map_keys = T)
      })
    }) %>%
    purrr::reduce(~purrr::list_merge(.x, !!!.y))
}

#' Parses the "report_saved_raw_data" section
#'
#' @param parsed The full parsed multiqc JSON file
#'
#' @return A list of samples, each of which has a list of metrics
#' @keywords internal
parse_raw <- function(parsed) {
  # For each tool
  parsed$report_saved_raw_data %>% purrr::imap(function(samples, tool) {
    # For each sample
    samples %>% kv_map(function(metrics, sample) {
      # For each metric in the above tool
      list(
        key=sample,
        value = metrics %>% kv_map(function(mvalue, mname) {
        # Sanitise metric names
        mname <- stringr::str_split(mname, "-")[[1]] %>% dplyr::last()
        combined_metric <-
        list(
          key = stringr::str_c(tool, mname, sep = "."),
          value = mvalue
        )
      }, map_keys = T)
      )
    }, map_keys = T)
  }) %>% purrr::reduce(modifyList)
}


#' Parses metadata using a user-supplied function
#'
#' @param parsed The parsed multiqc.json
#' @param samples A list of known sample names
#' @keywords internal
parse_metadata <- function(parsed, samples, find_metadata) {
  samples %>%
    kv_map(function(sample) {
      # Find metadata using a user-defined function
      metadata = find_metadata(sample, parsed)

      if (length(metadata) > 0){
        metadata = metadata %>% purrr::set_names(function(name) {
            stringr::str_c("metadata", name, sep = ".")
        })
      }

      list(
        key = sample,
        value = metadata
      )
    })
}

#' Loads one or more MultiQCs report into a data frame
#'
#' @param path A vector of filepaths to multiqc_data.json files
#' @param plot_opts A list mapping the internal MultiQC plot name, e.g.
#' "fastqc_per_sequence_quality_scores_plot" to a list of options for that plot.
#' The list can have the following keys:
#' \describe{
#'   \item{$extractor}{Mandatory. A function which converts the raw plot JSON
#'   into a vector. Often you will want to use a built-in `extract_x`
#'   function provided by this package}
#'   \item{$summary}{A function that maps a vector to a scalar, to "summarise"
#'   it. For example, you might want to use the `mean` function}
#'   \item{$prefix}{A new name for this plot. MultiQC sometimes has some
#'   unwieldy names for its plot, so this lets you rename it}
#' }
#' @param find_metadata A function that will be called with a sample name and the
#' parsed JSON and returns a named list of metadata fields for the sample
#' @param sections List of the sections to include in the output: 'plots'
#' in the list means parse plot data, 'general' means parse the general stats
#' section, and 'raw' means parse the raw data section
#'
#' @export
#'
#' @return A tibble with QC data and metadata as columns, and samples as rows
load_multiqc <- function(paths,
                              plot_opts = list(),
                              find_metadata = function(...){ list() },
                              sections = "general") {

  # Vectorised over paths
  paths %>%
    purrr::map_dfr(function(path){
      parsed <- jsonlite::read_json(path)

      # The main data is plots/general/raw
      main_data = sections %>%
        purrr::map(~ switch(.,
                            general = parse_general,
                            raw = parse_raw,
                            plots = purrr::partial(parse_plots, options = plot_opts)
        )(parsed)) %>%
        purrr::reduce(~purrr::list_merge(.x, !!!.y), .init = list()) %>%
        purrr::imap(~ purrr::list_merge(.x, metadata.sample_id=.y))

      # Metadata is defined by a user function
      metadata = parse_metadata(parsed = parsed, samples = names(main_data), find_metadata = find_metadata)

      purrr::list_merge(main_data, !!!metadata) %>%
        dplyr::bind_rows()
    })
}
