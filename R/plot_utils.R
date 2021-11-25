#' Given a plot list column for a histogram type plot,
#' converts into a list of HistDat objects,
#' which can then be used to efficiently calculate summary statistics
#'
#' @param list_col A list containing tibbles
#' @return A list of HistDat objects
#' @export
#' @examples
plot_to_histogram = function(list_col){
    purrr::map(list_col, ~HistDat::HistDat(vals = .$x, counts = .$y))
}

q30_statistic <- function(vec) {
  cdf <- HistDat::as.ecdf(vec)
  # We use just less than 30, because we want P(X >= 30) but 1 - CDF gives us
  # P(X > 30)
  1 - cdf(29.9999)
}