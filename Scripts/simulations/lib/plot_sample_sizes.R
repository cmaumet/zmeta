plot_sample_sizes <- function(data, title, mult=TRUE, lim=NA, filename=NA){
    
    # Ignore soft2Factor=100 (too extreme)
    data = subset(data, data$soft2Factor<100)
        
    if (! mult) {
    
    allsimudat$Within <- factor(allsimudat$Within)
    p <- ggplot(data=data,aes(x=expectedz, y=equivz-expectedz, group=allgroups, colour=factor(Within)))

    p <- p + 
            geom_ribbon(
                aes(x=expectedz, ymin=z_lower-expectedz, ymax=z_upper-expectedz, group=glm), 
                fill="grey", alpha=.8, colour=NA) + 
            facet_grid(methods~nStudies, scales = "free", 
                       labeller = labeller(
                           methods = method_labels, 
                           nStudies = label_both,
                           soft2 = soft2_labels,
                           unitMism = units_labels)) + 
            theme(strip.text.x = element_text(size = 10)) + 
            ylab("Estimated - reference Z") + xlab("Reference Z") + 
            geom_line(aes(x=expectedz, y=0), colour="black") + 
            geom_line() + 
    #         geom_point(size=0.5) + 
            ggtitle(paste("Small sample sizes:", title)) + theme(legend.position="bottom") 
    
    if (! is.na(lim)){
        p <- p + coord_cartesian(ylim=c(-lim, lim))
    }
    } else {
        subpl=list()
        idx = 1
        for (i in sort(unique(data$nStudies))){
            subpl[[idx]] <- ggplot(data=subset(data, nStudies==i),aes(x=expectedz, y=equivz-expectedz, group=allgroups, colour=factor(Within)))

            subpl[[idx]]  <- subpl[[idx]]  + 
            geom_ribbon(
                aes(x=expectedz, ymin=z_lower-expectedz, ymax=z_upper-expectedz, group=glm), 
                fill="grey", alpha=.8, colour=NA) + 
            facet_grid(methods~nStudies, scales = "free", 
                       labeller = labeller(
                           methods = method_labels, 
                           nStudies = nstudies_labels,
                           soft2 = soft2_labels,
                           unitMism = units_labels)) + 
            theme(strip.text.x = element_text(size = 10)) + 
            ylab("Estimated - reference Z") + xlab("Reference Z") + 
            geom_line(aes(x=expectedz, y=0), colour="black") + 
            geom_line() +
    #         geom_point(size=0.5) + 
            theme(legend.position="none") 
            

    
            if (! is.na(lim[1])){
                if (length(lim) == 1){
                    currlim = lim
                } else {
                    currlim = lim[idx]
                }
                subpl[[idx]]  <- subpl[[idx]]  + scale_y_continuous(limits=c(-currlim, currlim), minor_breaks = seq(-currlim, currlim, by=0.05), breaks = seq(-currlim, currlim, by=0.1))
            }

            # + geom_ribbon(aes(x=expectedz, ymax = equivz_upper-expectedz, ymin= equivz_lower-expectedz), width=0.20) 

            # subpl[[i]] <- subpl[[i]] + geom_ribbon(aes(x=expectedz, ymin=z_lower-expectedz, ymax=z_upper-expectedz), fill="grey", alpha=.2, colour=NA) + facet_grid(Between + methods + nStudies + glm ~ unitMismatch+soft2Factor+ soft2, labeller=facet_labeller) + theme(strip.text.x = element_text(size = 16)) + ylab("Difference between estimated and reference z-statistic") + xlab("Reference z-statistic") + geom_line(aes(x=expectedz, y=0), colour="black") + geom_line() + geom_point(size=1) 
            idx = idx + 1
        }
    }
    
    if (mult){       
        p <- plot_grid(subpl[[1]], subpl[[2]], subpl[[3]], labels = '',ncol = 3)
        
        title <- ggdraw() + draw_label(paste("Small sample sizes:", title))
        p <- plot_grid(title, p, ncol=1, rel_heights=c(0.1, 1))

        legend <- get_legend(subpl[[1]] + theme(legend.position="bottom"))
        p <- plot_grid(p, legend, ncol = 1, rel_heights = c(1, .2))
        return(p)

        # multiplot(subpl[[1]], subpl[[2]], subpl[[3]], layout=matrix(c(1,2,3), nrow=1, byrow=TRUE))
        if (! is.na(filename)){
            pdf(paste(filename, ".pdf", sep=""))
            multiplot(subpl[[1]], subpl[[4]], subpl[[3]], layout=matrix(c(1,2,3,3), nrow=1, byrow=TRUE))
            dev.off()
        }
    } else {
        for (i in seq(1,length(subpl))){
            print(subpl[[i]])
            if (! is.na(filename)){
                pdf(paste(filename, ".pdf", sep=""))
                print(subpl[[i]])
                dev.off()
            }
        }
    }
}

