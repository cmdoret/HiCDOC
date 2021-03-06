#' List of HiCDOC default parameters.
#'
#' @name HiCDOCDefaultParameters
#' @docType data
#' @keywords data
#' @examples
#' exp <- HiCDOCExample()
#' exp <- HiCDOC(exp)
#'
#' @export
HiCDOCDefaultParameters <- list(
    kMeansIterations = 50,
    kMeansDelta      = 0.0001,
    kMeansRestarts   = 20,
    sampleSize       = 20000,
    loessSpan        = 0.75
)

###############################################################################
# HiCDOCDataSet S4 class definition
###############################################################################
#' Infrastructure for HiCDOC data set
#'
#' \code{HiCDOCDataSet} is an S4 class providing the infrastructure (slots)
#' to store the input data.
#'
#' @details \code{HiCDOCDataSet} does this and that...
#' TODO
#'
#' @name HiCDOCDataSet
#' @rdname HiCDOCDataSet
#' @docType class
#' @aliases HiCDOCDatSet HiCDOCDataSet-class
#'
#' @slot inputPath The input matrix/matrices.  Can be the path(s) to
#' to one, or several files, depending on the format considered.
#' @slot interactions A data frame storing the matrices.  Is built using
#' the values in the \code{inputPath} files.
#' @slot replicates A vector storing the names of the replicates.
#' @slot conditions A vector storing the names of the conditions.
#' There should be exactly two different conditions.
#' @slot binSize The resolution.
#'
#' @export
setClass(
    "HiCDOCDataSet",
    slots = c(
        inputPath    = "ANY",
        interactions = "ANY",
        replicates   = "ANY",
        conditions   = "ANY",
        binSize      = "ANY"
    )
)

##- makeHiCDOCDataSet --------------------------------------------------------#
##----------------------------------------------------------------------------#
#' Constructor function for the \code{HiCDOCDataSet} class.
#'
#' @param inputPath    One or several file(s) that contain the input matrix/ces.
#' @param interactions The interaction matrices.
#' @param replicates   The list of the replicate names.
#' @param conditions   The names of the two conditions.
#' @param binSize      The resolution.
#' @return A \code{HiCDOCDataSet} object.
#' @examples
#' basedir <- system.file("extdata", package="HiCDOC", mustWork = TRUE)
#' matrix  <- file.path(basedir, "sampleMatrix.tsv")
#' data    <- makeHiCDOCDataSet(inputPath = matrix)
#' @export
makeHiCDOCDataSet <- function(
    inputPath    = NULL,
    interactions = NULL,
    replicates   = NULL,
    conditions   = NULL,
    binSize      = NULL) {
    ##- checking general input arguments -------------------------------------#
    ##------------------------------------------------------------------------#

    ##- matrix
    if (is.null(inputPath)) {
        stop("'inputPath' must be the path(es) to a matrix(ces)",
                 call. = FALSE)
    }

    if (!is.character(inputPath)) {
        stop("'inputPath' must be a character.", call. = FALSE)
    }

    for (fileName in inputPath) {
        if (!file.exists(fileName)) {
            stop(paste("File name", fileName, "is not a valid file."),
                    call. = FALSE)
        }
    }

    ##- end checking ---------------------------------------------------------#

    object <- new("HiCDOCDataSet")
    object@inputPath <- inputPath
    if (!is.null(interactions)) {
        object@interactions <- interactions
    }
    if (!is.null(replicates)) {
        object@replicates <- replicates
    }
    if (!is.null(conditions)) {
        object@conditions <- conditions
    }
    if (!is.null(binSize)) {
        object@binSize <- binSize
    }
    return(object)
}


##- HiCDOCDataSet S4 class constructor from sparse matrix --------------------#
##----------------------------------------------------------------------------#
#' Reads a sparse matrix and fill a \code{HiCDOCDataSet} with its content.
#'
#' @rdname HiCDOCDataSetFromSparseMatrix
#' @docType class
#'
#' @param matrix A matrix with the data.
#'
#' @return \code{HiCDOCDataSet} constructor returns an \code{HiCDOCDataSet}
#'         object of class S4.
#'
#' @examples
#' linkToMatrix <- system.file("extdata", "sampleMatrix.tsv",  package="HiCDOC")
#' srnaExp <- HiCDOCDataSetFromSparseMatrix(linkToMatrix)
#' srnaExp
#'
#' @export
HiCDOCDataSetFromSparseMatrix <- function(matrix = NULL) {
    ##- checking general input arguments -------------------------------------#
    ##------------------------------------------------------------------------#

    ##- end checking ---------------------------------------------------------#

    data <- makeHiCDOCDataSet(inputPath = matrix)
    object <- parseInteractionMatrix3Columns(data)

    return(invisible(object))
}


