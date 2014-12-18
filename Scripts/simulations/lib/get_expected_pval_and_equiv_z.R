# Load first simulation
suffix <- "tom"
remove(allsimudat)

study_dirs = dir('../../../data/simulations/', pattern="nStudy.*")

tot_num_simu = length(study_dirs)

print(paste(tot_num_simu, "simulations"))

for (simunum in seq(tot_num_simu, 1, -1)){
	print(paste('Reading ', simunum, ' / ', tot_num_simu))	
	simu_file = paste('../../../data/simulations/', study_dirs[simunum],'/simu.csv',sep="")
	
	if (! file.exists(simu_file)){
		print(paste('/!\ ', simu_file, 'does not exist.'))			
		next
	}
	
simudat <- read.csv(simu_file, header=T)

# qnorm works with natural log (and not base 10)
simudat$lnp <- -simudat$minuslog10P*log(10)

# It is easier to work with the equiv z stat
simudat$equivz <- qnorm(simudat$lnp, lower.tail = FALSE, log.p = TRUE)

simudat$allgroups <- paste(simudat$Between, simudat$Within, simudat$nStudies, simudat$nSimu, simudat$numSubjectScheme, simudat$varScheme, simudat$soft2, simudat$soft2Factor, as.character(simudat$unitMismastch))

# newsimudat$expectedp <- newsimudat$rankp/newsimudat$nSimu
simudat$expectedz <- qnorm(simudat$expectedP, lower.tail = FALSE)

if (! exists("allsimudat"))
{
	allsimudat <- simudat
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


allsimudat$unitMismatch <- as.character(allsimudat$unitMismatch)
allsimudat$unitMismatch[allsimudat$unitMismatch=="0"]=FALSE
allsimudat$unitMismatch[allsimudat$unitMismatch=="false"]=FALSE
allsimudat$unitMismatch[allsimudat$unitMismatch=="true"]=TRUE

write.table(allsimudat,file=paste('../../../allsimudat_', suffix,'.csv', sep=""),row.names=F)


