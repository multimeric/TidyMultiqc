# Summary statistics for plots

#' Summary statistic for finding the %Q30 of a dataset of quality scores
#' This is the proportion of total reads in a dataset that have a quality
#' score of 30 or above.
#' @param vec Either a [HistDat::HistDat-class] or a 1-D numeric vector
#' @return The %Q30 of the dataset, as a numeric of length 1
#' @export
summary_q30 <- function(vec) {
  cdf <- HistDat::as.ecdf(vec)
  # We use just less than 30, because we want P(X >= 30) but 1 - CDF gives us
  # P(X > 30)
  1 - cdf(29.9999)
}


#' Summary function that only works with the [extract_xy()] extractor.
#' Extracts a single point from the x,y data.frame by first selecting a row
#' and then returning the y value for that row
#' @param row_select An expression that will be pass through to
#' [dplyr::filter()]. This is a quoted argument so you can refer to the variables
#' `x` and `y`
#' @param df A data.frame with x and y columns. This is provided automatically
#' by the package and users don't need to provide this.
#' @param col A column name, either "x" or "y"
#' @return The value in a single cell of the data.frame
#' @export
summary_extract_df <- function(df, row_select, col = "y") {
  row_select <- rlang::enquo(row_select)
  df %>%
    dplyr::filter(!!row_select) %>%
    dplyr::pull(col)
}
