#' Return the text indicating what represent the gray areas on
#' plotConcordance()
#'
#' @param differences difference, from object@differences after
#' detectCompartments() function
#' @param padjThreshold threshold for the significance
#'
#' @return A character vector of length 1
textsignif <- function(differences, padjThreshold) {
    text <- "The grey areas are significant changes"
    if (nrow(differences) == 0)
        text <- "No change is significant"
    text <- paste(text, "(pAdj <", round(100 * padjThreshold, 2), "%)")
    return(text)
}

#' Return valid xlim
#'
#' test if the xlim is valid (length(2)) or \code{NULL} and return
#' the xlim for the plot.
#' If \code{NULL} or invalid return the min and max of \code{positions}.
#'
#' @param xlim The entred xlim
#' @param positions The positions from the data
#'
#' @return A length 2 numerical vector
testxlim <- function(xlim, positions) {
    if (is.null(xlim) == FALSE) {
        if (length(xlim) != 2) {
            message("Incorrect values for xlim (numerical of length 2 expected),
                         Set to NULL")
            xlim <- NULL
        } else {
            xlim <- sort(xlim)
        }
    }
    if (is.null(xlim) == TRUE) {
        xlim <-
            c(min(positions, na.rm = TRUE),
                max(positions, na.rm = TRUE))
    }
    return(xlim)
}


#' Plot the concordance
#'
#' Plot the concordance of all the replicates for one chromosome.
#'
#' @param object A \code{HiCDOCExp} object on which \code{detectCompartments()} has run.
#' @param chromosomeId The name or number of the chromosome to plot.
#' If number, will be taken in \code{object@chromosomes[chromosomeId]}
#' @param xlim A numeric-value pair, indicating the interval of positions to represent.
#' Default to NULL = all positions.
#' @param padjThreshold Significance threshold for the changes. Default to 0.05.
#' @param points Logical (default to FALSE). If TRUE, points will be added on the concordance lines.
#'
#' @return A ggplot.
#' @export
#'
#' @examples
#' object <- HiCDOCExample()
#' object <- filterSmallChromosomes(object)
#' object <- filterWeakPositions(object)
#' object <- normalizeTechnicalBiases(object)
#' object <- normalizeBiologicalBiases(object)
#' object <- normalizeDistanceEffect(object)
#' object <- detectCompartments(object)
#' plotConcordance(object, 1)
#' @export
plotConcordance <- function(object,
                            chromosomeId,
                            xlim = NULL,
                            padjThreshold = 0.05,
                            points = FALSE) {
    testSlotsHiCDOCExp(object, slots = c("concordances", "differences"))
    chr <- testChromosome(object, chromosomeId)
    xlim <- testxlim(xlim,
                     seq_len(object@totalBins[[chr]] - 1) * object@binSize)

    concordance <- object@concordances %>%
        filter(chromosome == chr) %>%
        filter(position >= xlim[1] & position <= xlim[2]) %>%
        mutate(condition = paste0("confidence, cond. ", condition)) %>%
        mutate(position = position + 0.5 * object@binSize)

    # Significant differences
    differences <- object@differences %>%
        filter(chromosome == chr) %>%
        filter(start >= xlim[1] & start <= xlim[2]) %>%
        filter(padj < padjThreshold) %>%
        pivot_longer(cols = starts_with("condition"),
                     values_to = "condition") %>%
        mutate(condition = paste0("confidence, cond. ", condition))

    textdifference <- textsignif(differences, padjThreshold)

    ylim <-
        c(min(concordance$value, na.rm = TRUE),
            max(concordance$value, na.rm = TRUE))

    gp <- ggplot()
    if (nrow(differences) > 0) {
        gp <- gp + geom_rect(
            data = differences,
            aes(
                xmin = start,
                xmax = end,
                ymin = ylim[1],
                ymax = ylim[2]
            ),
            color = NA,
            fill = "gray80"
        )
    }
    gp <- gp +
        geom_line(data = concordance,
                  aes(x = position, y = value, color = replicate))
    if (points == TRUE) {
        gp <- gp + geom_point(data = concordance,
                              aes(x = position, y = value, color = replicate))
    }
    gp <- gp + labs(caption = textdifference) +
        xlim(xlim[1] , xlim[2] + object@binSize) +
        ylim(ylim) +
        geom_hline(yintercept = 0.0, size = 0.1) +
        facet_grid(rows = vars(condition),  margins = FALSE, switch = "y")    +
        theme_minimal() +
        theme(
            axis.title.y = element_blank(),
            axis.line.y = element_blank(),
            axis.ticks = element_blank(),
            legend.position = "bottom",
            strip.placement = "outside"
        )
    return(gp)
}

#' Plot the A & B compartments
#'
#' Plot the A and B compartments after \code{detectCompartments()} on
#' a HiCDOCExp object, for a chromosome.
#'
#' @param object A \code{HiCDOCExp} object on which \code{detectCompartments()} has run.
#' @param chromosomeId The name or number of the chromosome to plot.
#' If number, will be taken in \code{object@chromosomes[chromosomeId]}
#' @param xlim A numeric-value pair, indicating the interval of positions to represent.
#' Default to NULL = all positions.
#'
#' @return A ggplot.
#' @export
#'
#' @examples
#' object <- HiCDOCExample()
#' object <- filterSmallChromosomes(object)
#' object <- filterWeakPositions(object)
#' object <- normalizeTechnicalBiases(object)
#' object <- normalizeBiologicalBiases(object)
#' object <- normalizeDistanceEffect(object)
#' object <- detectCompartments(object)
#' plotCompartments(object, 1)
#' @export
plotCompartments <- function(object,
                             chromosomeId,
                             xlim = NULL) {
    testSlotsHiCDOCExp(object, slots = c("compartments"))
    chr <- testChromosome(object, chromosomeId)
    xlim <- testxlim(xlim,
                     seq_len(object@totalBins[[chr]] - 1) * object@binSize)

    compartments <- object@compartments %>%
        filter(chromosome == chr) %>%
        filter(position >= xlim[1] & position <= xlim[2]) %>%
        mutate(compartment = factor(value)) %>%
        mutate(position = position + 0.5 * object@binSize)

    ggplot(data = compartments, aes(x = position, fill = compartment)) +
        geom_histogram(binwidth = object@binSize,
                       colour = "gray90",
                       size = 0.05) +
        xlim(xlim[1] - 0.5 * object@binSize, xlim[2] + 0.5 * object@binSize) +
        facet_grid(rows = vars(condition), margins = FALSE, switch = "y")    +
        theme_minimal() +
        theme(
            axis.title = element_blank(),
            axis.text = element_blank(),
            axis.line = element_blank(),
            axis.ticks = element_blank(),
            panel.grid = element_blank(),
            legend.position = "bottom" ,
            strip.placement = "outside"
        )
}

#' Run plotCompartments() and plotConcordance() and assemble them on the same plot
#'
#' @param object An HiCDOCExp object, after a detectCompartments() run
#' @param chromosomeId Name or number of the chromosome, like in object@chromosome
#' @param padjThreshold Significance threshold for the changes. Default to 0.05.
#' @param xlim A numeric-value pair, indicating the interval of positions to represent.
#' Default to NULL = all positions.
#' @param points Logical (default to FALSE). If TRUE, points will be added on the concordance lines.
#'
#' @return A ggplot object.
#'
#' @examples
#' object <- HiCDOCExample()
#' object <- filterSmallChromosomes(object)
#' object <- filterWeakPositions(object)
#' object <- normalizeTechnicalBiases(object)
#' object <- normalizeBiologicalBiases(object)
#' object <- normalizeDistanceEffect(object)
#' object <- detectCompartments(object)
#' plotCompartmentChanges(object, 1)
#' @export
plotCompartmentChanges <-
    function(object,
                     chromosomeId,
                     padjThreshold = 0.05,
                     xlim = NULL,
                     points = FALSE) {
        # Test parameters format
        testSlotsHiCDOCExp(object,
                           slots = c("concordances", "compartments", "differences"))
        chr <- testChromosome(object, chromosomeId)

        pConcordance <- plotConcordance(object, chr, xlim, padjThreshold, points)

        pCompartment <- plotCompartments(object, chr, xlim)

        # Horizontal alignment of the sub-graphs (change width of the plots)
        plotsgrobs <-
            lapply(list(
                pCompartment + theme(legend.position = "none"),
                pConcordance + theme(legend.position = "none")
            ),
            ggplot2::ggplotGrob)

        commonwidths <- plotsgrobs[[length(plotsgrobs)]]$widths
        plotsgrobs <-
            lapply(plotsgrobs, function(x) {
                x$widths <- commonwidths
                return(x)
            })

        finalplot <- ggpubr::as_ggplot(
            gridExtra::arrangeGrob(
                gridExtra::arrangeGrob(
                    plotsgrobs[[1]],
                    plotsgrobs[[2]],
                    heights = c(1, 5),
                    padding = unit(0, "cm")
                ),
                # Extract legends
                gridExtra::arrangeGrob(
                    gtable::gtable_filter(ggplotGrob(pCompartment), "guide-box"),
                    gtable::gtable_filter(ggplotGrob(pConcordance), "guide-box"),
                    ncol     = 2
                ),
                heights = c(10, 1),
                top = paste0("Chromosome ", chr)
            )
        )
        return(finalplot)
    }
