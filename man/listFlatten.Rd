% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/listFlatten.R
\name{listFlatten}
\alias{listFlatten}
\title{Flatten list completely}
\usage{
listFlatten(data)
}
\arguments{
\item{data}{list or vector}
}
\value{
single-level list with all list elements of length 1
}
\description{
Flattens a list recursively, converting vector elements to list elements, producing a one-level list with all elements length 1. Names may not be preserved.
}
\examples{
listFlatten(list(list(list(1:5))))
listFlatten(7)
listFlatten(7:9)
listFlatten("foo")
listFlatten(c("foo","gorp"))
data <- list(list(3:4,"apple"), TRUE, list(list(5.1,"foo"),NULL))
listFlatten(data)

}
