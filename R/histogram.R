#' S3 class for histogram data
#'
#' @param mat Matrix of data, with values in column 1, and counts in column 2
#'
#' @return
#' @export
var = function(x){
  result = try(UseMethod('var'),  silent = T)
  if (is.null(result)){
    stats::var(x)
  }
  else{
    result
  }
}

hist_dat = function(vals, counts){
  structure(list(
    vals=vals,
    counts=counts
  ), class='hist_dat')
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
  num = sum((his$vals - mean(his)) * his$counts)^2
  denom = length(his) - 1
  num / denom
}
