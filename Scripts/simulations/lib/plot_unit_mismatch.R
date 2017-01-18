plot_unit_mismatch <- function(data, suffix, mult=FALSE, single=FALSE, lim=0.5, filename=NA){
    
    subplot=list()
    
    if (mult){
        titles=list()
        titles[[1]] <- paste("Nominal (", suffix,")")
        titles[[2]] <- "Different scaling target"
        titles[[3]] <- "Different scaling algorithm (same target)"
        titles[[4]] <- "Different contrast vector scaling"
        
        data_subplot[[1]] <- subset(data, unitMism=="nominal")
        data_subplot[[2]] <- subset(data, unitMism=="datascl" & soft2Factor==100)
        data_subplot[[3]] <- subset(data, unitMism=="datascl" & soft2Factor!=100)
        data_subplot[[4]] <- subset(data, soft2==0 & unitMism=="contscl")
        
        data <- data_subplot
    }
    
    p <- plot_blandaldman_z(data, methods~unitMism+soft2, paste("Unit mismatch:", suffix), mult, lim, filename)
}