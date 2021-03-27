var <- function(x) UseMethod("var")
sd <- function(x) UseMethod("sd")
as.vector <- function(x) UseMethod("as.vector")
as.cdf <- function(x) UseMethod("as.cdf")

#' S3 class for histogram data
#'
#' @param mat Matrix of data, with values in column 1, and counts in column 2
#'
#' @return
#' @export
hist_dat = function(vals, counts){
  sorted = sort(vals, index.return=T)
  structure(rlang::new_environment(list(
    vals=sorted$x,
    counts=counts[sorted$ix]
  )), class='hist_dat')
}

sum.hist_dat = function(his, na.rm){
  sum(his$vals * his$counts)
}

length.hist_dat = function(his, na.rm){
  sum(his$counts)
}

mean.hist_dat = function(his){
  sum(his) / length(his)
}

var.hist_dat = function(his){
  num = sum((his$vals - mean(his))^2 * his$counts)
  denom = length(his) - 1
  num / denom 
}

min.hist_dat = function(his, na.rm){
  min(his$vals)
}

max.hist_dat = function(his, na.rm){
  max(his$vals)
}

median.hist_dat = function(his){
  cumul = 0
  middle = (length(his) + 1) / 2
  for (i in 1:length(his)){
    count = his$counts[[i]]
    val = his$vals[[i]]
    if (middle > cumul && middle < (cumul + count)){
      # If the middle index is within the current range, return the corresponding value
      return(val)
    }
    else if (middle == cumul + count + 0.5){
      # If the middle index is 0.5 outside of the current range, average this value and the next
      return(mean(his$vals[i:(i+1)]))
    }
    cumul = cumul + count
  }
}

range.hist_dat = function(his, ...){
  range(his$vals, ...)
}

quantile.hist_dat = function(his, ...){
  cdf = as.cdf(his)
  quantile(cdf, ...)
}

#' Convert this histogram to a vector. Not recommended if there are many counts
#' as this would result in an incredibly long vector
#'
#' @param his 
#'
#' @export
#'
as.vector.hist_dat = function(his, ...){
  rep(his$vals, his$counts)
}

#' Convert this histogram to an instance of the "ecdf" class, allowing the 
#' calculation of cumulative densities, and quantiles
#'
#' @param his 
#'
#' @export
#'
as.cdf.hist_dat = function(his){
  st = stepfun(
    x=his$vals,
    y=c(0, cumsum(his$counts))/length(his),
    right = F
  )
  class(st) = c('ecdf', class(st))
  assign("nobs", length(his), envir = environment(st))
  st
}

var.default = function(x, ...){
  stats::var(x)
}

as.cdf.default = function(x){
  ecdf(x)
}

as.vector.default = function(x){
  browser()
  base::as.vector(x)
}

sd.default = function(x, ...){
  sqrt(var(x))
}