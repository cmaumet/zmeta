plot_blandaldman_z <- function(data, formula, title, mult, lim, filename, max_z=NA){
    data <- prepare_data(data, max_z)
    
    if (! mult) {
        p <- ggplot(data=data[[1]],aes(x=expectedz, y=equivz-expectedz, group=allgroups, colour=factor(Within)))
        p <- p + 
            geom_ribbon(
                aes(x=expectedz, ymin=z_lower-expectedz, ymax=z_upper-expectedz, group=glm), 
                fill="grey", alpha=.8, colour=NA) + 
            facet_grid(formula, scales = "free", 
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
            ggtitle(title) + theme(legend.position="bottom") 
    
        if (! is.na(lim)){
            p <- p + coord_cartesian(ylim=c(-lim, lim))
        }
    } else {
        subpl=list()
        for (idx in seq(1,length(data))){
            subpl[[idx]] <- ggplot(data=data[[idx]],aes(x=expectedz, y=equivz-expectedz, group=allgroups, colour=factor(Within))) 
            subpl[[idx]]  <- subpl[[idx]]  + 
            geom_ribbon(
                aes(ymin=z_lower-expectedz, ymax=z_upper-expectedz, group=glm), 
                fill="grey", alpha=.8, colour=NA) + 
            facet_grid(formula, scales = "free", 
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
        }
    }
    
    if (mult){       
        p <- plot_grid(subpl[[1]], subpl[[2]], subpl[[3]], labels = '',ncol = 3)
        
        title <- ggdraw() + draw_label(title)
        p <- plot_grid(title, p, ncol=1, rel_heights=c(0.1, 1))

        legend <- get_legend(subpl[[1]] + theme(legend.position="bottom"))
        p <- plot_grid(p, legend, ncol = 1, rel_heights = c(1, .2))
        print(p)

        if (! is.na(filename)){
            pdf(paste(filename, ".pdf", sep=""))
            print(p)
            dev.off()
        }
    } else {
        print(p)
        if (! is.na(filename)){
            pdf(paste(filename, ".pdf", sep=""))
            print(p)
            dev.off()
        }
    }
    return(p)
}
    