plot_grid_methods_color_within <- function(data, aes_main, aes_line, aes_ribbon, formula, title, mult, lim, filename, max_z=NA,xlabel="", ylabel=""){
    data <- prepare_data(data, max_z)
    # cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
    
    # scale_colour_manual(values=cbPalette)

    if (! mult) {
        p <- ggplot(data=data[[1]][with(data[[1]], order(allgroups, withinInfo)), ],aes_main)
        p <- p + 
            geom_ribbon(
                aes_ribbon, 
                fill="grey", alpha=.8, colour=NA) + 
            facet_grid(formula,  
                       labeller = labeller(
                           methods = method_labels, 
                           nStudies = nstudies_labels,
                           nSubjects = nsubjects_labels,
                           soft2 = soft2_labels,
                           Between=between_labels,
                           glm=test_labels,
                           unitMism = units_labels)) + 
            theme(strip.text.x = element_text(size = 8)) +
            theme(strip.text.y = element_text(size = 6)) +
            ylab(ylabel) + xlab(xlabel) + 
            geom_line(aes_line, colour="black") + theme(legend.position="bottom")
    #         geom_point(size=0.5) + 
            

        if (title != "") {
            p <- p + ggtitle(title)
        }

        # joint_palette <- c("#fee090", "#fdae61", "#f46d43", "#d73027", "#a50026", # "#e0f3f8",
        #                     "#abd9e9", "#74add1", "#4575b4", "#313695")

        # p <- p + geom_line(data=data[[1]][data[[1]]$withinVariation==1,])
        p <- p + geom_line()
         # + scale_colour_manual(values = joint_palette)
    
        if (! is.na(lim)){
            p <- p + coord_cartesian(ylim=c(-0.5, lim))
        } else {
            # Limit plot to max of 95% CI ribbon
            # max_ribbon = max(with(data[[1]], eval(aes_ribbon$ymax)))
            # min_ribbon = min(with(data[[1]], eval(aes_ribbon$ymin)))
            max_ribbon=1.5
            min_ribbon=-0.5
            p <- p + coord_cartesian(ylim=c(min_ribbon, max_ribbon))
        }
    } else {
        subpl=list()
        for (idx in seq(1,length(data))){
            subpl[[idx]] <- ggplot(data=data[[idx]], aes_main) 
            subpl[[idx]]  <- subpl[[idx]]  + 
            geom_ribbon(
                aes_ribbon, 
                fill="grey", alpha=.8, colour=NA) + 
            facet_grid(formula,  
                       labeller = labeller(
                           methods = method_labels, 
                           nStudies = nstudies_labels,
                           nSubjects = nsubjects_labels,
                           soft2 = soft2_labels,
                           Between=between_labels,
                           glm=test_labels,
                           unitMism = units_labels)) + 
            theme(strip.text.x = element_text(size = 8))  +
            theme(strip.text.y = element_text(size = 6)) + theme(aspect.ratio = 1) +
            ylab(ylabel) + xlab(xlabel) + 
            geom_line(aes_line, colour="black") + 
            geom_line() +
    #         geom_point(size=0.5) + 
            theme(legend.position="none") 
            

    
            if (! is.na(lim[1])){
                if (length(lim) == 1){
                    currlim = lim
                } else {
                    currlim = lim[idx]
                }
                subpl[[idx]]  <- subpl[[idx]]  + scale_y_continuous(limits=c(-currlim, currlim), minor_breaks = seq(-currlim, currlim, by=0.05), 
                    breaks = seq(-currlim, currlim, by=0.1))
            }

            # + geom_ribbon(aes(x=expectedz, ymax = equivz_upper-expectedz, ymin= equivz_lower-expectedz), width=0.20) 

            # subpl[[i]] <- subpl[[i]] + geom_ribbon(aes(x=expectedz, ymin=z_lower-expectedz, ymax=z_upper-expectedz), fill="grey", alpha=.2, colour=NA) + facet_grid(Between + methods + nStudies + glm ~ unitMismatch+soft2Factor+ soft2, labeller=facet_labeller) + theme(strip.text.x = element_text(size = 16)) + ylab("Difference between estimated and reference z-statistic") + xlab("Reference z-statistic") + geom_line(aes(x=expectedz, y=0), colour="black") + geom_line() + geom_point(size=1) 
        }
    }
    
    if (mult){       
        p <- plot_grid(plotlist=subpl, labels = '',ncol = length(subpl), rel_widths = c(2, 1))
        
        title <- ggdraw() + draw_label(title)
        p <- plot_grid(title, p, ncol=1, rel_heights=c(0.1, 1))

        legend <- get_legend(subpl[[1]] + theme(legend.position="bottom"))
        p <- plot_grid(p, legend, ncol = 1, rel_heights = c(1, .2))
        # print(p)

        if (! is.na(filename)){
            pdf(paste(filename, ".pdf", sep=""))
            print(p)
            dev.off()
        }
    } else {
        # print(p)
        if (! is.na(filename)){
            pdf(paste(filename, ".pdf", sep=""))
            print(p)
            dev.off()
        }
    }
    return(p)
}
    