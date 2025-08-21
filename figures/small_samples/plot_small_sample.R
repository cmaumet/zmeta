plot_small_sample <- function(test_type=1, allsimudat=NA) {
    # Robustness under assumption violations

    # # for all methods
    require('cowplot')
    library('ggplot2')
    source(file.path('..','commons','get_expected_pval_and_equiv_z.R'))
    source(file.path('..','commons','multiplot.R'))
    source(file.path('..','commons','plot_lib.R'))
    source(file.path('..', 'commons','prepare_data.R'))
    source(file.path('..', 'commons','plot_unit_mismatch.R'))
    source(file.path('..', 'commons','plot_blandaldman_z.R'))
    source(file.path('..', 'commons','plot_grid_methods_color_within.R'))
    source(file.path('..', 'commons','plot_qq_p.R'))
    source(file.path('..', 'commons','load_data_from_files.R'))

    simu_dir = file.path('..', '..', 'results', 'simus')
    # theme_set(theme_gray()) # switch to default ggplot2 theme for good
    # theme_update(panel.background = element_rect(fill = "grey95"))
    # library(scales)

    iter = 38
    if (all(is.na(allsimudat))){
        allsimudat = load_data_from_files(simu_dir, iter, test_type)
    }

    # Method names in the dataframe
    # "fishers"      "stouffers"    "stouffersMFX" "weightedZ"    "megaRFX"     
    # "permutZ"      "permutCon"    "megaMFX"      "megaFFX_FSL"

    # colorblind-friendly palette
    # # Source: http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/
    cbfPalette <- c("#999999", "#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

    # # Figure
    source(file.path('..', 'commons','plot_grid_methods_color_within.R'))
    source(file.path('..', 'commons','plot_qq_p.R'))

    # Create a three-panel figure investigating robustness under:
    #  A. small sample sizes (FFX and MFX)
    #  B. heteroscedasticity (RFX and contrast permutation)
    #  C. heterogeneity (Fisher's, Stouffer's, FFX and Weighted Z)
    robutness_plot <- function(data){
        
        data_positive_z <- subset(data, expectedz>0 & (unitMism=="nominal"))

        large_sample_methods <- c("megaMFX","megaFFX_FSL")
        homoscedasticity_methods <- c("megaRFX","permutCon","stouffersMFX")
        homogeneity_methods <- c("megaFFX_FSL","fishers", "stouffers", "weightedZ")

        # Data verifying random/fixed-effect assumption for each method    
        data_rfx_assumption <- subset(data_positive_z, 
        ((methods %in% homogeneity_methods & Between==0) | 
         (!(methods %in% homogeneity_methods) & Between==1)) )
        
        # Data violating random/fixed-effect assumption for each method    
        data_not_rfx_assumption <- subset(data_positive_z, 
        ((methods %in% homogeneity_methods & Between==1) | 
         (!(methods %in% homogeneity_methods) & Between==0)) )
                  
        # Panel A: small samples - homoscedasticity
        p1 <- plot_qq_p(
                subset(data_rfx_assumption, methods %in% large_sample_methods & withinVariation==1),
                formula=methods~nStudies+nSubjects, "Small sample sizes: homoscedasticity") +
            theme(legend.position="right")  +
            scale_fill_manual(values=cbfPalette) + 
            scale_colour_manual(values=cbfPalette)

        # Panel B: small samples - heteroscedasticity
        p2 <- plot_qq_p(
                subset(data_rfx_assumption, methods %in% large_sample_methods & withinVariation!=1),
                formula=methods~nStudies+nSubjects, "Small sample sizes: heteroscedasticity") +
            theme(legend.position="right")  +
            scale_fill_manual(values=cbfPalette) + 
            scale_colour_manual(values=cbfPalette)
        
        # # Panel B: heteroscedasticity
        # p2 <- plot_qq_p(
        #         subset(data_rfx_assumption, methods %in% homoscedasticity_methods &
        #                                     nSubjects==20 & nStudies==25+25*(data$glm[1] > 1)),
        #         formula=.~methods, "Heteroscedasticity", short=TRUE) + 
        #     theme(legend.position="none") + 
        #     scale_fill_manual(values=cbfPalette) + 
        #     scale_colour_manual(values=cbfPalette)

        # # Panel C: heterogeneity
        # p3 <- plot_qq_p(
        #         subset(data_not_rfx_assumption, methods %in% homogeneity_methods & 
        #                                         nStudies==25+25*(data$glm[1] > 1) & nSubjects==20), 
        #         formula=.~methods, 
        #         title="Heterogeneity", short=TRUE, lim=10) + 
        #     theme(legend.position="none") + ylab(NULL) + 
        #     scale_fill_manual(values=cbfPalette) + 
        #     scale_colour_manual(values=cbfPalette)
        
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
            'Robustness of the meta-analytic estimators under assumption violations')
        p <- plot_grid(title, p, ncol=1, rel_heights=c(0.1, 1)) + 
            theme(plot.title=element_text(size=12), text=element_text(size=10))

        return(p)
    }

    p <- robutness_plot(allsimudat)

    # print on screen
    print(p)

    # Save to pdf
    pdf(paste("robustness_2.pdf", sep=""))
    print(p)
    dev.off()
}