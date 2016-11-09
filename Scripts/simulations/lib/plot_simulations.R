library('ggplot2')

# allsimudat_pval <- read.csv('../../../allsimudat_pval.csv', header=T, sep=" ")
# allsimudat_pval_rank <- read.csv('../../../allsimudat_pval_rank.csv', header=T, sep=" ")
# allsimudat_tval <- read.csv('../../../allsimudat_nopval.csv', header=T, sep=" ")
pattern = "^test2_k.*_btw1"
suffix <- gsub('[^a-zA-Z_0-9]', '', pattern)
csv_file = paste(getwd(), '/../../../data/allsimudat_', suffix,'.csv', sep="")

if (! file.exists(csv_file)){
	get_expected_pval_and_equiv_z(pattern)
}

allsimudat_tom <- read.csv(csv_file, header=T, sep=",")


allsimudat <- allsimudat_tom

facet_labeller <- function(var, value){
    value <- as.character(value)
    if (var=="unitMismatch") { 
        value[value=="FALSE"] <- "different software"    	
        value[value=="TRUE"] <- "contrast & design matrix"    	        
    } else if (var=="soft2Factor") { 
        value[value==1] <- "none"    	
        value[value==2] <- "algorithm"    	        
        value[value==100] <- "baseline"    	        
    } else if (var=="soft2") { 
        value <- paste(as.numeric(value)*100, "%", sep='')
        value[value=="0%"] <- ""    	        
    } else if (var=="methods") { 
        value[value=="megaMFX"] <- "MFX"    	
        value[value=="megaRFX"] <- "RFX"    	    
        value[value=="permutCon"] <- "Perm. E"
        value[value=="permutZ"] <- "Perm. Z"            	    
        value[value=="stouffersMFX"] <- "Stouf."            	            
    } else if (var=="units") { 
        value[value=="contscl 1 0"] <- "Different contrast vector scaling"    
        value[value=="contscl 1"] <- "Different contrast vector scaling"            	
        value[value=="datascl 2"] <- "Different scaling algorithm (same target)"        
        value[value=="datascl 2 0.2"] <- "Different scaling algorithm (same target) - 20%"
        value[value=="datascl 2 0.5"] <- "Different scaling algorithm (same target) - 50%"        
        value[value=="nominal 1 0"] <- "Nominal"                    	    
        value[value=="nominal 1"] <- "Nominal"                    	            
        value[value=="datascl 100 0.2"] <- "Different scaling target - 20%"
        value[value=="datascl 100"] <- "Different scaling target"        
        value[value=="datascl 100 0.5"] <- "Different scaling target - 50%"        
    } else if (var=="nStudies") { 
        value <- paste(as.numeric(value), " studies", sep='')
    }
    return(value)
}

#selected_methods <- c("megaMFX","megaRFX","permutCon","permutZ","stouffersMFX")
selected_methods <- c("megaMFX","megaRFX","permutCon")

# data_subset <- subset(allsimudat, expectedz>0 &  nStudies>10 & Between==0 &  (allsimudat$methods not %in% selected_methods)  & !(allsimudat$methods %in% c("megaFFX")) & glm==1)

# expectedz is minus infinity if expected p is 1 which happens when rank = sample_size
# we look only at positive effect (expectedz>0), supposedly this should be more or less symmetric...?
data_subset <- subset(allsimudat, is.finite(expectedz) & expectedz>0 &  (allsimudat$methods %in% selected_methods) )

data_subset$units <- paste(data_subset$unitMism, data_subset$soft2Factor)

# Reorder the data frame to have nominal first
data_subset <- data_subset[order(c(data_subset$soft2, data_subset$soft2Factor, data_subset$units)), ]

subplot=list()
titles=list()

titles[[1]] <- paste("Nominal (", suffix,")") 
subplot[[1]] <- subset(data_subset, unitMism=="nominal")
#subplot[[1]] <- data_subset

titles[[2]] <- "Different scaling target"
subplot[[2]] <- subset(data_subset, unitMism=="datascl" & soft2Factor==100)

titles[[3]] <- "Different scaling algorithm (same target)"
subplot[[3]] <- subset(data_subset, unitMism=="datascl" & soft2Factor!=100)

titles[[4]] <- "Different contrast vector scaling"
subplot[[4]] <- subset(data_subset, soft2==0 & unitMism=="contscl")



#methods=="megaRFX")

allsimudat$Within <- factor(allsimudat$Within)


 # 


#methods=="permutCon" & Between==1 & nStudies==50 & numSubjectScheme=="identical" & varScheme=="identical" & Within==5)
#

# # # With the plot below, we can check if things went wrong (i.e. expected z-stat not incremental)
# p <- ggplot(data_subset, aes(as.factor(equivz), expectedz, colour=factor(paste(Within))))
# p + geom_boxplot() + stat_summary(fun.y=mean, colour="red", geom="point", shape=18, size=3,show_guide = FALSE) + facet_grid(methods+Between ~ nStudies+ numSubjectScheme) 

# p <- ggplot(data_subset, aes(as.factor(equivz), equivz-expectedz, colour=factor(paste(Within))))


# Bland-Altman like
subpl=list()


