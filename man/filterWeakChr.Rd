% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/filterWeakPositions.R
\name{filterWeakChr}
\alias{filterWeakChr}
\title{Look for the weak positions for a given chromosome}
\usage{
filterWeakChr(object, chromosomeId, threshold = 0)
}
\arguments{
\item{object}{Interaction matrix for the chromosome}

\item{chromosomeId}{Number of total bins for this chromosome}

\item{threshold}{Numeric default to 0.}
}
\value{
list of length 2 : \code{"pos"} = the weak positions,
\code{"interactions"} the interactions matrix for the chromosome,
whithout the weak bins.
}
\description{
The function identifies and remove the weak positions
from the interaction matrix for a given chromosome, in a recursive way.
To be kept, the bins (positions) must have a mean value greater than
\code{threshold}, on all replicates and all conditions.
The mean is computed on the row of the reconstructed full interaction
matrix for the chromosome, 1 condition and 1 replicate.
}
