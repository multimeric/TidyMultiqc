# Internal plot parsing functions

#' Takes the JSON dictionary for an xyline plot, and returns a named list of 
#' data frames, one for each sample. 
#' @keywords internal
#' @import rlang
#' @noRd
parse_xyline_plot <- function(plot_data, name) {
  # This only works on xyline plots
  assertthat::assert_that(plot_data$plot_type == "xy_line")
  
  plot_data$datasets %>%
    purrr::map(function(dataset) {
      # For some reason there are two levels of nesting here
      dataset %>%
        kv_map(function(subdataset) {
          name = stringr::str_c("plot", name, sep=".")
          list(
            key = subdataset$name,
            value = subdataset$data %>%
              purrr::map_dfr(~list(x=.[[1]], y=.[[2]])) %>%
              # Chop the multi-row data frame into one row
              tidyr::nest({{name}} := tidyr::everything()) #%>%
          )
        })
    }) %>%
    purrr::reduce(~ purrr::list_merge(.x, !!!.y))
}

#' Takes the JSON dictionary for a bar graph, and returns a named list of 
#' data frames, one for each sample. 
#' @keywords internal
#' @import rlang
#' @noRd
parse_bar_graph <- function(plot_data, name) {
  # This only works on bar_graphs
  assertthat::assert_that(plot_data$plot_type == "bar_graph")

  # Make a list of samples
  samples <- plot_data$samples[[1]] %>% purrr::flatten_chr()
  
  colname = stringr::str_c("plot", sanitise_column_name(name), sep = ".") 
  
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
    purrr::map(~tidyr::nest(., {{colname}} := tidyr::everything()))
}

DEFAULT_PLOT_PARSERS = list(
  xy_line = parse_xyline_plot,
  bar_graph = parse_bar_graph
)

#' Parses the "report_saved_raw_data" section
#' @param plots The vector of plots to parse, or NULL to parse all of them
#' @param parsed The full parsed multiqc JSON file
#'
#' @return A list of samples, each of which has a list of metrics
#' @keywords internal
#' @noRd
parse_plots <- function(parsed, plots, plot_parsers) {
  # Merge the default parsers with the user provided ones
  parsers = purrr::list_modify(DEFAULT_PLOT_PARSERS, !!!plot_parsers)

  # Plot data is more complex
  parsed$report_plot_data %>%
    purrr::imap(function(plot_data, plot_name) {
      # Skip any plot not explicitly in this list, it's impossible to infer
      # what type of plot each is
      if (plot_name %in% plots || is.null(plots)) {
        parser = parsers[[plot_data$plot_type]]
        if (!is.null(parser)){
          parser(plot_data = plot_data, name = plot_name)
        }
        else {
          warning(paste("No known (or provided) parser for a plot of type \"", plot_data$plot_type, "\""))
        }
      }
    }) %>%
    purrr::flatten() %>%
    purrr::discard(is.null)
}

#' List the plot identifiers of all the plots in a given multiqc report
#' 
#' @details This is a useful function, because the `plot_opts` list used in
#' the main `load_multiqc` function requires these identifiers as names. 
#' Refer to the "Plot Extraction" vignette for more information.
#' @param path The file path to the multiqc report. This should be a length 1
#' character vector
#' @return A data frame containing n rows, where n is the number
#' of plots in the report you have provided, and two columns:
#' \describe{
#' \item{id}{The identifier for the plot. This is the one you should use as a name in `plot_opts`.}
#' \item{name}{The plot title. This is likely what you see in the multiqc report when you open it with your browser.}
#' }
#' @export
#' @examples
#' # Ignore this, choose your own filepath as the `filepath` variable
#' filepath <- system.file("extdata", "HG00096/multiqc_data.json", package = "TidyMultiqc")
#' # This is the actual invocation
#' list_plots(filepath)
list_plots <- function(path){
  jsonlite::read_json(path) %>%
    `$`("report_plot_data") %>%
    purrr::imap_dfr(function(plot, id){
      list(
        id = id,
        title = plot$config$title
      )
    })
}
