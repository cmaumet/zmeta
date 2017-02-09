plot_qq_p <- function(data, formula, title, mult, lim, filename, max_z=NA){
    
    # data, aes_main, aes_ribbon, formula, title, mult, lim, filename, max_z=NA
    
    # plot_grid_methods_color_within(data,
    #     aes_main=aes(x=-log10(expectedP), y=-log10(P), group=allgroups, colour=factor(Within)),
    #     aes_line=aes(x=-log10(expectedP), y=-log10(expectedP)),
    #     aes_ribbon=aes(ymin=-log10(p_lower), ymax=-log10(p_upper), group=glm), formula, title, mult, lim, filename, max_z=NA,
    #     xlabel="-log10(expected P)", ylabel="-log10(P)")
    
    if (! is.na(filename)){
        filename = paste(filename, "_p", sep="")
    }
    
    plot_grid_methods_color_within(data,
        aes_main=aes(x=-log10(expectedP), y=-log10(P)-(-log10(expectedP)), group=allgroups, colour=factor(Within)),
        aes_line=aes(x=-log10(expectedP), y=0),
        aes_ribbon=aes(ymin=-log10(p_lower)-(-log10(expectedP)), ymax=-log10(p_upper)-(-log10(expectedP)), group=glm), formula, title, mult, -log10(lim), filename, max_z,
        xlabel="-log10(expectedP)", ylabel="-log10(P)-(-log10(expectedP))")
    
#     data <- prepare_data(data, max_z, min_z=0)
    
#     if (! mult) {
#         p <- ggplot(data=data[[1]],aes(x=-log10(expectedP), y=-log10(P), group=allgroups, colour=factor(Within)))
#         p <- p + 
#             geom_ribbon(
#                 aes(x=-log10(expectedP), ymin=-log10(p_lower), ymax=-log10(p_upper), group=glm), 
#                 fill="grey", alpha=.8, colour=NA) + 
#             facet_grid(formula, scales = "free", 
#                        labeller = labeller(
#                            methods = method_labels, 
#                            nStudies = label_both,
#                            soft2 = soft2_labels,
#                            unitMism = units_labels)) + 
#             theme(strip.text.x = element_text(size = 10)) + 
#             ylab("-log10(P)") + xlab("-log10(expected P)") + 
#             geom_line(aes(x=-log10(expectedP), y=-log10(expectedP)), colour="black") + 
#             geom_line() + 
#     #         geom_point(size=0.5) + 
#             ggtitle(title) + theme(legend.position="bottom") 
    
#         if (! is.na(lim)){
#             p <- p + coord_cartesian(ylim=c(-lim, lim))
#         }
#     } else {
#         subpl=list()
#         for (idx in seq(1,length(data))){
#             subpl[[idx]] <- ggplot(data=data[[idx]],aes(x=-log10(expectedP), y=-log10(P), group=allgroups, colour=factor(Within))) 
#             subpl[[idx]]  <- subpl[[idx]]  + 
#             geom_ribbon(
#                 aes(ymin=-log10(p_lower), ymax=-log10(p_upper), group=glm), 
#                 fill="grey", alpha=.8, colour=NA) + 
#             facet_grid(formula, scales = "free", 
#                        labeller = labeller(
#                            methods = method_labels, 
#                            nStudies = nstudies_labels,
#                            soft2 = soft2_labels,
#                            unitMism = units_labels)) + 
#             theme(strip.text.x = element_text(size = 10)) + 
#             ylab("-log10(P)") + xlab("-log10(expected P)") +  + 
#             geom_line(aes(x=-log10(expectedP), y=-log10(expectedP)), colour="black") + 
#             geom_line() +
#     #         geom_point(size=0.5) + 
#             theme(legend.position="none") 
            

    
#             if (! is.na(lim[1])){
#                 if (length(lim) == 1){
#                     currlim = lim
#                 } else {
#                     currlim = lim[idx]
#                 }
#                 subpl[[idx]]  <- subpl[[idx]]  + scale_y_continuous(limits=c(-currlim, currlim), minor_breaks = seq(-currlim, currlim, by=0.05), breaks = seq(-currlim, currlim, by=0.1))
#             }

#             # + geom_ribbon(aes(x=expectedP, ymax = P_upper-expectedP, ymin= P_lower-expectedP), width=0.20) 

#             # subpl[[i]] <- subpl[[i]] + geom_ribbon(aes(x=expectedP, ymin=p_lower-expectedP, ymax=p_upper-expectedP), fill="grey", alpha=.2, colour=NA) + facet_grid(Between + methods + nStudies + glm ~ unitMismatch+soft2Factor+ soft2, labeller=facet_labeller) + theme(strip.text.x = element_text(size = 16)) + ylab("Difference between estimated and reference z-statistic") + xlab("Reference z-statistic") + geom_line(aes(x=expectedP, y=0), colour="black") + geom_line() + geom_point(size=1) 
#         }
#     }
    
#     if (mult){       
#         p <- plot_grid(subpl[[1]], subpl[[2]], subpl[[3]], labels = '',ncol = 3)
        
#         title <- ggdraw() + draw_label(title)
#         p <- plot_grid(title, p, ncol=1, rel_heights=c(0.1, 1))

#         legend <- get_legend(subpl[[1]] + theme(legend.position="bottom"))
#         p <- plot_grid(p, legend, ncol = 1, rel_heights = c(1, .2))
#         print(p)

#         if (! is.na(filename)){
#             pdf(paste(filename, "_p.pdf", sep=""))
#             print(p)
#             dev.off()
#         }
#     } else {
#         print(p)
#         if (! is.na(filename)){
#             pdf(paste(filename, "_p.pdf", sep=""))
#             print(p)
#             dev.off()
#         }
#     }
#     return(p)
}
    