plot_simulations <- function(test_type=1, allsimudat=NA) {
# # Robustness to units mismatch


require('cowplot')
library('ggplot2')
source(file.path('..', 'commons','get_expected_pval_and_equiv_z.R'))
source(file.path('..', 'commons','plot_grid_methods_color_within.R'))
source(file.path('..', 'commons','multiplot.R'))
source(file.path('..', 'commons','prepare_data.R'))
source(file.path('..', 'commons','plot_lib.R'))
source(file.path('..', 'commons','plot_qq_p.R'))
source(file.path('..', 'commons','load_data_from_files.R'))

theme_set(theme_gray()) # switch to default ggplot2 theme for good
theme_update(panel.background = element_rect(fill = "grey95"))
# theme_set(theme_gray() + theme(panel.background = element_blank()))
# theme_set(theme_bw() + theme(panel.border = element_blank())) # switch to default ggplot2 theme for good

# colorblind-friendly palette
# Source: http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/
cbfPalette <- c("#999999", "#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

simu_dir = file.path('..', '..', 'results', 'simus')

# - We look how contrast-based methods are affected by the units issue.
# ## One-sample tests

iter = 38

# - Load data from the CSV files

kn = "k025_n20"
if (all(is.na(allsimudat))){
    allsimudat_btw1 <- load_data_from_csv(paste('^test1_', kn, '_btw1.*', sep=""), simu_dir, iter)
    allsimudat <- rbind(allsimudat_btw1)

    allsimudat$withinVar <- allsimudat$Within/allsimudat$nSubjects

    allsimudat$methods <- factor(allsimudat$methods, levels=c("fishers",
        "stouffers", "weightedZ", "megaRFX", "permutCon", 
        "stouffersMFX", "permutZ", "megaMFX", "megaFFX_FSL"))

    allsimudat$unitMism <- factor(allsimudat$unitMism, 
        levels=c("nominal", "datascl", "contscl"))
}

# if (all(is.na(allsimudat))){
#     allsimudat = load_data_from_files(simu_dir, iter, test_type)
# }

# ## Plots
# ### Main figure

source(file.path('..', 'commons','plot_grid_methods_color_within.R'))
units_plot <- function(data, max_z=NA, lim=NA){
    
    con_methods <- c("megaMFX","megaRFX","permutCon")
    con_data <- subset(data, is.finite(expectedz) & expectedz>0  &  methods %in% con_methods)


    # # Panel A: heteroscedasticity
    # p1 <- plot_qq_p(
    #          subset(data_positive_z, methods %in% homoscedasticity_methods &
    #                                      nSubjects==20 & nStudies==25+25*(data$glm[1] > 1) &
    #                                      withinVariation!=1),
    #         formula=Between~methods, "Heteroscedasticity", short=TRUE) + 
    #     theme(legend.position="right") + 
    #     scale_fill_manual(values=cbfPalette) + 
    #     scale_colour_manual(values=cbfPalette, name = expression(alpha))

    # # Panel B: homoscedasticity (under ass)
    # p2 <- plot_qq_p(
    #         subset(data_positive_z, methods %in% homoscedasticity_methods &
    #                                      nSubjects==20 & nStudies==25+25*(data$glm[1] > 1) &
    #                                      withinVariation==1),
    #         formula=Between~methods, "Homoscedasticity", short=TRUE) + 
    #     theme(legend.position="right") + 
    #     scale_fill_manual(values=cbfPalette) + 
    #     scale_colour_manual(values=cbfPalette, name = expression(sigma[i]^2))

    
    p1 <- plot_qq_p(subset(con_data, nSubjects==20 & nStudies==25+25*(data$glm[1] > 1) &
                                         withinVariation==1),  
              methods~unitMism+soft2, 
              "Within study variance - Homogneous Value (Homoscedasticity)",
              mult=FALSE, lim=lim, filename=NA, max_z=max_z) +  
        theme(legend.position="right") + 
        scale_fill_manual(values=cbfPalette) + 
        scale_colour_manual(values=cbfPalette, name = expression(sigma[i]^2))

    p2 <- plot_qq_p(subset(con_data, nSubjects==20 & nStudies==25+25*(data$glm[1] > 1) &
                                         withinVariation!=1),  
              methods~unitMism+soft2, 
              "Within study variance - Heterogeneous Value (Heteroscedasticity)", 
              mult=FALSE, lim=lim, filename=NA, max_z=max_z) + 
        theme(legend.position="right") + 
        scale_fill_manual(values=cbfPalette) + 
        scale_colour_manual(values=cbfPalette, name = expression(alpha))


    # Organise the figure: title, panel A at the top, panel B and C in a second row
    top_row <- plot_grid(p1, labels = 'A', ncol=1)
   
    if (data$glm[1] == 1){
        # For one-sample tests we have many methods to check under heterogeneity        
        widths = c(0.4, 0.75)
    } else {
        # For two-sample tests we only have one method to check under heterogeneity
        widths = c(0.6, 0.4)
    }
    
    # bottom_row <- plot_grid(p2, p3, labels = c('B', 'C'), ncol=2, rel_widths=widths)
    bottom_row <- plot_grid(p2, labels = c('B'), ncol=1)

    p <- plot_grid(top_row, bottom_row, labels = ' ', ncol=1)
    title <- ggdraw() + draw_label(
        'Robustness under contrasts with mismatched units, one-sample') 
    p <- plot_grid(title, p, ncol=1, rel_heights=c(0.1, 1)) 

    return(p)
}

p <- units_plot(allsimudat)

    # print on screen
    print(p)

    # Save to pdf
    pdf(paste("robustness_unitmismatch.pdf", sep=""))
    print(p)
    dev.off()


# # # Two-sample tests

# # ## Load data from the CSV files


# # allsimudat2_btw0 <- load_data_from_csv('^test2_k025_n20_btw0_.*', simu_dir, iter)
# allsimudat2_btw1 <- load_data_from_csv('^test2_k025_n20_btw1_.*', simu_dir, iter)
# allsimudat2 <- rbind(allsimudat2_btw1)



# best_con_data_2 <- subset(allsimudat2, 
#     ((methods %in% c("megaMFX") & Between==1) | 
#      (methods %in% c("megaRFX") & Between==1) | 
#      (methods %in% c("megaFFX_FSL") & Between==0) |
#      (methods %in% c("permutCon"))
#     ))

# # best_con_data_2_nom_ok <- subset(best_con_data_2, 
# #     (methods %in% c("megaMFX") & withinVariation<4) |
# #     (methods %in% setdiff(methods, c("megaFFX_FSL", "megaMFX"))))

# # ## Main figure

# p <- units_plot(best_con_data_2)

# # print on screen
# print(p)

# # Save to pdf
# pdf(paste("units_test2.pdf", sep=""))
# print(p)
# dev.off()

# # # Unbalanced two-sample tests
# # ## Load data from the CSV files

# allsimudat3_btw1 <- load_data_from_csv('^test3_k025_n20_btw1_.*', simu_dir, iter)
# allsimudat3 <- rbind(allsimudat3_btw1)

# # con_data_3 <- subset(allsimudat3, is.finite(expectedz) & expectedz>0 & methods %in% con_methods)
# best_con_data_3 <- subset(allsimudat3, 
#     ((methods %in% c("megaMFX") & Between==1) | 
#      (methods %in% c("megaRFX") )  | 
#      (methods %in% c("megaFFX_FSL") & Between==0) |
#      (methods %in% c("permutCon"))
#     ) & nStudies==50)

# # plot_unit_mismatch(
# #     subset(best_con_data_3,((methods %in% c("megaRFX") & Between==1) | !(methods %in% c("megaRFX")))),
# #     'unbalanced two-sample test', mult=FALSE, single=TRUE, lim=NA,
# #      filename=file.path("..", "..", "zmeta_paper", "figures", "unitmimatch_test3"), max_z=4)

# p <- units_plot(
#     subset(best_con_data_3,((methods %in% c("megaRFX") & Between==1) 
#                             | !(methods %in% c("megaRFX")))))

# # print on screen
# print(p)

# # Save to pdf
# pdf(paste("units_test3.pdf", sep=""))
# print(p)
# dev.off()

# ### Think about the above plot: with max_z=4, we see a quite different picture...

# p <- units_plot(
#     subset(best_con_data_3,((methods %in% c("megaRFX") & Between==1) 
#                             | !(methods %in% c("megaRFX")))), max_z=4)

# print(p)

# ### Think about the above plot: with max_z=4, we see a quite different picture...

# p <- units_plot(
#     subset(best_con_data_2,((methods %in% c("megaRFX") & Between==1) 
#                             | !(methods %in% c("megaRFX")))), max_z=4)

# print(p)

# ### Think about the above plot: with max_z=4, we see a quite different picture...

# p <- units_plot(allsimudat, max_z=4)

# print(p)

    return(allsimudat)
}