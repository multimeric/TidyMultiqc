#' TidyMultiqc: Converting MultiQC reports into tidy data frames
#' @description This package provides the means to convert `multiqc_data.json`
#' files, produced by the wonderful [MultiQC](http://multiqc.info/) tool,
#' into tidy data.frames for downstream analysis in R.
#' If you are reading this manual, you should immediately stop reading this and
#' instead refer to the documentation website at <https://multimeric.github.io/TidyMultiqc/>, which
#' provides more accessible documentation.
#' @importFrom magrittr `%>%`
#' @docType package
#' @name TidyMultiqc-package
NULL

# Make R CMD Check hush
utils::globalVariables(c(".", "metadata.sample_id"))

#' Parses the "general_stats_data" section
#' @param parsed The full parsed multiqc JSON file
#' @return A list of samples, each of which has a list of metricsx
#' @keywords internal
#' @noRd
parse_general <- function(parsed) {
  parsed$report_general_stats_data %>%
    purrr::map(function(inner) {
      inner %>% purrr::imap(function(sample_data, sample) {
        sample_data %>% kv_map(function(mvalue, mname) {
          list(
            # Add the "general" prefix here for general stats
            key = stringr::str_c("general", sanitise_column_name(mname), sep = "."),
            value = mvalue
          )
        }, map_keys = TRUE)
      })
    }) %>%
    purrr::reduce(~ purrr::list_merge(.x, !!!.y))
}

#' Parses the "report_saved_raw_data" section
#'
#' @param parsed The full parsed multiqc JSON file
#'
#' @return A list of samples, each of which has a list of metrics
#' @keywords internal
#' @noRd
parse_raw <- function(parsed) {
  # For each tool
  parsed$report_saved_raw_data %>%
    purrr::imap(function(samples, tool) {
      # Remove the superflous "multiqc_" from the start of the tool name
      tool <- stringr::str_remove(tool, "multiqc_")

      # For each sample
      samples %>% kv_map(function(metrics, sample) {
        # For each metric in the above tool
        list(
          key = sample,
          value = metrics %>% kv_map(function(mvalue, mname) {
            # Sanitise metric names
            mname <- stringr::str_split(mname, "-")[[1]] %>% dplyr::last()
            combined_metric <-
              list(
                # Add the "raw" prefix here for raw stats
                key = stringr::str_c("raw", sanitise_column_name(tool), sanitise_column_name(mname), sep = "."),
                value = mvalue
              )
          }, map_keys = TRUE)
        )
      }, map_keys = TRUE)
    }) %>%
    purrr::reduce(utils::modifyList)
}

#' Parses metadata using a user-supplied function
#'
#' @param parsed The parsed multiqc.json
#' @param samples A list of known sample names
#' @keywords internal
#' @noRd
parse_metadata <- function(parsed, samples, find_metadata) {
  samples %>%
    kv_map(function(sample) {
      # Find metadata using a user-defined function
      metadata <- find_metadata(sample, parsed)

      if (length(metadata) > 0) {
        metadata <- metadata %>% purrr::set_names(function(name) {
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
#' @param paths A string vector of filepaths to multiqc_data.json files
#' @param find_metadata A single function that will be called with a sample name and the
#' parsed JSON for the entire report and returns a named list of metadata fields for the sample.
#' Refer to the vignette for an example.
#' @param sections A string vector of zero or more sections to include in the output.
#' Each section can be:
#' \describe{
#' \item{"plot"}{Parse plot data. Note that you should also provide a list of plots via the `plots` argument}
#' \item{"general"}{parse the general stat section}
#' \item{"raw"}{Parse the raw data section}
#' }
#' This defaults to 'general', which tends to contain the most useful statistics
#' @param plots A string vector, each of which contains the ID of a plot you
#' want to include in the output. You can use [TidyMultiqc::list_plots()] to help here.
#' @param plot_parsers **Advanced**. A named list of custom parser functions.
#' The names of the list should correspond to plotly plot types, such as "xy_line", and the values should be functions
#' that return a named list of named lists. For the return value, the outer list is named by the sample ID, and the inner list
#' is named by the name of the column. Refer to the source code for some examples.
#' @export
#' @return A tibble (data.frame subclass) with QC data and metadata as columns, and samples as rows.
#' Columns are named according to the respective section they belong to,
#' and will always be listed in the following order:
#' \item{`metadata.X`}{This column contains metadata for this sample.
#' By default this is only the sample ID, but if you have provided the
#' `find_metadata` argument, there may be more columns.}
#' \item{`general.X`}{This column contains a generally useful summary statistic for each sample}
#' \item{`plot.X`}{This column contains a data frame of plot data for each sample.
#' Refer to the plot parsers documentation (ie the `parse_X` functions) for more information on the output format. }
#' \item{`raw.X`}{This column contains a raw summary statistic or value relating to each sample }
#' @seealso [TidyMultiqc::parse_xyline_plot()] [TidyMultiqc::parse_bar_graph()]
#' @examples
#' load_multiqc(system.file("extdata", "wgs/multiqc_data.json", package = "TidyMultiqc"))
load_multiqc <- function(paths,
                         plots = NULL,
                         find_metadata = function(...) {
                           list()
                         },
                         plot_parsers = list(),
                         sections = "general") {
  assertthat::assert_that(all(sections %in% c(
    "general", "plot", "raw"
  )), msg = "Only 'general', 'plot' and 'raw' (and combinations of those) are valid items for the sections parameter")

  # Vectorised over paths
  paths %>%
    purrr::map_dfr(function(path) {
      parsed <- jsonlite::read_json(path)

      # The main data is plots/general/raw
      main_data <- sections %>%
        purrr::map(~ switch(.,
          general = parse_general(parsed),
          raw = parse_raw(parsed),
          plot = parse_plots(parsed, plots = plots, plot_parsers = plot_parsers)
        )) %>%
        purrr::reduce(~ purrr::list_merge(.x, !!!.y), .init = list()) %>%
        purrr::imap(~ purrr::list_merge(.x, metadata.sample_id = .y))

      # Metadata is defined by a user function
      metadata <- parse_metadata(parsed = parsed, samples = names(main_data), find_metadata = find_metadata)
      purrr::list_merge(metadata, !!!main_data) %>%
        dplyr::bind_rows()
    }) %>%
    # Only arrange the columns if we have at least 1 column
    `if`(
      # Move the columns into the order: metadata, general, plot, raw
      ncol(.) > 0,
      (.) %>%
        dplyr::relocate(dplyr::starts_with("raw")) %>%
        dplyr::relocate(dplyr::starts_with("plot")) %>%
        dplyr::relocate(dplyr::starts_with("general")) %>%
        dplyr::relocate(dplyr::starts_with("metadata")) %>%
        # Always put the sample ID at the start
        dplyr::relocate(metadata.sample_id),
      .
    )
}
