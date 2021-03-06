##- chromosomes
setGeneric(
    name = "chromosomes",
    def = function(object) {
        standardGeneric("chromosomes")
    }
)

##- interactions
setGeneric(
    name = "interactions",
    def = function(object) {
        standardGeneric("interactions")
    }
)

##- differences
setGeneric(
    name = "differences",
    def = function(object, pvalue) {
        standardGeneric("differences")
    }
)

##- compartments
setGeneric(
    name = "compartments",
    def = function(object) {
        standardGeneric("compartments")
    }
)

##- concordances
setGeneric(
    name = "concordances",
    def = function(object) {
        standardGeneric("concordances")
    }
)

##- parameters
setGeneric(
    name = "parameters",
    def = function(object) {
        standardGeneric("parameters")
    }
)

setGeneric(
    name = "parameters<-",
    def = function(object, value) {
        standardGeneric("parameters<-")
    }
)

##- parameters
setGeneric(
    name = "printHiCDOCParameters",
    def = function(object) {
        standardGeneric("printHiCDOCParameters")
    }
)
