# Load first simulation
tot_num_simu = 50

for (simunum in seq(1, tot_num_simu)){
	print(paste('Reading ',paste('../../../data/simulations/simu_all_', as.character(simunum), '.csv',sep="")))
simudat <- read.csv(paste('../../../data/simulations/simu_all_', as.character(simunum), '.csv',sep=""), header=T)

# qnorm works with natural log (and not base 10)
simudat$lnp <- -simudat$minuslog10P*log(10)

# It is easier to work with the equiv z stat
simudat$equivz <- qnorm(simudat$lnp, lower.tail = FALSE, log.p = TRUE)

simudat$allgroups <- paste(simudat$Between, simudat$Within, simudat$nStudies, simudat$nSimu, simudat$numSubjectScheme, simudat$varScheme)

# newsimudat$expectedp <- newsimudat$rankp/newsimudat$nSimu
simudat$expectedz <- qnorm(simudat$expectedP, lower.tail = FALSE)

if (simunum == 1)
{
	allsimudat <-simudat
} else
{
	allsimudat <-rbind(allsimudat,simudat)
}

}

# allsimudat$expectedz <- qnorm(allsimudat$expectedp, lower.tail=FALSE)

# We have downsampled so can't find rank using rank function but from pvalue expected we can retreive rank
# allsimudat$k = allsimudat$expectedp*allsimudat$nSimu^3
allsimudat$p_upper <- qbeta(0.025, allsimudat$rankP, allsimudat$nSimu-allsimudat$rankP +1)
allsimudat$z_upper <- qnorm(allsimudat$p_upper, lower.tail=FALSE)
allsimudat$p_lower <- qbeta(0.975, allsimudat$rankP, allsimudat$nSimu-allsimudat$rankP +1)
allsimudat$z_lower <- qnorm(allsimudat$p_lower, lower.tail=FALSE)

write.table(allsimudat,file='../../../allsimudat.csv',row.names=F)


