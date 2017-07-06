plot_unit_mismatch <- function(data, suffix, mult=FALSE, single=FALSE, lim=0.5, filename=NA, max_z=NA, both=TRUE){
    
    data_list=list()   
    
    if (mult){
        titles=list()
        titles[[1]] <- paste("Nominal (", suffix,")")
        titles[[2]] <- "Different scaling target"
        titles[[3]] <- "Different scaling algorithm (same target)"
        titles[[4]] <- "Different contrast vector scaling"      
        
        data_list[[1]] <- subset(data, unitMism=="nominal")
        data_list[[2]] <- subset(data, unitMism=="datascl" & soft2Factor==100)
        data_list[[3]] <- subset(data, unitMism=="datascl" & soft2Factor!=100)
        data_list[[4]] <- subset(data, soft2==0 & unitMism=="contscl")
    } else {
        data_list[[1]] <- data
    }

    formula=methods~unitMism+soft2
    if (length(unique(data[data$unitMism=='datascl',]$soft2)) == 1)
    {
        # If there is only one parametrisation of data scaling do not facet over parameters
        formula=methods~unitMism
    }

    
    p <- plot_qq_p(data_list, formula, paste("Unit mismatch:", suffix), mult, lim, filename, max_z)
    if (both)
    {
        p <- plot_blandaldman_z(data_list, formula, paste("Unit mismatch:", suffix), mult, lim, filename, max_z)
    }
}