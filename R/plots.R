#' Plot the interaction matrix (as heatmap).
#'
#' @param object an \code{HiCDOCExp} object
#' @param chromosomeId The name or number of the chromosome to plot.
#' If number, will be taken in \code{object@chromosomes[chromosomeId]}
#' @param trans character: transformation of the color scale. Default to "log2".
#' See \code{\link[ggplot2]{scale_fill_gradientn}} for other accepted values.
#' Set to NULL for no transformation.
#' @param colours character vector, vector of colours to use for n-colour gradient.
#' Default to \code{c("#000066", "#ffffbf", "#990000")}.
#'
#' @return A \code{ggplot} object.
#' @examples
#' object <- HiCDOCExample()
#' p <- plotInteractionMatrix(object, chromosomeId = 1, trans = "log2")
#' @export
plotInteractionMatrix <-
    function(object,
             chromosomeId,
             trans = "log2",
             colours = c("#000066", "#ffffbf", "#990000")) {
        # Parameters
        testSlotsHiCDOCExp(object,
                           slots = c("interactions",
                                     "conditions",
                                     "totalBins",
                                     "binSize"))
        chr <- testChromosome(object, chromosomeId)
        if (is.null(trans))
            trans <- "Identity"

        # Prepare data
        interactionsChr <- object@interactions %>%
            filter(chromosome == chr & value > 0)
        nblevels <- table(object@conditions)
        nbrows <- 1
        if (max(nblevels) == min(nblevels))
            nbrows <- length(unique(object@conditions))
        xylim <- c(0, (object@totalBins[[chr]] - 1) * object@binSize)

        if (nrow(interactionsChr) > 0) {
            p <-
                ggplot(data = interactionsChr,
                       aes(x = position.1, y = position.2, z = value)) +
                geom_raster(aes(fill = value), na.rm = TRUE) +
                geom_raster(
                    data = interactionsChr[interactionsChr$position.1 !=
                                               interactionsChr$position.2,],
                    aes(x = position.2, y = position.1, fill = value),
                    na.rm = TRUE
                ) +
                coord_fixed(ratio = 1) +
                theme_bw() +
                xlim(xylim) +
                scale_y_reverse(limits = rev(xylim)) +
                facet_wrap(condition ~ replicate,
                           nrow = nbrows,
                           labeller = label_wrap_gen(multi_line = FALSE)) +
                labs(title = paste("Chromosome:", chr), x = "", y = "")
            p <-
                p + scale_fill_gradientn(
                    colours = colours,
                    trans = trans,
                    name = "Intensity",
                    na.value = "transparent"
                )
        } else {
            message("No interaction data, with positive value to plot")
            p <- NULL
        }
        return(p)
    }

#' Plot the distance vs intensity matrix.
#'
#' @param object an \code{HiCDOCExp} object
#' @return A \code{ggplot}.
#' @examples
#' object <- HiCDOCExample()
#' plotDistanceEffect(object)
#' @export
plotDistanceEffect <- function(object) {
    testSlotsHiCDOCExp(object, slots = c("interactions"))

    p <- object@interactions %>%
        mutate(distance = position.2 - position.1) %>%
        ggplot(aes(x = distance, y = value)) +
        geom_bin2d() +
        scale_fill_gradient(low = "white",
                            high = "blue",
                            trans = "log2") +
        geom_point(col = "transparent") + # necessary for geom_smooth
        geom_smooth(col = "red") +
        labs(title = "Distance effect")
    p <-
        ggMarginal(p, margins = "x", type = "histogram", fill = "transparent")
    return(p)
}

