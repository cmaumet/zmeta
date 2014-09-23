# Load first simulation
tot_num_simu = 84

for (simunum in seq(1, tot_num_simu)){
	print(paste('Reading ',paste('../../../simu_all_', as.character(simunum), '.csv',sep="")))
simudat <- read.csv(paste('../../../simu_all_', as.character(simunum), '.csv',sep=""), header=T)

# qnorm works with natural log (and not base 10)
simudat$lnp <- -simudat$minuslog10P*log(10)

# It is easier to work with the equiv z stat
simudat$equivz <- qnorm(simudat$lnp, lower.tail = FALSE, log.p = TRUE)

simudat$allgroups <- paste(simudat$Between, simudat$Within, simudat$nStudies, simudat$nSimu, simudat$numSubjectScheme)

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

write.table(allsimudat,file='../../../allsimudat.csv',row.names=F)


