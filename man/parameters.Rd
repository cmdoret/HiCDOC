% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/methods.R
\docType{methods}
\name{parameters}
\alias{parameters}
\alias{parameters,HiCDOCExp-method}
\alias{parameters<-}
\alias{parameters<-,HiCDOCExp-method}
\alias{printHiCDOCParameters}
\title{Accessors for the 'parameters' slot of an HiCDOCExp object}
\usage{
\S4method{parameters}{HiCDOCExp}(object)

\S4method{parameters}{HiCDOCExp}(object) <- value

printHiCDOCParameters(x, ...)
}
\arguments{
\item{object}{An \code{HiCDOCExp} object.}

\item{value}{A named \code{list} containing valid parameters. See details.}

\item{x}{The first element of the parameters used by an \code{HiCDOC} object}

\item{...}{The other elements of the parameters}
}
\value{
The named list of the parameters used in the analysis.
}
\description{
The \code{parameters} slot holds the parameter values
used in an experiment as a named \code{list}. Default values
exist for parameters, but these can also be supplied as input
values in the \code{useParameters} argument of the \code{\link{HiCDOC}}
function or using the assignment function \code{\link{parameters<-}}.
}
\details{
Parameters in a HiCDOC experiment.

\subsection{Global parameters}{
   \describe{
       \item{\code{minDepth}}{The cutoff to filter the base-level
               coverage. Bases where at least one sample has (normalized)
               coverage greater than \code{minDepth} be been retained.
               Default to \code{10}.}
   }
}
}
\examples{
exp <- HiCDOCExample()
exp <- HiCDOC(exp)
print(parameters(exp))

exp <- HiCDOCExample()
exp <- HiCDOC(exp)
print(parameters(exp))

}
\seealso{
\code{useParameters} argument in \code{\link{HiCDOC}} function.
}
