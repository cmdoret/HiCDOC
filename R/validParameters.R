##- testChromosome -----------------------------------------------------------#
##----------------------------------------------------------------------------#
#' Test the existence of a given chromosome.
#'
#' @param object A \code{HiCDOCExp} object.
#' @param chromosomeId The condition name, or an error.
#'
#' @return The chromosome name or an error.
testChromosome <- function(object, chromosomeId) {
    if (chromosomeId %in% object@chromosomes) return (chromosomeId)
    if (is.numeric(chromosomeId) == TRUE &&
            chromosomeId %in% seq_len(length(object@chromosomes)))
        return (object@chromosomes[chromosomeId])
    stop(paste("Unknown chromosome:", chromosomeId), call. = FALSE)
}

##- testCondition -----------------------------------------------------------#
##---------------------------------------------------------------------------#
#' Test the existence of a given condition in a HiCDOC object
#'
#' @param object A \code{HiCDOCExp} object.
#' @param conditionId    A character or numeric value
#'
#' @return The condition name, or an error.
testCondition <- function(object, conditionId) {
    if (conditionId %in% object@conditions) return (conditionId)
    uniquecond <- unique(object@conditions)
    if (is.numeric(conditionId) && conditionId %in% seq_len(length(uniquecond)))
        return (uniquecond[conditionId])
    stop(paste("Unknown condition:", conditionId), call. = FALSE)
}

##- testSlotsHiCDOCExp -------------------------------------------------------#
##----------------------------------------------------------------------------#
#' Test the existence of slots in HiCDOCExp object
#'
#' @param object A \code{HiCDOCExp} object.
#' @param slots Character vector, names of slots to verify. Default to NULL.
#' If NULL, check only for the class of \code{object}
#'
#' @return An error if the object is not a HiCDOCExp object or a slot is
#' missing.
testSlotsHiCDOCExp <- function(object, slots = NULL) {
    if (!is(object, "HiCDOCExp"))
        stop("The object provided is not from class HiCDOCExp", call. = FALSE)

    if (!is.null(slots)) {
        existing <- slotNames("HiCDOCExp")
        existing <- existing[vapply(
            existing,
            function(x) .hasSlot(object, x) && !is.null(slot(object, x)),
            TRUE
        )]
        missing <- slots[!(slots %in% existing)]
        if (length(missing) > 0) {
            missingInteractions = FALSE
            missingCompartments = FALSE
            compartmentSlots = c(
                "compartments",
                "concordances",
                "differences",
                "distances",
                "centroids",
                "diagonalRatios"
            )
            for (slot in missing) {
                if (slot == "interactions") missingInteractions = TRUE
                if (slot %in% compartmentSlots) missingCompartments = TRUE
            }
            stop(
                paste0(
                    "Missing slot(s): ",
                    paste(missing, collapse = ", "),
                    if (missingInteractions)
                        "\nPlease provide an HiCDOC object, with filled interactions.",
                    if (missingCompartments)
                        "\nPlease run 'detectCompartments' first."
                ),
                call. = FALSE
            )
        }
    }
}
