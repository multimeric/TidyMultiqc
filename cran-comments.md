## Response to Submission Comments
> Please add \value to .Rd files regarding exported methods and explain
the functions results in the documentation. Please write about the
structure of the output (class) and also what the output means. (If a
function does not return a value, please document that too, e.g.
\value{No return value, called for side effects} or similar)
Missing Rd-tags:
      kv_map.Rd: \value
      parse_bar_graph.Rd: \arguments,  \value
      parse_metadata.Rd: \value
      parse_xyline_plot.Rd: \arguments,  \value
      sanitise_column_name.Rd: \arguments,  \value
      
These functions are not exported and were not intended to be included in the man files. 
This has now been fixed.

> Please write TRUE and FALSE instead of T and F.

Done.

> You have examples for unexported functions.
    kv_map() in:
       kv_map.Rd
  Please either omit these examples or export the functions.

> \dontrun{} should only be used if the example really cannot be executed
(e.g. because of missing additional software, missing API keys, ...) by
the user. That's why wrapping examples in \dontrun{} adds the comment
('# Not run:') as a warning for the user.
Does not seem necessary.

> Please unwrap the examples if they are executable in < 5 sec, or replace
\dontrun{} with \donttest{}.

As above, the `kv_map` function wasn't supposed to be a public function, so it is now excluded from the man files.

> If possible: Please add some more small executable examples in your
Rd-files to illustrate the use of the exported function but also enable
automatic testing.

Done. All exported functions now have at least one example.
```

## Test environments
* local R installation, R 4.0.3 on Ubuntu 18.04
* win-builder (release)

## R CMD check results

```
✓  checking for file ‘/media/michael/Storage2/Programming/multiqc/DESCRIPTION’ (354ms)
─  preparing ‘TidyMultiqc’: (19s)
✓  checking DESCRIPTION meta-information ...
─  installing the package to build vignettes
✓  creating vignettes (7.7s)
─  checking for LF line-endings in source and make files and shell scripts (833ms)
─  checking for empty or unneeded directories
─  building ‘TidyMultiqc_0.1.0.tar.gz’
   
── Checking ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── TidyMultiqc ──
Setting env vars:
● _R_CHECK_CRAN_INCOMING_USE_ASPELL_: TRUE
● _R_CHECK_CRAN_INCOMING_REMOTE_    : FALSE
● _R_CHECK_CRAN_INCOMING_           : FALSE
● _R_CHECK_FORCE_SUGGESTS_          : FALSE
● NOT_CRAN                          : true
── R CMD check ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
─  using log directory ‘/tmp/RtmpRf1AmT/TidyMultiqc.Rcheck’ (352ms)
─  using R version 4.0.3 (2020-10-10)
─  using platform: x86_64-conda-linux-gnu (64-bit)
─  using session charset: UTF-8
─  using options ‘--no-manual --as-cran’
✓  checking for file ‘TidyMultiqc/DESCRIPTION’
─  checking extension type ... Package
─  this is package ‘TidyMultiqc’ version ‘0.1.0’
─  package encoding: UTF-8
✓  checking package namespace information ...
✓  checking package dependencies (1.8s)
✓  checking if this is a source package ...
✓  checking if there is a namespace
✓  checking for executable files ...
✓  checking for hidden files and directories
✓  checking for portable file names
✓  checking for sufficient/correct file permissions ...
✓  checking serialization versions
✓  checking whether package ‘TidyMultiqc’ can be installed (2.2s)
✓  checking installed package size ...
✓  checking package directory ...
✓  checking for future file timestamps (1.3s)
✓  checking ‘build’ directory
✓  checking DESCRIPTION meta-information (338ms)
✓  checking top-level files
✓  checking for left-over files
✓  checking index information ...
✓  checking package subdirectories ...
✓  checking R files for non-ASCII characters ...
✓  checking R files for syntax errors ...
✓  checking whether the package can be loaded ...
✓  checking whether the package can be loaded with stated dependencies ...
✓  checking whether the package can be unloaded cleanly ...
✓  checking whether the namespace can be loaded with stated dependencies ...
✓  checking whether the namespace can be unloaded cleanly ...
✓  checking loading without being on the library search path ...
✓  checking dependencies in R code (731ms)
✓  checking S3 generic/method consistency (622ms)
✓  checking replacement functions ...
✓  checking foreign function calls ...
✓  checking R code for possible problems (2.9s)
✓  checking Rd files ...
✓  checking Rd metadata ...
✓  checking Rd line widths ...
✓  checking Rd cross-references ...
✓  checking for missing documentation entries ...
✓  checking for code/documentation mismatches (577ms)
✓  checking Rd \usage sections (859ms)
✓  checking Rd contents ...
✓  checking for unstated dependencies in examples ...
✓  checking installed files from ‘inst/doc’ ...
✓  checking files in ‘vignettes’ ...
✓  checking examples (3.2s)
✓  checking for unstated dependencies in ‘tests’ ...
─  checking tests ...
✓  Running ‘testthat.R’ (4.3s)
✓  checking for unstated dependencies in vignettes (4.6s)
✓  checking package vignettes in ‘inst/doc’ ...
✓  checking re-building of vignette outputs (5.2s)
✓  checking for non-standard things in the check directory
✓  checking for detritus in the temp directory
   
   
── R CMD check results ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── TidyMultiqc 0.1.0 ────
Duration: 29.8s

