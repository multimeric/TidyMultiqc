
# TidyMultiqc

TidyMultiqc Provides the means to convert ‘multiqc\_data.json’ files,
produced by the wonderful ‘MultiQC’ tool, into tidy data frames for
downstream analysis in R.

**Please visit [the pkgdown
website](https://multimeric.github.io/TidyMultiqc/index.html) for a
comprehensive tutorial and function documentation.**

## Installation

The latest stable version can be installed from CRAN:

``` r
install.packages("TidyMultiqc")
```

You can also install the development version of TidyMultiqc from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("multimeric/TidyMultiqc")
```

## Example

``` r
TidyMultiqc::load_multiqc(multiqc_data_path)
#> # A tibble: 6 × 165
#>   metadata.sample_id general.total_reads general.mapped_reads general.percentag…
#>   <chr>                            <dbl>                <dbl>              <dbl>
#> 1 P4107_1003                   868204107            847562410               97.6
#> 2 P4107_1004                  1002828927            985115356               98.2
#> 3 P4107_1005                   974955793            955921317               98.0
#> 4 P4107_1002                   865975844            847067526               97.8
#> 5 P4107_1006                   912383669            894970438               98.1
#> 6 P4107_1001                   772071557            751147332               97.3
#> # … with 161 more variables: general.median_coverage <int>,
#> #   general.median_insert_size <int>, general.avg_gc <dbl>,
#> #   general.1_x_pc <dbl>, general.5_x_pc <dbl>, general.10_x_pc <dbl>,
#> #   general.30_x_pc <dbl>, general.50_x_pc <dbl>, general.genome <chr>,
#> #   general.number_of_variants_before_filter <dbl>,
#> #   general.number_of_known_variants_brie_non_empty_id <dbl>,
#> #   general.number_of_known_variants_brie_non_empty_id_percent <dbl>, …
```
