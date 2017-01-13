method_labels <- function(string) {
    string[string=="megaMFX"] <- "MFX"
    string[string=="megaRFX"] <- "RFX"
    string[string=="permutCon"] <- "Perm. E"
    string[string=="permutZ"] <- "Perm. Z"
    string[string=="stouffersMFX"] <- "Stouf."
    string[string=="megaFFX_FSL"] <- "FFX"
    string
}

units_labels <- function(string){
    string[string=="contscl"] <- "Diff. contrast"    
    string[string=="datascl"] <- "Diff. scaling"
    string[string=="nominal"] <- "Nominal"
    # string[string=="contscl 1 0"] <- "Different contrast vector scaling"    
    # string[string=="contscl 1"] <- "Different contrast vector scaling"
    # string[string=="datascl 2"] <- "Different scaling algorithm (same target)"
    # string[string=="datascl 2 0.2"] <- "Different scaling algorithm (same target) - 20%"
    # string[string=="datascl 2 0.5"] <- "Different scaling algorithm (same target) - 50%"        
    # string[string=="nominal 1 0"] <- "Nominal"
    # string[string=="nominal 1"] <- "Nominal"
    # string[string=="datascl 100 0.2"] <- "Different scaling target - 20%"
    # string[string=="datascl 100"] <- "Different scaling target"
    # string[string=="datascl 100 0.5"] <- "Different scaling target - 50%"
    string
}

soft2Factor_labels <- function(string){
    string[string==1] <- "none"
    string[string==2] <- "algorithm"
    string[string==100] <- "baseline"
    string
}

soft2_labels <- function(string){
    string[string==0] = ""
    string
}

load_data_from_csv <- function(pattern){
    suffix <- gsub('[^a-zA-Z_0-9]', '', pattern)
    csv_file = paste(getwd(), '/../../../data/allsimudat_', suffix,'.csv', sep="")

    if (! file.exists(csv_file)){
        print(paste('pattern=', suffix))
        print(paste('CSV file', csv_file,' not found, reprocessing the data.'))
        get_expected_pval_and_equiv_z(pattern)
    }
    simudata <- read.csv(csv_file, header=T, sep=",")
    # Reorder unit mismatch factor levels
    simudata$unitMism = factor(simudata$unitMism,c('nominal', 'contscl', 'datascl'))
    
    return(simudata)
}

plot_unit_mismatch <- function(data, suffix, mult=FALSE, single=FALSE){
    
    # Ignore soft2Factor=100 (too extreme)
    data = subset(data, data$soft2Factor<100)
    
    subplot=list()
    titles=list()

    titles[[1]] <- paste("Nominal (", suffix,")") 
    subplot[[1]] <- subset(data, unitMism=="nominal")
    #subplot[[1]] <- data_subset

    titles[[2]] <- "Different scaling target"
    subplot[[2]] <- subset(data, unitMism=="datascl" & soft2Factor==100)

    titles[[3]] <- "Different scaling algorithm (same target)"
    subplot[[3]] <- subset(data, unitMism=="datascl" & soft2Factor!=100)

    titles[[4]] <- "Different contrast vector scaling"
    subplot[[4]] <- subset(data, soft2==0 & unitMism=="contscl")



    #methods=="megaRFX")

    allsimudat$Within <- factor(allsimudat$Within)


     # 


    #methods=="permutCon" & Between==1 & nStudies==50 & numSubjectScheme=="identical" & varScheme=="identical" & Within==5)
    #

    # # # With the plot below, we can check if things went wrong (i.e. expected z-stat not incremental)
    # p <- ggplot(data_subset, aes(as.factor(equivz), expectedz, colour=factor(paste(Within))))
    # p + geom_boxplot() + stat_summary(fun.y=mean, colour="red", geom="point", shape=18, size=3,show_guide = FALSE) + facet_grid(methods+Between ~ nStudies+ numSubjectScheme) 

    # p <- ggplot(data_subset, aes(as.factor(equivz), equivz-expectedz, colour=factor(paste(Within))))

    subpl=list()
    if (single){
        subpl[[1]] <- ggplot(data=data,aes(x=expectedz, y=equivz-expectedz, group=allgroups, colour=factor(Within)))

        subpl[[1]] <- subpl[[1]] + 
                geom_ribbon(
                    aes(x=expectedz, ymin=z_lower-expectedz, ymax=z_upper-expectedz), 
                    fill="grey", alpha=.2, colour=NA) + 
                facet_grid(methods~unitMism+soft2, scales = "free", 
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
                ggtitle(paste("Unit mismatch:", suffix)) + theme(legend.position="none") + ylim(-1, 0.5)

    } else {
        # Bland-Altman like

        for (i in 1:4){
            subpl[[i]] <- ggplot(data=subplot[[i]],aes(x=expectedz, y=equivz-expectedz, group=allgroups, colour=factor(Within)))

            subpl[[i]] <- subpl[[i]] + 
                geom_ribbon(
                    aes(x=expectedz, ymin=z_lower-expectedz, ymax=z_upper-expectedz), 
                    fill="grey", alpha=.2, colour=NA) + 
                facet_grid(methods~nStudies+soft2, scales = "free", 
                           labeller = labeller(
                               methods = method_labels, 
                               nStudies = label_both,
                               soft2 = soft2Factor_labels)) + 
                theme(strip.text.x = element_text(size = 10)) + 
                ylab("Estimated - reference Z") + xlab("Reference Z") + 
                geom_line(aes(x=expectedz, y=0), colour="black") + 
                geom_line() + 
        #         geom_point(size=0.5) + 
                ggtitle(titles[[i]]) + theme(legend.position="none") + ylim(-1, 0.5)


            # + geom_ribbon(aes(x=expectedz, ymax = equivz_upper-expectedz, ymin= equivz_lower-expectedz), width=0.20) 

            # subpl[[i]] <- subpl[[i]] + geom_ribbon(aes(x=expectedz, ymin=z_lower-expectedz, ymax=z_upper-expectedz), fill="grey", alpha=.2, colour=NA) + facet_grid(Between + methods + nStudies + glm ~ unitMismatch+soft2Factor+ soft2, labeller=facet_labeller) + theme(strip.text.x = element_text(size = 16)) + ylab("Difference between estimated and reference z-statistic") + xlab("Reference z-statistic") + geom_line(aes(x=expectedz, y=0), colour="black") + geom_line() + geom_point(size=1) 
        }
    }
    if (mult){
        multiplot(subpl[[1]], subpl[[4]], subpl[[3]], layout=matrix(c(1,2,3,3), nrow=1, byrow=TRUE))
    } else {
        for (i in seq(1,length(subpl))){
            print(subpl[[i]])
        }
    }
}