for (i in 1:4){
	subpl[[i]] <- ggplot(data=subplot[[i]],aes(x=expectedz, y=equivz-expectedz, group=allgroups, colour=factor(Within)))
	
	subpl[[i]] <- subpl[[i]] + geom_ribbon(aes(x=expectedz, ymin=z_lower-expectedz, ymax=z_upper-expectedz), fill="grey", alpha=.9, colour=NA) + facet_grid(methods+nStudies ~soft2+Within, labeller=facet_labeller,scales = "free") + theme(strip.text.x = element_text(size = 10)) + ylab("Estimated - reference Z") + xlab("Reference Z") + geom_line(aes(x=expectedz, y=0), colour="black") + ggtitle(titles[[i]]) + theme(legend.position="none") + ylim(-1, 0.5)  + stat_summary(fun.y = mean, geom = "line") + stat_summary(fun.data = mean_se, geom = "pointrange") 
	
	#+ stat_summary(fun.data = "interquartile", geom = "errorbar")+    stat_summary(fun.y = 'median', geom='line')



	
	# + geom_ribbon(aes(x=expectedz, ymax = equivz_upper-expectedz, ymin= equivz_lower-expectedz), width=0.20) 
	
	# subpl[[i]] <- subpl[[i]] + geom_ribbon(aes(x=expectedz, ymin=z_lower-expectedz, ymax=z_upper-expectedz), fill="grey", alpha=.2, colour=NA) + facet_grid(Between + methods + nStudies + glm ~ unitMismatch+soft2Factor+ soft2, labeller=facet_labeller) + theme(strip.text.x = element_text(size = 16)) + ylab("Difference between estimated and reference z-statistic") + xlab("Reference z-statistic") + geom_line(aes(x=expectedz, y=0), colour="black") + geom_line() + geom_point(size=1) 
}

#p<- subpl[[1]]

#multiplot(subpl[[1]], subpl[[4]], subpl[[3]], subpl[[2]], layout=matrix(c(1,2,3,3,4,4), nrow=1, byrow=TRUE))
multiplot(subpl[[1]], subpl[[4]], subpl[[3]], layout=matrix(c(1,2,3,3), nrow=1, byrow=TRUE))


# # To be able to do boxplots we need to store all values... otherwise as digits -> infinity we get smaller and smaller box plots...
# # digits <- 1
# # + geom_boxplot(aes(x=(round(expectedz, digits)), y=equivz-expectedz, group=paste(allgroups,factor(round(expectedz, digits))) , colour=factor(paste(Within))))

# + geom_smooth(method = "loess", fill=NA, size=1) + xlim(0, 3.4) + ylim(-0.05, 0.05)


# # estimated = f(reference) like on P
# p <- ggplot(data= data_subset, aes(x=-log10(expectedP), y=-log10(P), group=allgroups, colour=factor(paste(Within))))

# p + geom_line() + geom_point(size=1) + facet_grid(methods+Between ~ nStudies+ numSubjectScheme, scales = "free") + theme(strip.text.x = element_text(size = 16)) + ylab("Observed -log10(P)") + xlab("Expected -log10(P)") + geom_line(aes(x=expectedP, y=expectedP), colour="black") + geom_line(aes(x=expectedP, y=p_upper), colour="red") + geom_line(aes(x=expectedP, y=p_lower), colour="blue")

# # Bland-Altman like on P
# p <- ggplot(data=subset(allsimudat, expectedP<0.5 & !(allsimudat $methods %in% levels(allsimudat $methods)[c(3,4,5,7)])), aes(x=-log10(expectedP), y=(P-expectedP), group=allgroups, colour=factor(paste(Within))))

# p + geom_line() + geom_point(size=1) + facet_grid(Between~methods, scales = "free") + theme(strip.text.x = element_text(size = 16)) + ylab("Observed P minus expected P") + xlab("Expected -log10(P)") 

# p + geom_line() + geom_point(size=1) + facet_grid(methods~Between+Within+nStudies, scales = "free") + theme(strip.text.x = element_text(size = 16)) + ylab("Difference between estimated and reference z-statistic") + xlab("Reference z-statistic") + geom_abline(intercept=0, slope=1)


# p + geom_line() +  geom_abline(slope=1) +  geom_line(slope=1) + facet_grid(Between~methods, scales = "free") + theme(strip.text.x = element_text(size = 16)) + ylab("Estimated and z-statistic") + xlab("Reference z-statistic") 

# + geom_ribbon(aes(ymin=equivz+1,ymax= equivz-1,alpha=0.1, group=methods))

# # # By doing this we accept a lower precison around p=1
# allsimudat$roundedlog10p_1 <- round(allsimudat $log10p, digits=1)

# newallsimudat <- as.data.frame(aggregate(cbind(p,original_p,log10p,lnp,equivz,expectedp,expectedz)  ~ allgroups + roundedlog10p_1 + methods, data=allsimudat, FUN=mean))


# newallsimudat <- aggregate(cbind(p,original_p,log10p,lnp,equivz,expectedp,expectedz)  ~ allgroups + roundedlog10p_1 + methods + nStudies + Between + Within + nSimu, data= allsimudat, FUN=mean)

# newallsimudat$expectedz_re <- qnorm(newallsimudat$expectedp, lower.tail=FALSE)

# p <- ggplot(data=subset(newallsimudat,expectedz_re>0 & nStudies==20  (newallsimudat$methods %in% levels(newallsimudat$methods)[c(3,4,5,7)])), aes(x=expectedz_re, y=equivz-expectedz_re, group=allgroups, colour=factor(Within)))

# p + geom_line() + geom_point(size=1) + facet_grid(Between~ methods) + ylim(-0.3, 0.3) +      theme(strip.text.x = element_text(size = 16))




# p + facet_grid(Between~ methods) +    geom_smooth(method="loess", se=FALSE, fullrange=T)


