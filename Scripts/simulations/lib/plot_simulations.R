library('ggplot2')
allsimudat <- read.csv('../data/miccai-simu/allsimudat.csv', header=T, sep=" ")

# allsimudat$expectedz <- qnorm(allsimudat$expectedp, lower.tail=FALSE)

# We have downsampled so can't find rank using rank function but from pvalue expected we can retreive rank
# allsimudat$k = allsimudat$expectedp*allsimudat$nSimu^3
allsimudat$p_upper <- qbeta(0.025, allsimudat$rankP, allsimudat$nSimu-allsimudat$rankP +1)
allsimudat$z_upper <- qnorm(allsimudat$p_upper, lower.tail=FALSE)
allsimudat$p_lower <- qbeta(0.975, allsimudat$rankP, allsimudat$nSimu-allsimudat$rankP +1)
allsimudat$z_lower <- qnorm(allsimudat$p_lower, lower.tail=FALSE)


# Bland-Altman like
p <- ggplot(data=subset(allsimudat, expectedz>0 & !(allsimudat $methods %in% levels(allsimudat $methods)[c(3,4,5,7)])), aes(x=expectedz, y=equivz-expectedz, group=allgroups, colour=factor(paste(Within))))

p + geom_ribbon(aes(x=expectedz, ymin=z_lower-expectedz, ymax=z_upper-expectedz), fill="grey", alpha=.2, colour=NA) + geom_line() + geom_point(size=1) + facet_grid(methods ~ Between+numSubjectScheme,scales = "free") + theme(strip.text.x = element_text(size = 16)) + ylab("Difference between estimated and reference z-statistic") + xlab("Reference z-statistic") + geom_line(aes(x=expectedz, y=0), colour="black") 

# estimated = f(reference) like
p <- ggplot(data=subset(allsimudat, expectedz>0 & !(allsimudat $methods %in% levels(allsimudat $methods)[c(3,4,5,7)])), aes(x=expectedz, y=equivz, group=allgroups, colour=factor(paste(Within))))

p + geom_line() + geom_point(size=1) + facet_grid(Between~methods, scales = "free") + theme(strip.text.x = element_text(size = 16)) + ylab("Difference between estimated and reference z-statistic") + xlab("Reference z-statistic") + geom_line(aes(x=expectedz, y=expectedz), colour="black") + geom_line(aes(x=expectedz, y=z_upper), colour="red") + geom_line(aes(x=expectedz, y=z_lower), colour="blue")

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
