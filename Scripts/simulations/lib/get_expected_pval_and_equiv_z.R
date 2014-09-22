# Load first simulation
simunum <- 1

for (simunum in seq(1,31)){
	print(paste('Reading ',paste('../../../simu_all_', as.character(simunum), '.csv',sep="")))
simudat <- read.csv(paste('../../../simu_all_', as.character(simunum), '.csv',sep=""), header=T)

# In fact p contains -log10(p)
simudat$original_p <- simudat$p
simudat$log10p <- -simudat$p
simudat$p <- 10^(simudat$log10p)

# With permutations we can have p=1, not sure why this was an issue
# We have to ignore the cases in which p = 1 due to matlab imprecision 1-1E-20 = 1 -> FIXME
# dim(simudat[simudat$original_p==0,])
# simudat <- subset(simudat, original_p!=0)

# qnorm works with natural log (and not base 10)
simudat$lnp <- simudat$log10p*log(10)

# It is easier to work with the equiv z stat
simudat$equivz <- qnorm(simudat$lnp, lower.tail = FALSE, log.p = TRUE)

simudat$allgroups <- paste(simudat$Between, simudat$Within, simudat$nStudies, simudat$nSimu, simudat$numSubjectScheme)

# We need to sort by z so that later on we can move by one for probas
simudat <- simudat[with(simudat, order(methods, allgroups, equivz)), ]

simudat$rankp <- NaN
simudat$expectedp <- NaN
simudat$expectedz <- NaN
for (meth in levels(simudat$methods))
{
	print(meth)
	# Empirical cumulative distribution function
	# quantile(simudat$equivz[is.finite(simudat$equivz)], type=1)
	# subdat <- subset(simudat, methods==meth)
	
	# cumempfun <- ecdf(simudat[simudat$methods==meth,]$equivz[is.finite(simudat[simudat$methods==meth,]$equivz)])
	# cumulative on p gives directly the inverse cumulative on z moved by 1
	# and working with p remove the pb of infinite equiv z-stat (in permutation-based methods
	# we can have p=1 hence equivz=Inf)
	# Faster with a rank		
  	# cumempfun <- ecdf(simudat[simudat$methods==meth,]$p)
	# summary(cumempfun)
	
	simudat[simudat$methods==meth,]$rankp <- rank(simudat[simudat$methods==meth,]$p)
	nSimu <- simudat[simudat$methods==meth,]$nSimu

	# expected_p_by_1 <- 1-cumempfun(simudat[simudat$methods==meth,]$equivz)
	# simudat[simudat$methods==meth,]$expectedp <-c(1, expected_p_by_1[1:length(expected_p_by_1)-1])
	simudat[simudat$methods==meth,]$expectedp <- simudat[simudat$methods==meth,]$rankp/nSimu
	simudat[simudat$methods==meth,]$expectedz <- qnorm(simudat[simudat$methods==meth,]$expectedp, lower.tail = FALSE)
}

write.table(simudat,file=paste('../../../simu_all_expected_', as.character(simunum), '.csv',sep=""),sep=",",row.names=F)


# By doing this we accept a lower precison around p=1
simudat$roundedlog10p <- round(simudat$log10p, digits=2)


# Reduce the number of sample point
# This is not the right way to add confidence interval!
# newsimudat <- aggregate(cbind(p,original_p,log10p,lnp,equivz,expectedp,expectedz)  ~ allgroups + roundedlog10p + methods, data=simudat, FUN=function(x) c(m=mean(x), s=sd(x)/sqrt(length(x)), n=length(x) ))

# Downsampling: For each multiple occurence of rounded log10p select the first one
newsimudat <- aggregate(cbind(p,original_p,log10p,lnp,equivz,expectedp,expectedz,rankp)  ~ allgroups + roundedlog10p + methods + nStudies + Between + Within + nSimu, data=simudat, FUN=function(x){head(x,1)})

#newsimudat <- as.data.frame(as.list(newsimudat))


#aggregate( simudat[,c(6:10, 12:13)], simudat[,c(1, 11, 14)], FUN = mean )
write.table(newsimudat,file=paste('../../../simu_all_expected_short_', as.character(simunum), '.csv',sep=""),sep=",",row.names=F)

if (simunum == 1)
{
	allsimudat <-newsimudat
} else
{
	allsimudat <-rbind(allsimudat,newsimudat)
}

write.table(allsimudat,file='../../../allsimudat.csv',row.names=F)
}


