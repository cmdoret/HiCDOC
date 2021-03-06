% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/normalizeDistanceEffect.R
\name{normalizeDistanceEffect}
\alias{normalizeDistanceEffect}
\title{Normalize the distance effect using a loess on the intensity vs distance
to diagonal.}
\usage{
normalizeDistanceEffect(object)
}
\arguments{
\item{object}{A \code{HiCDOCExp} object.}
}
\value{
A \code{HiCDOCExp} object, with the normalized matrices.
}
\description{
Normalize the distance effect using a loess on the intensity vs distance
to diagonal.
}
\examples{
object <- HiCDOCExample()
object <- filterSmallChromosomes(object)
object <- filterWeakPositions(object)
object <- normalizeTechnicalBiases(object)
object <- normalizeBiologicalBiases(object)
object <- normalizeDistanceEffect(object)
}
