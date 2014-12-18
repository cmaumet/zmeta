library('ggplot2')
# allsimudat_pval <- read.csv('../../../allsimudat_pval.csv', header=T, sep=" ")
# allsimudat_pval_rank <- read.csv('../../../allsimudat_pval_rank.csv', header=T, sep=" ")
# allsimudat_tval <- read.csv('../../../allsimudat_nopval.csv', header=T, sep=" ")
allsimudat_tom <- read.csv('../../../allsimudat_tom.csv', header=T, sep=" ")

allsimudat <- allsimudat_tom
allsimudat$unitMismatch <- as.character(allsimudat$unitMismatch)
allsimudat$unitMismatch[allsimudat$unitMismatch=="0"]=FALSE
allsimudat$unitMismatch[allsimudat$unitMismatch=="false"]=FALSE
allsimudat$unitMismatch[allsimudat$unitMismatch=="true"]=TRUE

data_subset <- subset(allsimudat, expectedz>0 & nStudies == 10 &  methods=="megaRFX")

(allsimudat$methods %in% levels(allsimudat $methods)[c(3,4,5,6,8)]))

 # 


#methods=="permutCon" & Between==1 & nStudies==50 & numSubjectScheme=="identical" & varScheme=="identical" & Within==5)
#

# With the plot below, we can check if things went wrong (i.e. expected z-stat not incremental)
p <- ggplot(data_subset, aes(as.factor(equivz), expectedz, colour=factor(paste(Within))))
p + geom_boxplot() + stat_summary(fun.y=mean, colour="red", geom="point", shape=18, size=3,show_guide = FALSE) + facet_grid(methods+Between ~ nStudies+ numSubjectScheme) 

p <- ggplot(data_subset, aes(as.factor(equivz), equivz-expectedz, colour=factor(paste(Within))))


# Bland-Altman like
p <- ggplot(data=data_subset,aes(x=expectedz, y=equivz-expectedz, group=allgroups, colour=factor(paste(Within))))
p + geom_ribbon(aes(x=expectedz, ymin=z_lower-expectedz, ymax=z_upper-expectedz), fill="grey", alpha=.2, colour=NA) + facet_grid(Between + methods~soft2 +unitMismatch+soft2Factor  ) + theme(strip.text.x = element_text(size = 16)) + ylab("Difference between estimated and reference z-statistic") + xlab("Reference z-statistic") + geom_line(aes(x=expectedz, y=0), colour="black") + geom_line() + geom_point(size=1)

# To be able to do boxplots we need to store all values... otherwise as digits -> infinity we get smaller and smaller box plots...
# digits <- 1
# + geom_boxplot(aes(x=(round(expectedz, digits)), y=equivz-expectedz, group=paste(allgroups,factor(round(expectedz, digits))) , colour=factor(paste(Within))))

+ geom_smooth(method = "loess", fill=NA, size=1) + xlim(0, 3.4) + ylim(-0.05, 0.05)


# estimated = f(reference) like on P
p <- ggplot(data= data_subset, aes(x=-log10(expectedP), y=-log10(P), group=allgroups, colour=factor(paste(Within))))

p + geom_line() + geom_point(size=1) + facet_grid(methods+Between ~ nStudies+ numSubjectScheme, scales = "free") + theme(strip.text.x = element_text(size = 16)) + ylab("Observed -log10(P)") + xlab("Expected -log10(P)") + geom_line(aes(x=expectedP, y=expectedP), colour="black") + geom_line(aes(x=expectedP, y=p_upper), colour="red") + geom_line(aes(x=expectedP, y=p_lower), colour="blue")

# Bland-Altman like on P
p <- ggplot(data=subset(allsimudat, expectedP<0.5 & !(allsimudat $methods %in% levels(allsimudat $methods)[c(3,4,5,7)])), aes(x=-log10(expectedP), y=(P-expectedP), group=allgroups, colour=factor(paste(Within))))

p + geom_line() + geom_point(size=1) + facet_grid(Between~methods, scales = "free") + theme(strip.text.x = element_text(size = 16)) + ylab("Observed P minus expected P") + xlab("Expected -log10(P)") 

p + geom_line() + geom_point(size=1) + facet_grid(methods~Between+Within+nStudies, scales = "free") + theme(strip.text.x = element_text(size = 16)) + ylab("Difference between estimated and reference z-statistic") + xlab("Reference z-statistic") + geom_abline(intercept=0, slope=1)


p + geom_line() +  geom_abline(slope=1) +  geom_line(slope=1) + facet_grid(Between~methods, scales = "free") + theme(strip.text.x = element_text(size = 16)) + ylab("Estimated and z-statistic") + xlab("Reference z-statistic") 

+ geom_ribbon(aes(ymin=equivz+1,ymax= equivz-1,alpha=0.1, group=methods))

# # By doing this we accept a lower precison around p=1
allsimudat$roundedlog10p_1 <- round(allsimudat $log10p, digits=1)

newallsimudat <- as.data.frame(aggregate(cbind(p,original_p,log10p,lnp,equivz,expectedp,expectedz)  ~ allgroups + roundedlog10p_1 + methods, data=allsimudat, FUN=mean))


newallsimudat <- aggregate(cbind(p,original_p,log10p,lnp,equivz,expectedp,expectedz)  ~ allgroups + roundedlog10p_1 + methods + nStudies + Between + Within + nSimu, data= allsimudat, FUN=mean)

newallsimudat$expectedz_re <- qnorm(newallsimudat$expectedp, lower.tail=FALSE)

p <- ggplot(data=subset(newallsimudat,expectedz_re>0 & nStudies==20  (newallsimudat$methods %in% levels(newallsimudat$methods)[c(3,4,5,7)])), aes(x=expectedz_re, y=equivz-expectedz_re, group=allgroups, colour=factor(Within)))

p + geom_line() + geom_point(size=1) + facet_grid(Between~ methods) + ylim(-0.3, 0.3) +      theme(strip.text.x = element_text(size = 16))




p + facet_grid(Between~ methods) +    geom_smooth(method="loess", se=FALSE, fullrange=T)
