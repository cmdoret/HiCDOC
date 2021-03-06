% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllClasses.R
\docType{class}
\name{HiCDOCDataSetFromSparseMatrix}
\alias{HiCDOCDataSetFromSparseMatrix}
\title{Reads a sparse matrix and fill a \code{HiCDOCDataSet} with its content.}
\usage{
HiCDOCDataSetFromSparseMatrix(matrix = NULL)
}
\arguments{
\item{matrix}{A matrix with the data.}
}
\value{
\code{HiCDOCDataSet} constructor returns an \code{HiCDOCDataSet}
        object of class S4.
}
\description{
Reads a sparse matrix and fill a \code{HiCDOCDataSet} with its content.
}
\examples{
linkToMatrix <- system.file("extdata", "sampleMatrix.tsv",  package="HiCDOC")
srnaExp <- HiCDOCDataSetFromSparseMatrix(linkToMatrix)
srnaExp

}
