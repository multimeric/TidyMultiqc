% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_parsers.R
\name{parse_xyline_plot}
\alias{parse_xyline_plot}
\title{Takes the JSON dictionary for an xyline plot, and returns a named list of
data frames, one for each sample.}
\usage{
parse_xyline_plot(plot_data, name)
}
\value{
A list of data frames, one for each sample.
Each data frame will have two columns: x, and y.
These correspond to the x and y coordinates in the plot.
For example, for histogram data, the x values are values of the random
variable, and the y values are the number of counts for that value.
}
\description{
Takes the JSON dictionary for an xyline plot, and returns a named list of
data frames, one for each sample.
}
\keyword{internal}
\keyword{plot_parser}
