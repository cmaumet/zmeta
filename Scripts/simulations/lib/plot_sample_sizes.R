plot_sample_sizes <- function(data, title, mult=TRUE, lim=NA, filename=NA){
    
    if (mult){
        data_subpl <- list()
        idx = 1
        for (i in sort(unique(data$nStudies))){
            data_subpl[[idx]] <- subset(data, nStudies==i)
            idx = idx + 1
        }
        data <- data_subpl
    }
    print(length(data))
    p <- plot_blandaldman_z(data, methods~nStudies, paste("Small sample sizes:", title), mult, lim, filename)
}

