# Extractor functions

#' Extractor function that ignores the x-axis and applies statistics over the
#' y-values.
#' @details
#' For example this might be relevant for a mean per-base fastq
#' quality score. This will let you then calculate the overall mean quality of
#' the reads.
#' @param data Provided internally, users don't need to provide this.
#' @return A 1-D numeric vector of y-values from the plot
#' @export
#' @family extractors
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

#' Extractor function that extracts the (x, y) pairs in the plot and puts them
#' as columns in a data.frame, with colnames "x" and "y"
#' @details Since this extractor returns an entire data.frame, the extractor
#' function cannot use ordinary summary statistics like `mean`, `median` etc.
#' If you want to do that, look into the other extractors. Instead, you will
#' need summary functions that pull out a single value from the data.frame.
#' @export
#' @param data Provided internally, users don't need to provide this.
#' @return A tibble with the "x" column corresponding to the x-values in the
#' plot, and a "y" column corresponding to the y-values in the plot.
#' @family extractors
extract_xy = function(data){
  data %>%
    purrr::map(~purrr::set_names(., c("x", "y"))) %>%
    dplyr::bind_rows()
}

#' Extractor function that calculates statistics for a histogram.
#' @details For example this might be relevant for the "Coverage histogram" plot
#' from Qualimap. By default this returns a [HistDat::HistDat-class] instance,
#' which is compatible with most common summary statistics (`mean`, `quantile`, etc),
#' so your summary statistic functions can be ordinary R functions.
#' @export
#' @param data Provided internally, users don't need to provide this.
#' @param as_hist_dat If true return an instance of the
#' [HistDat::HistDat-class] class. Otherwise return a 1-D numeric vector.
#' Default true, as this is strongly recommended to avoid crashing the R
#' interpreter with large counts in the histogram.
#' @return A single [HistDat::HistDat-class] instance, or a 1-D numeric vector
#' @family extractors
extract_histogram <- function(data, as_hist_dat=T) {
  df = unlist(data) %>% matrix(byrow=T, ncol=2)
  his = HistDat::HistDat(vals=df[, 1], counts = df[, 2])

  if (as_hist_dat){
    his
  }
  else {
    HistDat::as.vector(his)
  }
}
