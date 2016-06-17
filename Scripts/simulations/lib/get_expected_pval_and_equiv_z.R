# Load first simulation

suffix <- "tom"
remove(allsimudat)

study_dir = '/Volumes/camille/MBIA_buster/'
study_dirs = dir(study_dir, pattern="nStudy.*")

tot_num_simu = length(study_dirs)

print(paste(tot_num_simu, "simulations"))

for (simunum in seq(tot_num_simu, 1, -1)){
	print(paste('Reading ', simunum, ' / ', tot_num_simu))	
	simu_file = paste(study_dir, study_dirs[simunum],'/simu.csv',sep="")
	print(simu_file)
	
	if (! file.exists(simu_file)){
		print(paste('/!\ ', simu_file, 'does not exist.'))			
		next
	}
	
simudat <- read.csv(simu_file, header=T,row.names = NULL)

# qnorm works with natural log (and not base 10)
simudat$lnp <- -simudat$minuslog10P*log(10)

# It is easier to work with the equiv z stat
simudat$equivz <- qnorm(simudat$lnp, lower.tail = FALSE, log.p = TRUE)

# Get confidence interval on observed p
obs_p_upper <- simudat$P + simudat$stderr_P*1.96
obs_p_lower <- simudat$P - simudat$stderr_P*1.96
minuslog10P_upper <- -log10(obs_p_upper)
minuslog10P_lower <- -log10(obs_p_lower)

simudat$lnp_upper <- -minuslog10P_upper*log(10)
simudat$lnp_lower <- -minuslog10P_lower*log(10)

simudat$equivz_upper <- qnorm(simudat$lnp_upper, lower.tail = FALSE, log.p = TRUE)
simudat$equivz_lower <- qnorm(simudat$lnp_lower, lower.tail = FALSE, log.p = TRUE)


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

csv_file = paste(getwd(), '/../../../data/allsimudat_', suffix,'.csv', sep="")
write.table(allsimudat,file=csv_file,row.names=F)
print(paste("saved in", csv_file))


