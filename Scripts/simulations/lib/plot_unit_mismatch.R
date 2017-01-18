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

#      # 


#     #methods=="permutCon" & Between==1 & nStudies==50 & numSubjectScheme=="identical" & varScheme=="identical" & Within==5)
#     #

#     # # # With the plot below, we can check if things went wrong (i.e. expected z-stat not incremental)
#     # p <- ggplot(data_subset, aes(as.factor(equivz), expectedz, colour=factor(paste(Within))))
#     # p + geom_boxplot() + stat_summary(fun.y=mean, colour="red", geom="point", shape=18, size=3,show_guide = FALSE) + facet_grid(methods+Between ~ nStudies+ numSubjectScheme) 

#     # p <- ggplot(data_subset, aes(as.factor(equivz), equivz-expectedz, colour=factor(paste(Within))))

#     subpl=list()
#     if (single){
#         subpl[[1]] <- ggplot(data=data,aes(x=expectedz, y=equivz-expectedz, group=allgroups, colour=factor(Within)))

#         subpl[[1]] <- subpl[[1]] + 
#                 geom_ribbon(
#                     aes(x=expectedz, ymin=z_lower-expectedz, ymax=z_upper-expectedz, group=glm), 
#                     fill="grey", alpha=.8, colour=NA) + 
#                 facet_grid(methods~unitMism+soft2, scales = "free", 
#                            labeller = labeller(
#                                methods = method_labels, 
#                                nStudies = label_both,
#                                soft2 = soft2_labels,
#                                unitMism = units_labels)) + 
#                 theme(strip.text.x = element_text(size = 10)) + 
#                 ylab("Estimated - reference Z") + xlab("Reference Z") + 
#                 geom_line(aes(x=expectedz, y=0), colour="black") + 
#                 geom_line() + 
#         #         geom_point(size=0.5) + 
#                 ggtitle(paste("Unit mismatch:", suffix)) + theme(legend.position="bottom") + coord_cartesian(ylim=c(-lim, lim))

#     } else {
#         # Bland-Altman like

#         for (i in 1:4){
#             subpl[[i]] <- ggplot(data=subplot[[i]],aes(x=expectedz, y=equivz-expectedz, group=allgroups, colour=factor(Within)))

#             subpl[[i]] <- subpl[[i]] + 
#                 geom_ribbon(
#                     aes(x=expectedz, ymin=z_lower-expectedz, ymax=z_upper-expectedz), 
#                     fill="grey", alpha=.2, colour=NA) + 
#                 facet_grid(methods~nStudies+soft2, scales = "free", 
#                            labeller = labeller(
#                                methods = method_labels, 
#                                nStudies = label_both,
#                                soft2 = soft2Factor_labels)) + 
#                 theme(strip.text.x = element_text(size = 10)) + 
#                 ylab("Estimated - reference Z") + xlab("Reference Z") + 
#                 geom_line(aes(x=expectedz, y=0), colour="black") + 
#                 geom_line() + 
#         #         geom_point(size=0.5) + 
#                 ggtitle(titles[[i]]) + theme(legend.position="none") + ylim(-1, 0.5)


#             # + geom_ribbon(aes(x=expectedz, ymax = equivz_upper-expectedz, ymin= equivz_lower-expectedz), width=0.20) 

#             # subpl[[i]] <- subpl[[i]] + geom_ribbon(aes(x=expectedz, ymin=z_lower-expectedz, ymax=z_upper-expectedz), fill="grey", alpha=.2, colour=NA) + facet_grid(Between + methods + nStudies + glm ~ unitMismatch+soft2Factor+ soft2, labeller=facet_labeller) + theme(strip.text.x = element_text(size = 16)) + ylab("Difference between estimated and reference z-statistic") + xlab("Reference z-statistic") + geom_line(aes(x=expectedz, y=0), colour="black") + geom_line() + geom_point(size=1) 
#         }
#     }
#     if (mult){
#         multiplot(subpl[[1]], subpl[[4]], subpl[[3]], layout=matrix(c(1,2,3,3), nrow=1, byrow=TRUE))
#         return("")
#         if (! is.na(filename)){
#             pdf(paste(filename, ".pdf", sep=""))
#             multiplot(subpl[[1]], subpl[[4]], subpl[[3]], layout=matrix(c(1,2,3,3), nrow=1, byrow=TRUE))
#             dev.off()
#         }
#     } else {
#         for (i in seq(1,length(subpl))){
#             print(subpl[[i]])
#             if (! is.na(filename)){
#                 pdf(paste(filename, ".pdf", sep=""))
#                 print(subpl[[i]])
#                 dev.off()
#             }
#         }
#     }
}