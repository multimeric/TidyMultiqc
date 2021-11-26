# Plot parsing functions

DEFAULT_PLOT_PARSERS <- list(
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
  parsers <- purrr::list_modify(DEFAULT_PLOT_PARSERS, !!!plot_parsers)

  # Plot data is more complex
  parsed$report_plot_data %>%
    purrr::imap(function(plot_data, plot_name) {
      # Skip any plot not explicitly in this list, it's impossible to infer
      # what type of plot each is
      if (plot_name %in% plots || is.null(plots)) {
        parser <- parsers[[plot_data$plot_type]]
        if (!is.null(parser)) {
          parser(plot_data = plot_data, name = plot_name)
        } else {
          warning(paste("No known (or provided) parser for a plot of type \"", plot_data$plot_type, "\""))
        }
      }
    }) %>%
    purrr::flatten() %>%
    purrr::discard(is.null)
}

#' List the plot identifiers of all the plots in a given multiqc report
#'
#' @details The main use for this function is finding the plot identifiers
#' that you will then pass into the `plots` argument of the [TidyMultiqc::load_multiqc()]
#' function.
#' Refer to the section on "Extracting Plot Data" in the main vignette for more information.
#' @param path The file path to the multiqc report. This should be a length 1
#' character vector
#' @return A data frame containing \eqn{n} rows, where \eqn{n} is the number
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
list_plots <- function(path) {
  jsonlite::read_json(path) %>%
    `$`("report_plot_data") %>%
    purrr::imap_dfr(function(plot, id) {
      list(
        id = id,
        title = plot$config$title
      )
    })
}
