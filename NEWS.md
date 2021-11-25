# Release 1.0.0

## Breaking Changes

* Removed the `plot_opts` key from the `load_multiqc` function. Instead, the plots are returns as list columns ie nested data frames inside the returned data frame. Users are then able to parse out summary statistics using normal `dplyr` and `tidyr` functions. Refer to the vignettes for examples.
* Renamed "plots" to "plot" in the `sections` argument. This ensures consistency with the data frame column names for plots, which are "plot.XX"

## New Features

* Add `list_plots()` utility function for listing the available plots
* Add `parsers` argument to `load_multiqc` which allows for custom parsers for diverse plot types in multiqc
* Add pkgdown website
* Add GitHub repository and issue tracker to package metadata [#1](https://github.com/multimeric/TidyMultiqc/issues/1)

## Bug fixes

* Fix errors when the data frame contains no data (for example because you only requested a single plot which isn't present) [#2](https://github.com/multimeric/TidyMultiqc/issues/2)