0 errors ✓ | 0 warnings ✓ | 0 notes ✓
```

## Winbuilder Results

```
* using log directory 'd:/RCompile/CRANguest/R-release/TidyMultiqc.Rcheck'
* using R version 4.0.5 (2021-03-31)
* using platform: x86_64-w64-mingw32 (64-bit)
* using session charset: ISO8859-1
* checking for file 'TidyMultiqc/DESCRIPTION' ... OK
* checking extension type ... Package
* this is package 'TidyMultiqc' version '0.1.0'
* package encoding: UTF-8
* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Michael Milton <michael.r.milton@gmail.com>'

New submission
* checking package namespace information ... OK
* checking package dependencies ... OK
* checking if this is a source package ... OK
* checking if there is a namespace ... OK
* checking for hidden files and directories ... OK
* checking for portable file names ... OK
* checking serialization versions ... OK
* checking whether package 'TidyMultiqc' can be installed ... OK
* checking installed package size ... OK
* checking package directory ... OK
* checking for future file timestamps ... OK
* checking 'build' directory ... OK
* checking DESCRIPTION meta-information ... OK
* checking top-level files ... OK
* checking for left-over files ... OK
* checking index information ... OK
* checking package subdirectories ... OK
* checking R files for non-ASCII characters ... OK
* checking R files for syntax errors ... OK
* loading checks for arch 'i386'
** checking whether the package can be loaded ... OK
** checking whether the package can be loaded with stated dependencies ... OK
** checking whether the package can be unloaded cleanly ... OK
** checking whether the namespace can be loaded with stated dependencies ... OK
** checking whether the namespace can be unloaded cleanly ... OK
** checking loading without being on the library search path ... OK
** checking use of S3 registration ... OK
* loading checks for arch 'x64'
** checking whether the package can be loaded ... OK
** checking whether the package can be loaded with stated dependencies ... OK
** checking whether the package can be unloaded cleanly ... OK
** checking whether the namespace can be loaded with stated dependencies ... OK
** checking whether the namespace can be unloaded cleanly ... OK
** checking loading without being on the library search path ... OK
** checking use of S3 registration ... OK
* checking dependencies in R code ... OK
* checking S3 generic/method consistency ... OK
* checking replacement functions ... OK
* checking foreign function calls ... OK
* checking R code for possible problems ... [4s] OK
* checking Rd files ... OK
* checking Rd metadata ... OK
* checking Rd line widths ... OK
* checking Rd cross-references ... OK
* checking for missing documentation entries ... OK
* checking for code/documentation mismatches ... OK
* checking Rd \usage sections ... OK
* checking Rd contents ... OK
* checking for unstated dependencies in examples ... OK
* checking installed files from 'inst/doc' ... OK
* checking files in 'vignettes' ... OK
* checking examples ...
** running examples for arch 'i386' ... [5s] OK
** running examples for arch 'x64' ... [6s] OK
* checking for unstated dependencies in 'tests' ... OK
* checking tests ...
** running tests for arch 'i386' ... [10s] OK
  Running 'testthat.R' [10s]
** running tests for arch 'x64' ... [11s] OK
  Running 'testthat.R' [10s]
* checking for unstated dependencies in vignettes ... OK
* checking package vignettes in 'inst/doc' ... OK
* checking re-building of vignette outputs ... [12s] OK
* checking PDF version of manual ... OK
* checking for detritus in the temp directory ... OK
* DONE
Status: 1 NOTE
```
