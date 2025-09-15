real_data <- function(test_type=1, allsimudat=NA) {
# # for all methods
    require('cowplot')
    library('ggplot2')
    source(file.path(getwd(), 'commons','load_data_from_files.R'))
    source(file.path(getwd(), 'commons','plot_lib.R'))
    source(file.path(getwd(), 'commons','get_expected_pval_and_equiv_z.R'))

    simu_dir = file.path(getwd(), '..', 'data', 'derived', 'simus')
    # theme_set(theme_gray()) # switch to default ggplot2 theme for good
    # theme_update(panel.background = element_rect(fill = "grey95"))
    # library(scales)

    # iter = 38
    # if (all(is.na(allsimudat))){
    #     print(simu_dir)
    #     allsimudat <- load_data_from_csv(paste('^test', test_type, '_k025_n20.*_nominal*', sep=""), simu_dir, iter)
    # }
    simufpr <- read.csv(file.path('..', 'results', 'allsimudat_test1_k025_n20_nominal_38.csv'))

    theme_set(theme_gray()) # switch to default ggplot2 theme for good
    theme_update(panel.background = element_rect(fill = "grey95"))

    realdata <- read.csv(file.path('..', 'results', 'realdata_TPR.csv'), header=T, sep=",")
    realdata$Method <- as.factor(realdata$Method)

    p <- ggplot(data=subset(realdata, p<0.1),aes(x=(p), y=TPR, group=Method, colour=factor(Method))) + 
    geom_line() + ggtitle('real data: ROC curve using theoretical FPR') + theme(legend.position = 'bottom')

    print(p)

    # Only looking at nominal data under some heterogeneity
    allsimudat <- subset(simufpr, Between==1 & unitMism=='nominal')

    head(simufpr) 

    realdata_withsimuFPR = data.frame()

    for (within in unique(simufpr$Within)){
        print(paste("within=", within))
    for (variation in unique(simufpr$withinVariation)){
        print(paste("variation=",variation))
        currdat <- realdata
        currdat$withinVariation <- variation
        currdat$Between <- 1
        currdat$Within <- within
        currdat$FPR <- NA

        methods <- levels(realdata$Method)
        length(methods)
        
        for (meth in methods){
            print(paste('Currently: ', meth))

            th_p = currdat[currdat$Method==meth,]$p

            # Fix mismatch naming between TPR computation and simulations
            if (meth=="megaFFX"){ 
                meth_simu = "megaFFX_FSL";
            }    else{
                meth_simu = meth;
            }
           
            sub_df = subset(simufpr, Between==1 & Within==within & withinVariation==variation & methods == meth_simu)
            
            if (nrow(sub_df)>0){
                approximated = approx(x=sub_df$P, y=sub_df$expectedP, xout=th_p, yleft=0)
                 plot(sub_df$P, sub_df$expectedP, main = "approx")
                 points(approximated, col = 2, pch = "*")
                currdat[currdat$Method==meth,]$FPR <- approximated$y
            } else {
                print("sub_df no rows")
                # return('stopping here')
            }
        }
        
    #     currdat[currdat$p==0,]$FPR <- 0
    #     print(currdat[currdat$p==0,]$FPR) 
        if (! all(is.na(currdat$FPR))){
            print("not all nan")
            currdat[currdat$p==1,]$FPR <- 1
            realdata_withsimuFPR <- rbind(realdata_withsimuFPR, currdat) } 
        else {
            print("ALL nan")
        }
        
    }
    }

    # for (within in setdiff(unique(simufpr$Within), c(20, 40))){
    #     currdat <- realdata
    #     currdat$withinVariation <- 1
    #     currdat$Between <- 1
    #     currdat$Within <- within
    #     currdat$FPR <- NA

    #     methods <- levels(realdata$Method)
    #     length(methods)
        
    #     for (meth in methods){
    # #         print(paste('Currently: ', meth))
    #         th_p = currdat[currdat$Method==meth,]$p
           
    #         sub_df = subset(simufpr, Between==1 & Within==within & withinVariation==1 & methods == meth)
            
    #         approximated = approx(x=sub_df$P, y=sub_df$expectedP, xout=th_p, yleft=0)
    # #         plot(sub_df$P, sub_df$expectedP, main = "approx")
    # #         points(approximated, col = 2, pch = "*")
    #          currdat[currdat$Method==meth,]$FPR <- approximated$y

    #     }
        
    #     currdat[currdat$p==1,]$FPR <- 1
    # #     print(currdat[currdat$p==0,]$FPR) 

    #     realdata_withsimuFPR <- rbind(realdata_withsimuFPR, currdat)
    # }

    # simufpr_homo <- subset(simufpr, withinVariation==1 & Between==1 & Within==20)

    # simufpr_out16 <- subset(simufpr, withinVariation==16 & Between==1) 
    # names(simufpr_out16)

    # print(levels(simufpr_out16$methods))
    # print('--')
    # print(levels(realdata$Method))



    tail(realdata_withsimuFPR[is.na(realdata_withsimuFPR$FPR),])



    unique(simufpr$Within)

    head(subset(realdata_withsimuFPR, Method=='permutCon'))

    realdata_withsimuFPR$heterogeneity <- realdata_withsimuFPR$Between/realdata_withsimuFPR$Within*20





    heterogeneity_labels <- function(value) {
        value <- paste("tau2 =", value, 'x sigma2/20')
        value
    }

    heteroscedasticity_labels <- function(value) {
        value <- paste("sigma2/20 ~ 1..", value)
        value
    }

    method_labels <- function(string) {
        string[string=="megaMFX"] <- "MFX"
        string[string=="megaRFX"] <- "RFX"
        string[string=="permutCon"] <- "Perm. E"
        string[string=="permutZ"] <- "Perm. Z"
        string[string=="stouffers"] <- "Stouffer's"
        string[string=="fishers"] <- "Fisher's"
        string[string=="fishers"] <- "Fisher's"
        string[string=="weightedZ"] <- "Weighted Z"
        string[string=="megaFFX_FSL"] <- "FFX"
        string
    }

    roc_plot <- function(data, aes_line, ylim=c(0.5, 1), xlim=c(0, 0.1)) {
        
        # colorblind-friendly palette
        # Source: http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/

        cbbPalette <- c("#999999", "#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
    # print(names(data))
    # print(("p" %in% names(data)))
        if ("p" %in% names(data)){
            data$p <- data$p*100
        } 

    #     print("FPR" %in% names(data))
        
        if ("FPR" %in% names(data)){
            data$FPR <- data$FPR*100
        } 
        
        data$TPR <- data$TPR*100
        
        p <- ggplot(data=data,aes(group=Method, colour=factor(Method))) + 
        geom_line(aes_line)   + coord_cartesian(xlim = xlim*100, ylim = ylim*100 ) + 
        scale_x_continuous(breaks=seq(0,100,5)) +
        scale_y_continuous(breaks=seq(0,100,10)) + 
        scale_fill_manual(values=cbbPalette) + 
        scale_colour_manual(values=cbbPalette)
        
        return(p)
    }
        

    roc_plots_with_zoom <- function(data, facet_formula, ttl=''){
         # Panel B: Against simulated FPR & under varying levels of heterogenerity
        p2 <- roc_plot(data, aes(x=FPR, y=TPR)) + 
                facet_grid(facet_formula, labeller = labeller(heterogeneity = heterogeneity_labels,
                               withinVariation = heteroscedasticity_labels)) + 
            geom_rect(aes(xmin=0, xmax=2.5, ymin=85,ymax=95), alpha=0.2, color="grey", fill=NA, size=0.1) +   
                    ggtitle(ttl)
    #         geom_rect(mapping=aes(xmin=0, xmax=2.5, ymin=85, ymax=95), color="black", alpha=0.5, fill=NA)
        
        p3 <- roc_plot(data, aes(x=FPR, y=TPR), 
                       c(.85, .95), c(0, 0.025)) + 
                facet_grid(facet_formula, labeller = labeller(heterogeneity = heterogeneity_labels,
                               withinVariation = heteroscedasticity_labels)) 
        
        rect <- data.frame(xmin=0, xmax=0.025, ymin=.85, ymax=.95)

        
        
        start = 0.075
        decalage = 0.03
        p2 <- ggdraw() +
          draw_plot(p2 + theme(legend.justification = "bottom"), 0, 0, 1, 1) +
          draw_plot(p3 + ylab("  ") + xlab("  ") +
          theme(panel.border = element_rect(linetype = "solid", fill = NA), axis.title=element_blank(),
            strip.background = element_blank(),
           strip.text.x = element_blank(),
            plot.background=element_blank(),
            axis.text=element_blank(),
            axis.ticks=element_blank(), panel.spacing.x=unit(2.5, "lines")) + 
                    theme(legend.justification = "top"),start+decalage , 0.125, 1-start-2*decalage, 0.40) 

        res <- list("p" = p2, "legend" = get_legend(p3 + theme(legend.position="bottom")))
        return(res)
    }

    roc_plots <- function(data){
                  
    #     # Panel A: Against theoretical FPR
    #     p1 <- roc_plot(subset(realdata, p<0.1 & TPR>0.8), aes(x=p, y=TPR)) + 
    #             theme(legend.position="bottom", legend.direction='vertical') + coord_fixed(ratio = 1)
        
    #     # Panel B: Against simulated FPR & under varying levels of heterogenerity
    #     p1 <- roc_plot(subset(realdata_withsimuFPR, withinVariation==1 & Within==20), aes(x=FPR, y=TPR)) + 
    #             facet_grid(.~heterogeneity, labeller = labeller(withinVariation = group_var_labels)) + ggtitle('Homo') + theme(legend.position="none") +
    #             theme(legend.position="bottom", legend.direction='vertical')
        
       
        
    #     p2 <- ggplot(data=subset(realdata_withsimuFPR, FPR<=0.10 & TPR>0.75 & withinVariation==1),
    #             aes(x=FPR, y=TPR, group=Method, colour=factor(Method))) + geom_point(size=0.02) + geom_line() + 
        p2 <- roc_plots_with_zoom(subset(realdata_withsimuFPR, withinVariation==1 & Within!=20), .~heterogeneity, 'Heterogeneity')
        

        
        
        # Panel C: Against simulated FPR & under heteroscedasticity
        p3 <- roc_plots_with_zoom(subset(realdata_withsimuFPR, withinVariation>1), .~withinVariation, 'Heteroscedasticity')
        
    #     p3 <- roc_plot(subset(realdata_withsimuFPR, withinVariation>1), aes(x=FPR, y=TPR)) + 
    #             facet_grid(.~withinVariation, labeller = labeller(heterogeneity = heterogeneity_labels,
    #                            withinVariation = heteroscedasticity_labels)) + ggtitle('Heteroscedasticity') + theme(legend.position="none")

    #     ggplot(data=subset(realdata_withsimuFPR, FPR<=0.10 & TPR>0.75 & withinVariation>1),
    #             aes(x=FPR, y=TPR, group=Method, colour=factor(Method))) + 
    #     geom_point(size=0.02) + geom_line() + 

        
        # Organise the figure: title, panel A at the top, panel B and C in a second row
    #     right_column <- plot_grid(p1, labels = 'A', ncol=1)
       
        
        left_column <- plot_grid(p2$p, p3$p, labels = c('A', 'B'), ncol=1)
        
    #     p <- plot_grid(right_column, left_column, labels = ' ', ncol=2, rel_widths=c(1, 3))
        title <- ggdraw() + draw_label('ROC plots')
    #     legend <- get_legend(p3 + theme(legend.position="bottom"))
    #     p <- plot_grid(p, p3$legend, ncol = 1, rel_heights = c(1, .2))
        
        p <- plot_grid(title, left_column, p3$legend, ncol=1, rel_heights=c(0.1, 1, 0.1)) + 
            theme(plot.title=element_text(size=12), text=element_text(size=10))

        return(p)
    }

    realdata_withsimuFPR = subset(realdata_withsimuFPR)
    p <- roc_plots(subset(realdata)); print(p)

    # print on screen
    print(p)

    # Save to pdf
    pdf(paste("roc.pdf", sep=""))
    print(p)
    dev.off()



    simple_auc <- function(sens, spec){
    #     Sources: https://stats.stackexchange.com/questions/145566/how-to-calculate-area-under-the-curve-auc-or-the-c-statistic-by-hand
    #     print(order(sens, spec))
        
        height = (sens[-1]+sens[-length(sens)])/2
        width = -diff(spec) # = diff(rev(omspec))
        sum(height*width)
    }

    my_dat <- (subset(realdata_withsimuFPR, Method=='megaRFX' & withinVariation==16))
    simple_auc(my_dat$TPR, 1-my_dat$FPR)

    auc_df <- data.frame()

    for (within in unique(realdata_withsimuFPR$Within)){
        for (variation in unique(realdata_withsimuFPR$withinVariation)){

            methods <- levels(realdata_withsimuFPR$Method)
            print(methods)

            for (meth in methods){

                sub_df = subset(realdata_withsimuFPR, Between==1 & Within==within & withinVariation==variation & Method == meth)
                if (nrow(sub_df)>0){
    #                 print(head(sub_df))
            #         print(length(sub_df$TPR))
            #         print(unique(sub_df$Method))
                    auc_value = simple_auc(sub_df$TPR, 1-sub_df$FPR)
                    auc_df <- rbind(auc_df, data.frame(withinVariation = variation, 
                                                       Within = within,
                                                      Between=1,
                                                      auc=auc_value,
                                                  methods=meth))
                }
        }
        }
    }

    head(auc_df)

    print(auc_df[(auc_df$auc)>1,])

    # p <- ggplot(data=auc_df, aes=aes(x=Within, y=auc_value)) + geom_point()
    # print(p)

    p1 <- ggplot(data=subset(auc_df,withinVariation==1),aes(x=Within, y=auc, group=methods, colour=methods)) + 
    geom_line() + ggtitle('heterogeneity') + 
    coord_cartesian(ylim = c(0.94, 0.96)) 

    p2 <- ggplot(data=subset(auc_df,withinVariation>1),aes(x=withinVariation, y=auc, group=methods, colour=methods)) + 
    geom_line() + ggtitle('heteroscedasticity') + 
    coord_cartesian(ylim = c(0.945, 0.9555)) 

    row <- plot_grid(p1, p2, labels = c('A', 'B'), ncol=1)
        
    # title <- ggdraw() + draw_label('AUC plots')
    # legend <- get_legend(p1 + theme(legend.position="bottom"))
    # #     p <- plot_grid(p, legend, ncol = 1, rel_heights = c(1, .2))
        
    # p <- plot_grid(title, row, legend, ncol=1, rel_heights=c(0.1, 1, 0.1)) + 
    #         theme(plot.title=element_text(size=12), text=element_text(size=10))


    print(p)

    return(allsimudat)

}
