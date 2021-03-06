% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotCompartmentChanges.R
\name{testxlim}
\alias{testxlim}
\title{Return valid xlim}
\usage{
testxlim(xlim, positions)
}
\arguments{
\item{xlim}{The entred xlim}

\item{positions}{The positions from the data}
}
\value{
A length 2 numerical vector
}
\description{
test if the xlim is valid (length(2)) or \code{NULL} and return
the xlim for the plot.
If \code{NULL} or invalid return the min and max of \code{positions}.
}
