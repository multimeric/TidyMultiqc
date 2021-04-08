#' TidyMultiqc: Converting MultiQC reports into tidy data frames
#' @description This package provides the means to convert `multiqc_data.json`
#' files, produced by the wonderful [MultiQC](http://multiqc.info/) tool,
#' into tidy data.frames for downstream analysis in R. This analysis might
#' involve cohort analysis, quality control visualisation, changepoint detection,
#' statistical process control, clustering, or any other type of quality analysis.
#' @section Core API:
#' The public API to this package
#' * [load_multiqc()]
#' @section Plot Extractor Functions:
#' These functions can be used as arguments to [load_multiqc()] to specify
#' how to extract data from MultiQC plots
#' * [extract_ignore_x()]
#' * [extract_xy()]
#' * [extract_histogram()]
#' @section Summary Functions:
#' These are also passed as arguments to [load_multiqc()].
#' In most cases you can use normal summary statistics like [base::mean()],
#' but these are some other useful ones you might want.
#' * [summary_q30()]
#' * [summary_extract_df()]
#' @importFrom magrittr `%>%`
#' @docType package
#' @name TidyMultiqc-package
NULL

#' Parses the "general_stats_data" section
#' @param parsed The full parsed multiqc JSON file
#' @return A list of samples, each of which has a list of metrics
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
#' @param paths A vector of filepaths to multiqc_data.json files
#' @param plot_opts A named list mapping the internal MultiQC plot name, e.g.
#' "fastqc_per_sequence_quality_scores_plot" to a list of options for that plot.
#' The list can have the following keys:
#' \describe{
#'   \item{extractor}{Mandatory for scatter/line plots, ignored for bar graphs.
#'   A function which converts the raw plot JSON into a some kind of data,
#'   usually a vector. Often you will want to use a built-in `extract_x`
#'   functions provided by this package}
#'   \item{summary}{A named list of functions that each map the output from
#'   the extractor function (usually a 1-D vector) to a scalar, to "summarise"
#'   it. For example, you might want to use the [base::mean()] function to
#'   summarise the plot. See also the `summary_x` functions in this package.}
#'   \item{prefix}{Optional. A new name for this plot. MultiQC sometimes has
#'   some unwieldy names for its plot, so this lets you rename them}
#' }
#' @param find_metadata A function that will be called with a sample name and the
#' parsed JSON and returns a named list of metadata fields for the sample
#' @param sections Vector of the sections to include in the output: 'plots'
#' in the list means parse plot data, 'general' means parse the general stats
#' section, and 'raw' means parse the raw data section. This defaults to
#' 'general', which tends to contain the most useful statistics
#' @export
#' @return A tibble (data.frame subclass) with QC data and metadata as columns, and samples as rows
#' @examples
#' load_multiqc(
#'   system.file("extdata", "wgs/multiqc_data.json", package = "TidyMultiqc"),
#'   sections = c("plots", "general", "raw"),
#'   plot_opts = list(
#'     fastqc_per_sequence_quality_scores_plot = list(
#'       summary = list(`%q30` = summary_q30),
#'       extractor = extract_histogram,
#'       prefix = "quality"
#'     )
#'   )
#' )
load_multiqc <- function(paths,
                         plot_opts = list(),
                         find_metadata = function(...) {
                           list()
                         },
                         sections = "general") {
  assertthat::assert_that(all(sections %in% c(
    "general", "plots", "raw"
  )), msg = "Only 'general', 'plots' and 'raw' (and combinations of those) are valid items for the sections parameter")

  # Vectorised over paths
  paths %>%
    purrr::map_dfr(function(path) {
      parsed <- jsonlite::read_json(path)

      # The main data is plots/general/raw
      main_data <- sections %>%
        purrr::map(~ switch(.,
          general = parse_general,
          raw = parse_raw,
          plots = purrr::partial(parse_plots, options = plot_opts)
        )(parsed)) %>%
        purrr::reduce(~ purrr::list_merge(.x, !!!.y), .init = list()) %>%
        purrr::imap(~ purrr::list_merge(.x, metadata.sample_id = .y))

      # Metadata is defined by a user function
      metadata <- parse_metadata(parsed = parsed, samples = names(main_data), find_metadata = find_metadata)

      purrr::list_merge(metadata, !!!main_data) %>%
        dplyr::bind_rows()
    }) %>%
    # Move the columns into the order: metadata, general, plots, raw
    dplyr::relocate(dplyr::starts_with("metadata")) %>%
    dplyr::relocate(dplyr::starts_with("raw"), .after = dplyr::last_col())
}
