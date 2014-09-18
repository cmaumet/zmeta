library('ggplot2')
allsimudat <- read.csv('../data/miccai-simu/allsimudat.csv', header=T, sep=" ")

allsimudat$expectedz <- qnorm(allsimudat $expectedp, lower.tail=FALSE)

p <- ggplot(data=subset(allsimudat, expectedz>0 & !(allsimudat $methods %in% levels(allsimudat $methods)[c(3,4,5,7)])), aes(x=expectedz, y=equivz-expectedz, group=allgroups, colour=factor(paste(Within))))

p + geom_line() + geom_point(size=1) + facet_grid(Between~ methods) +      theme(strip.text.x = element_text(size = 16)) + ylab("Difference between estimated and reference z-statistic") + xlab("Reference z-statistic")

# # By doing this we accept a lower precison around p=1
allsimudat$roundedlog10p_1 <- round(allsimudat $log10p, digits=1)

newallsimudat <- as.data.frame(aggregate(cbind(p,original_p,log10p,lnp,equivz,expectedp,expectedz)  ~ allgroups + roundedlog10p_1 + methods, data=allsimudat, FUN=mean))


newallsimudat <- aggregate(cbind(p,original_p,log10p,lnp,equivz,expectedp,expectedz)  ~ allgroups + roundedlog10p_1 + methods + nStudies + Between + Within + nSimu, data= allsimudat, FUN=mean)

newallsimudat$expectedz_re <- qnorm(newallsimudat$expectedp, lower.tail=FALSE)

p <- ggplot(data=subset(newallsimudat,expectedz_re>0 & nStudies==20  (newallsimudat$methods %in% levels(newallsimudat$methods)[c(3,4,5,7)])), aes(x=expectedz_re, y=equivz-expectedz_re, group=allgroups, colour=factor(Within)))

p + geom_line() + geom_point(size=1) + facet_grid(Between~ methods) + ylim(-0.3, 0.3) +      theme(strip.text.x = element_text(size = 16))




p + facet_grid(Between~ methods) +    geom_smooth(method="loess", se=FALSE, fullrange=T)
