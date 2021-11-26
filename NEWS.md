# Release 1.0.0

## Breaking Changes

* Removed the `plot_opts` key from the `load_multiqc` function. Instead, the plots are returns as list columns with nested data frames inside the returned data frame. Users are then able to parse out summary statistics using normal `dplyr` and `tidyr` functions. Refer to the vignettes for examples. [[#1]](https://github.com/multimeric/TidyMultiqc/issues/1). Also, instead of selecting plots using the names of this argument, they are selected using the new `plots` option (documented below)
* Renamed "plots" to "plot" in the `sections` argument. This ensures consistency with the data frame column names for plots, which are "plot.XX"
* `metadata.sample_id` is now always the first column in the data frame, even if you have provided a metadata function

## New Features

* Add `list_plots()` utility function for listing the available plots. [[#2]](https://github.com/multimeric/TidyMultiqc/issues/2)
* Add `plot_parsers` argument to `load_multiqc` which allows for custom parsers for diverse plot types in MultiQC
* Add `plots` argument to `load_multiqc`, which is a vector of plot identifiers to parse
* Add pkgdown website, which is available at <https://multimeric.github.io/TidyMultiqc/index.html>
* Add GitHub repository and issue tracker to package metadata [[#3]](https://github.com/multimeric/TidyMultiqc/issues/3)

## Bug fixes

* Fix errors when the data frame contains no data (for example because you only requested a single plot which isn't present) [[#2]](https://github.com/multimeric/TidyMultiqc/issues/2)