#' Plot the concordance, i.e. the relative distance of the genomic positions
#' with respect to the centroids.
#'
#' @param object an \code{HiCDOCExp} object
#' @return A list of \code{ggplot}, one for each chromosome.
#' @examples
#' object <- HiCDOCExample()
#' object <- filterSmallChromosomes(object)
#' object <- filterWeakPositions(object)
#' object <- normalizeTechnicalBiases(object)
#' object <- normalizeBiologicalBiases(object)
#' object <- normalizeDistanceEffect(object)
#' object <- detectCompartments(object)
#' plotDiffConcordances(object)
#' @export
plotDiffConcordances <- function(object) {
    testSlotsHiCDOCExp(object,
                       slots = c("interactions", "differences", "concordances"))

    changed <- object@differences %>%
        select(-c(`end`, `padj`)) %>%
        rename(position = start) %>%
        mutate(changed = "T")

    differences <- object@concordances %>%
        group_by(.dots = c("chromosome", "position", "condition")) %>%
        summarise(value = median(value)) %>%
        ungroup() %>%
        spread(condition, value) %>%
        mutate(value = `2` - `1`) %>%
        select(-c(`1`, `2`)) %>%
        left_join(changed, by = c("chromosome", "position")) %>%
        mutate(changed = replace_na(changed, "F")) %>%
        select(-c(chromosome, position))

    p <- ggplot(differences, aes(x = value, fill = changed)) +
        geom_histogram() +
        labs(x = "Concordance",
             title = "Distribution of the differences of concordances")
    return(p)
}

#' Plot the distribution of A/B compartments along the genomic positions.
#'
#' @param object an \code{HiCDOCExp} object
#' @param chromosomeId character or numeric value, name or number of chromosome
#' @param conditionId character or numeric value, name or number of condition
#' @return A list of \code{ggplot}, one for each chromosome.
#' @examples
#' object <- HiCDOCExample()
#' object <- filterSmallChromosomes(object)
#' object <- filterWeakPositions(object)
#' object <- normalizeTechnicalBiases(object)
#' object <- normalizeBiologicalBiases(object)
#' object <- normalizeDistanceEffect(object)
#' object <- detectCompartments(object)
#' plotAB(object, 1, 1)
#' @export
plotAB <- function(object, chromosomeId, conditionId) {
    testSlotsHiCDOCExp(object, slots = c("diagonalRatios", "compartments"))
    chr <- testChromosome(object, chromosomeId)
    cond <- testCondition(object, conditionId)

    data <- object@diagonalRatios %>%
        left_join(
            object@compartments %>% rename(compartment = value),
            by = c("chromosome", "condition", "position")
        ) %>%
        filter(chromosome == chr) %>%
        filter(condition == cond)

    ggplot(data, aes(x = compartment, y = value)) +
        geom_jitter(aes(color = compartment)) +
        geom_boxplot(outlier.colour = NA,
                     fill = NA,
                     colour = "grey20") +
        labs(
            color = "Compartment",
            x = "Compartment",
            y = "Difference of int.",
            title = paste0("Chromosome: ", chr, ", condition: ", cond)
        )
}


#' Plot the centroid distributions along the genomic positions
#' for a given chromosome.
#'
#' @param object an \code{HiCDOCExp} object
#' @param chromosomeId Character or numeric value. Name or number of
#' the chromosome, like in chromosomes(object)
#'
#' @return A \code{ggplot} object
#' @examples
#' object <- HiCDOCExample()
#' object <- filterSmallChromosomes(object)
#' object <- filterWeakPositions(object)
#' object <- normalizeTechnicalBiases(object)
#' object <- normalizeBiologicalBiases(object)
#' object <- normalizeDistanceEffect(object)
#' object <- detectCompartments(object)
#' plotCentroids(object, 1)
#' @export
plotCentroids <- function(object, chromosomeId) {
    testSlotsHiCDOCExp(object, slots = c("centroids"))
    chr <- testChromosome(object, chromosomeId)

    df <- object@centroids %>%
        filter(chromosome == chr) %>%
        select(-chromosome) %>%
        unite(name, c(condition, compartment))
    names <- df$name
    df <- df %>%
        spread(name, centroid) %>%
        unnest(cols = names) %>% t()

    pca <- prcomp(df)
    varpca <- pca$sdev ^ 2
    propvar <- varpca / sum(varpca)
    propvar <- paste(round(100 * propvar, 2), "%")

    pca <- as.data.frame(pca$x)
    pca$group <- row.names(df)
    p <-
        ggplot(pca, aes(
            x = PC1,
            y = PC2,
            color = group,
            shape = group
        )) + geom_point(size = 2) +
        labs(
            title = paste0("Centroids of chromosome ", chr),
            x = paste("PC1 ", propvar[1]),
            y = paste("PC2 ", propvar[2])
        )
    return(p)
}
