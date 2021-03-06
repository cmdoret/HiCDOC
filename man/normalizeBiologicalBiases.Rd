% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/normalizeBiologicalBiases.R
\name{normalizeBiologicalBiases}
\alias{normalizeBiologicalBiases}
\title{Remove biological biases by normalizing with Knight-Ruiz matrix balancing.}
\usage{
normalizeBiologicalBiases(object)
}
\arguments{
\item{object}{A \code{HiCDOCExp} object.}
}
\value{
A \code{HiCDOCExp} object, with the normalized matrices.
}
\description{
Remove biological biases by normalizing with Knight-Ruiz matrix balancing.
}
\examples{
object <- HiCDOCExample()
object <- filterSmallChromosomes(object)
object <- filterWeakPositions(object)
object <- normalizeTechnicalBiases(object)
object <- normalizeBiologicalBiases(object)
}