##- HiCDOCDataSet S4 class constructor from cool files -----------------------#
##----------------------------------------------------------------------------#
#' Construct a \code{HiCDOCDataSet} from a cool file.
#' @rdname HiCDOCDataSetFromCool
#' @docType class
#'
#' @param coolFileNames A vector of file names, each one being a .cool file.
#' @param replicates   The list of the replicate names.
#' @param conditions   The names of the two conditions.
#'
#' @return \code{HiCDOCDataSet} constructor returns an \code{HiCDOCDataSet}
#'         object of class S4.
#'
#' @examples
#' data    <- read.csv(system.file("extdata","coolData.csv", package="HiCDOC"))
#' data
#' \dontrun{
#' dataSet <- HiCDOCDataSetFromCool(file.path(basedir, data$FileName),
#'                                  data$Replicate,
#'                                  data$Condition)
#' }

#'
#' @export
HiCDOCDataSetFromCool <- function(
  coolFileNames,
  replicates,
  conditions
) {

  ##- checking general input arguments -------------------------------------#
  ##------------------------------------------------------------------------#

  ##- coolFileNames
  if (is.null(coolFileNames)) {
    stop("'coolFileNames' must be paths to cool files", call. = FALSE)
  }
  if (is.factor(coolFileNames)) {
    coolFileNames <- as.vector(coolFileNames)
  }
  if (!is.vector(coolFileNames)) {
    stop("'coolFileNames' must be a vector.", call. = FALSE)
  }
  if (!is.character(coolFileNames)) {
    stop("'coolFileNames' must be a vector of characters.", call. = FALSE)
  }
  for (coolFileName in coolFileNames) {
    # Remove trailing URI in case of an mcool file
    coolFilePath <- strsplit(coolFileName, '::/')[[1]][1]
    if (!file.exists(coolFilePath)) {
      stop(
        paste("Cool file name", coolFilePath, "is not a valid file."),
        call. = FALSE
      )
    }

    ##- conditions
    if (is.null(conditions)) {
        stop("'conditions' should not be null.", call. = FALSE)
    }
    if (is.factor(conditions)) {
        conditions <- as.vector(conditions)
    }
    ##- end checking ---------------------------------------------------------#

    data   <- makeHiCDOCDataSet(inputPath  = coolFileNames,
                                replicates = replicates,
                                conditions = conditions)
    object <- parseInteractionMatrixCool(data)

    return(invisible(object))
}


##- HiCDOCDataSet S4 class constructor from hic files ------------------------#
##----------------------------------------------------------------------------#
#' Construct a \code{HiCDOCDataSet} from a hic file.
#' @rdname HiCDOCDataSetFromHic
#' @docType class
#'
#' @param hicFileNames A vector of file names, each one being a .hic file.
#' @param replicates   The list of the replicate names.
#' @param conditions   The names of the two conditions.
#' @param resolution   The resolution.
#'
#' @return \code{HiCDOCDataSet} constructor returns an \code{HiCDOCDataSet}
#'         object of class S4.
#'
#' @examples
#' data <- read.csv(system.file("extdata", "hicData.csv", package="HiCDOC"))
#' data
#' \dontrun{
#' dataSet <- HiCDOCDataSetFromHic(file.path(basedir, data$FileName),
#'                                  data$Replicate,
#'                                  data$Condition,
#'                                  100000)
#'}
#'
#' @export
#'
HiCDOCDataSetFromHic <- function(hicFileNames,
                                 replicates,
                                 conditions,
                                 resolution) {
    ##- checking general input arguments -------------------------------------#
    ##------------------------------------------------------------------------#

    ##- hicFileNames
    if (is.null(hicFileNames)) {
        stop("'hicFileNames' must be paths to hic files", call. = FALSE)
    }
    if (is.factor(hicFileNames)) {
        hicFileNames <- as.vector(hicFileNames)
    }
    if (!is.vector(hicFileNames)) {
        stop("'hicFileNames' must be a vector.", call. = FALSE)
    }
    if (!is.character(hicFileNames)) {
        stop("'hicFileNames' must be a vector of characters.", call. = FALSE)
    }
    for (hicFileName in hicFileNames) {
        if (!file.exists(hicFileName)) {
            stop(paste("hic file name", hicFileName, "is not a valid file."),
                 call. = FALSE)
        }
    }

    ##- conditions
    if (is.null(conditions)) {
        stop("'conditions' should not be null.", call. = FALSE)
    }
    if (is.factor(conditions)) {
        conditions <- as.vector(conditions)
    }

    ##- resolution
    if (is.null(resolution)) {
        stop("'resolution' should not be null.", call. = FALSE)
    }
    if (is.factor(resolution)) {
        resolution <- as.vector(resolution)
    }
    if (!is.numeric(resolution)) {
        stop("'resolution' should be an integer.", call. = FALSE)
    }
    if (length(resolution) != 1) {
        stop("'resolution' should not be a vector.", call. = FALSE)
    }

    ##- end checking ---------------------------------------------------------#

    data   <- makeHiCDOCDataSet(
        inputPath  = hicFileNames,
        replicates = replicates,
        conditions = conditions,
        binSize    = resolution
    )
    object <- parseInteractionMatrixHic(data)

    return(invisible(object))
}

##- Example constructor ------------------------------------------------------#
##----------------------------------------------------------------------------#
#' Example constructor
#'
#' This function provides an example of a \code{HiCDOCExp} object from
#' Marti-Marimon et al.
#'
#' @return An \code{HiCDOCExp} object called '\code{exp}'.
#'
#' @examples
#' ## The 'HiCDOCExp' object in this example was constructed by:
#' exp <- HiCDOCExample()
#' exp
#'
#' @export
HiCDOCExample <- function() {
    object  <- NULL
    basedir <-
        system.file("extdata", package = "HiCDOC", mustWork = TRUE)
    matrix  <- file.path(basedir, "sampleMatrix.tsv")
    dataSet <- HiCDOCDataSetFromSparseMatrix(matrix)
    object  <- HiCDOCExp(dataSet)
    return(invisible(object))
}

###############################################################################
### HiCDOC S4 class definition
###############################################################################
#' Infrastructure for HiCDOC experiment and differential interaction
#'
#' \code{HiCDOC} is an S4 class providing the infrastructure (slots)
#' to store the input data, methods parameters, intermediate calculations
#' and results of a differential interaction pipeline
#'
#' @details \code{HiCDOCExp} does this and that...
#' TODO
#'
#' @name HiCDOCExp
#' @rdname HiCDOCExp
#' @docType class
#' @aliases HiCDOCExp HiCDOCExp-class
#'
#' @slot inputPath The names of the matrix input files.
#' @slot interactions The interaction matrices.
#' @slot weakBins The empty bins.
#' @slot chromosomes The list of chromosomes.
#' @slot replicates The names of the replicates.
#' @slot totalReplicates The names of the replicates, glued with the
#' name of the conditions.
#' @slot totalReplicatesPerCondition A 2-element list, one for each condition,
#' where the union is the names of the replicates.
#' @slot conditions The names of the conditions (exactly two different).
#' @slot totalBins The number of bins per chromosome.
#' @slot binSize The resolution.
#' @slot sampleSize The number of bins used when sampling all the bins.
#' @slot distances The distribution of distances to the centroids.
#' @slot diagonalRatios TODO
#' @slot compartments The A/B compartments distribution, along the chromosomes.
#' @slot concordances The concordance distribution, along the chromosomes.
#' @slot differences The distribution of the difference of the concordance.
#' @slot centroids The position of the centroids.
#' @slot loessSpan The optimal span value used for the diagonal normalization.
#' @slot kMeansIterations The maximum number of 2-means iterations.
#' @slot kMeansDelta The stop criterion of convergence of the 2-means method.
#' @slot kMeansRestarts The maximum number of restarts for the 2-means.
#' @slot parameters An named \code{list}. The parameters for the
#' segmentation methods. See \code{\link{parameters}}.
#'
#' @export
setClass(
    "HiCDOCExp",
    slots = c(
        inputPath                   = "ANY",
        interactions                = "ANY",
        weakBins                    = "ANY",
        chromosomes                 = "ANY",
        replicates                  = "ANY",
        totalReplicates             = "ANY",
        totalReplicatesPerCondition = "ANY",
        conditions                  = "ANY",
        totalBins                   = "ANY",
        binSize                     = "ANY",
        sampleSize                  = "ANY",
        distances                   = "ANY",
        diagonalRatios              = "ANY",
        compartments                = "ANY",
        concordances                = "ANY",
        differences                 = "ANY",
        centroids                   = "ANY",
        loessSpan                   = "ANY",
        kMeansIterations            = "ANY",
        kMeansDelta                 = "ANY",
        kMeansRestarts              = "ANY",
        parameters                  = "ANY"
    )
)


##- HiCDOCExp S4 class constructor -----------------------------------------#
##--------------------------------------------------------------------------#
#' @rdname HiCDOCExp
#' @docType class
#'
#' @param dataSet A \code{HiCDOCDataSet} object.
#' @param parameters A named \code{list}. The parameters for the
#'                    segmentation methods. See \code{\link{parameters}}.
#' @param binSize    The resolution.
#'
#' @return \code{HiCDOCExp} constructor returns an \code{HiCDOCExp}
#'         object of class S4.
#'
#' @examples
#' linkToMatrix <- system.file("extdata", "sampleMatrix.tsv", package="HiCDOC")
#' srnaDataSet <- HiCDOCDataSetFromSparseMatrix(linkToMatrix)
#' srnaExp <- HiCDOCExp(srnaDataSet)
#' @export
HiCDOCExp <- function(dataSet = NULL,
                      parameters = NULL,
                      binSize = NULL) {
    ##- checking general input arguments -------------------------------------#
    ##------------------------------------------------------------------------#

    ##- dataSet
    if (is.null(dataSet)) {
        stop("'dataSet' must be specified", call. = FALSE)
    }

    ##- parameters

    ##- end checking ---------------------------------------------------------#

    object <- new("HiCDOCExp")

    object@interactions <- dataSet@interactions
    object@replicates   <- dataSet@replicates
    object@conditions   <- dataSet@conditions

    object@chromosomes <-
        mixedsort(as.vector(unique(object@interactions$chromosome)))

    object@totalReplicates <- length(object@replicates)

    object@totalReplicatesPerCondition <-
        vapply(c(1, 2), function(x) {
            length(which(object@conditions == x))
        }, FUN.VALUE = c(0))

    if (is.null(binSize)) {
        object@binSize <- min(abs(
            object@interactions$position.1[object@interactions$position.1
                                           != object@interactions$position.2]
            - object@interactions$position.2[object@interactions$position.1
                                             != object@interactions$position.2]
        ))
    }
    else {
        object@binSize <- binSize
    }

    object@totalBins <- vector("list", length(object@chromosomes))
    names(object@totalBins) <- object@chromosomes

    for (chromosomeId in object@chromosomes) {
        chromosomeInteractions <- object@interactions %>%
            filter(chromosome == chromosomeId)
        object@totalBins[[chromosomeId]] <-
            max(chromosomeInteractions$position.1,
                chromosomeInteractions$position.2) / object@binSize + 1
    }

    object@weakBins <- vector("list", length(object@chromosomes))
    names(object@weakBins) <- object@chromosomes

    object@kMeansIterations <-
        HiCDOCDefaultParameters$kMeansIterations
    object@kMeansDelta      <- HiCDOCDefaultParameters$kMeansDelta
    object@kMeansRestarts   <- HiCDOCDefaultParameters$kMeansRestarts
    object@sampleSize       <- HiCDOCDefaultParameters$sampleSize
    object@loessSpan        <- HiCDOCDefaultParameters$loessSpan

    return(invisible(object))
}


##- Main method --------------------------------------------------------------#
##----------------------------------------------------------------------------#
#' Main method.  Start the pipeline with default parameters.
#'
#' @param object A \code{HiCDOCExp} object.
#' @return Returns an \code{HiCDOCExp} object.
#' @export
HiCDOC <- function(object) {
    object <- normalizeTechnicalBiases(object)
    object <- normalizeBiologicalBiases(object)
    object <- normalizeDistanceEffect(object)
    object <- detectCompartments(object)
    return(invisible(object))
}
