## Test environments
* local R installation, R 4.0.3 on Ubuntu 18.04
* win-builder (release)

## R CMD check results

```
── Building ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── TidyMultiqc ──
Setting env vars:
● CFLAGS    : -Wall -pedantic -fdiagnostics-color=always
● CXXFLAGS  : -Wall -pedantic -fdiagnostics-color=always
● CXX11FLAGS: -Wall -pedantic -fdiagnostics-color=always
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
✓  checking for file ‘/media/michael/Storage2/Programming/multiqc/DESCRIPTION’ (353ms)
─  preparing ‘TidyMultiqc’: (1.1s)
✓  checking DESCRIPTION meta-information ...
─  installing the package to build vignettes
✓  creating vignettes (8.5s)
─  checking for LF line-endings in source and make files and shell scripts (904ms)
─  checking for empty or unneeded directories
─  building ‘TidyMultiqc_0.1.0.tar.gz’
   
── Checking ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── TidyMultiqc ──
Setting env vars:
● _R_CHECK_CRAN_INCOMING_USE_ASPELL_: TRUE
● _R_CHECK_CRAN_INCOMING_REMOTE_    : FALSE
● _R_CHECK_CRAN_INCOMING_           : FALSE
● _R_CHECK_FORCE_SUGGESTS_          : FALSE
● NOT_CRAN                          : true
── R CMD check ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
─  using log directory ‘/tmp/RtmpT3Jh3x/TidyMultiqc.Rcheck’ (373ms)
─  using R version 4.0.3 (2020-10-10)
─  using platform: x86_64-conda-linux-gnu (64-bit)
─  using session charset: UTF-8
─  using options ‘--no-manual --as-cran’
✓  checking for file ‘TidyMultiqc/DESCRIPTION’
─  checking extension type ... Package
─  this is package ‘TidyMultiqc’ version ‘0.1.0’
─  package encoding: UTF-8
✓  checking package namespace information
✓  checking package dependencies (1.6s)
✓  checking if this is a source package ...
✓  checking if there is a namespace
✓  checking for executable files ...
✓  checking for hidden files and directories
✓  checking for portable file names
✓  checking for sufficient/correct file permissions
✓  checking serialization versions
✓  checking whether package ‘TidyMultiqc’ can be installed (2.6s)
✓  checking installed package size ...
✓  checking package directory ...
✓  checking for future file timestamps (1.9s)
✓  checking ‘build’ directory
✓  checking DESCRIPTION meta-information ...
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
✓  checking loading without being on the library search path (353ms)
✓  checking dependencies in R code (802ms)
✓  checking S3 generic/method consistency (633ms)
✓  checking replacement functions ...
✓  checking foreign function calls ...
✓  checking R code for possible problems (3.2s)
✓  checking Rd files (360ms)
✓  checking Rd metadata ...
✓  checking Rd line widths ...
✓  checking Rd cross-references ...
✓  checking for missing documentation entries ...
✓  checking for code/documentation mismatches (611ms)
✓  checking Rd \usage sections (845ms)
✓  checking Rd contents ...
✓  checking for unstated dependencies in examples ...
✓  checking installed files from ‘inst/doc’ ...
✓  checking files in ‘vignettes’ ...
✓  checking examples (3s)
✓  checking for unstated dependencies in ‘tests’ ...
─  checking tests ...
✓  Running ‘testthat.R’ (4.9s)
✓  checking for unstated dependencies in vignettes (5.2s)
✓  checking package vignettes in ‘inst/doc’ ...
✓  checking re-building of vignette outputs (5.5s)
✓  checking for non-standard things in the check directory ...
✓  checking for detritus in the temp directory
   
   
── R CMD check results ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── TidyMultiqc 0.1.0 ────
Duration: 32.2s

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
