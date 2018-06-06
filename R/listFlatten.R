#' Flatten list completely
#'
#' Flattens a list recursively, converting vector elements to list elements, producing a one-level list with all elements length 1. Names may not be preserved.
#'
#' @param data list or vector
#'
#' @return single-level list with all list elements of length 1
#'
#' @examples
#' listFlatten(list(list(list(1:5))))
#' listFlatten(7)
#' listFlatten(7:9)
#' listFlatten("foo")
#' listFlatten(c("foo","gorp"))
#' data <- list(list(3:4,"apple"), TRUE, list(list(5.1,"foo"),NULL))
#' listFlatten(data)
#'
#' @export

listFlatten <- function(data) {
  if (!inherits(data, "list") & length(data) < 2) {
    return(list(data))
  } else {
    din <- unlist(c(lapply(data, listFlatten)), recursive = FALSE)
    for (i in 1:length(din)) { if (length(din[[i]]) > 1) din[[i]] <- as.list(din[[i]]) }
    dout <- unlist(c(lapply(din, listFlatten)), recursive = FALSE)
    return(dout)
  }
}

# look at rapply
#
# OLD code depends on rlang:
#
# listFlatten <- function(data) {
#   if (requireNamespace("rlang", quietly = TRUE)) {
#     d <- rlang::squash(as.list(data))
#     for (i in 1:length(d)) {
#       if (!is.null(d[[i]])) {
#         d[[i]] <- as.list(d[[i]])
#       }
#     }
#     d <- rlang::squash(d)
#     return(d)
#   } else {
#     stop('listFlatten requires the rlang package')
#   }
# }

