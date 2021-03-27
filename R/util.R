#' Maps over the keys and values of a vector, but expects the function to return
#' a named vector with "key" and "value" entries. These will become the names
#' and values of the final vector. Think of this as like a Python dictionary
#' comprehension: it takes an iterable and produces a dictionary.
#'
#' @param l a vector to map over
#' @param func the function to apply over that vector, which must return a `list(key=?, value=?)`
#' @param map_keys logical. If TRUE, then use `imap` which provides the keys as the second element to the function
#'
#' @examples
#' c(1, 2, 3) %>% kv_map(~ list(key = letters[[.]], value = .))
#' c(1, 2, 3) %>% kv_map(function(x) {
#'   list(key = letters[[x]], value = x)
#' })
#' c(a = 1, b = 2, c = 3) %>% kv_map(~ list(key = stringr::str_c(.y, "²"), value = .x), map_keys = T)
#' @keywords internal
kv_map <- function(l, func, map_keys = F) {
  mapper <- ifelse(map_keys, purrr::imap, purrr::map)
  mapped = mapper(l, func) %>% purrr::set_names(nm = NULL)
  keys = mapped %>% purrr::map_chr('key')
  vals = mapped %>% purrr::map('value')
  vals %>% purrr::set_names(keys)
}

sanitise_plot_name <- function(name) {
  stringr::str_split(name, " ")[[1]][[1]]
}
