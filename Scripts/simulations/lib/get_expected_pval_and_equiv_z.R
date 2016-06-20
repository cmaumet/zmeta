# Load first simulation


remove(allsimudat)

study_dir = '/Volumes/camille/MBIA_buster/'
pattern <- '^nStudy25_subNumidentical_varidentical_Betw1_'
suffix <- gsub('^', '', pattern)
study_dirs = dir(study_dir, pattern=paste(pattern, ".*", sep=''))

csv_file = paste(getwd(), '/../../../data/allsimudat_', suffix,'.csv', sep="")
if (file.exists(csv_file)){
	file.remove(csv_file)
}

tot_num_simu = length(study_dirs)

print(paste(tot_num_simu, "simulations"))

first = T
for (simunum in seq(tot_num_simu, 1, -1)){
	remove(thissimudat)
	
	print(paste('Reading ', simunum, ' / ', tot_num_simu))	

	simu_file = paste(study_dir, study_dirs[simunum], 'simu.csv', sep="/")
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

	simudat$allgroups <- paste(simudat$Between, simudat$Within, simudat$nStudies, simudat$nSimu, simudat$numSubjectScheme, simudat$varScheme, simudat$soft2, simudat$soft2Factor, as.character(simudat$unitMismastch))

	# newsimudat$expectedp <- newsimudat$rankp/newsimudat$nSimu
	simudat$expectedz <- qnorm(simudat$expectedP, lower.tail = FALSE)

	if (! exists("thissimudat"))
	{
		thissimudat <- simudat
	} else
	{
		thissimudat <-rbind(thissimudat,simudat)
	}
	# Append to the csv file after each simulation is computed
	# thissimudat$expectedz <- qnorm(thissimudat$expectedp, lower.tail=FALSE)

	# We have downsampled so can't find rank using rank function but from pvalue expected we can retreive rank
	# thissimudat$k = thissimudat$expectedp*thissimudat$nSimu^3
	thissimudat$p_upper <- qbeta(0.025, thissimudat$rankP, thissimudat$nSimu-thissimudat$rankP +1)
	thissimudat$z_upper <- qnorm(thissimudat$p_upper, lower.tail=FALSE)
	thissimudat$p_lower <- qbeta(0.975, thissimudat$rankP, thissimudat$nSimu-thissimudat$rankP +1)
	thissimudat$z_lower <- qnorm(thissimudat$p_lower, lower.tail=FALSE)


	thissimudat$unitMismatch <- as.character(thissimudat$unitMismatch)
	thissimudat$unitMismatch[thissimudat$unitMismatch=="0"]=FALSE
	thissimudat$unitMismatch[thissimudat$unitMismatch=="false"]=FALSE
	thissimudat$unitMismatch[thissimudat$unitMismatch=="true"]=TRUE
	
	# We want to keep the allsimudat variable (to be able to directly use it without re-reading from the file)
	if (! exists("allsimudat"))
	{
		allsimudat <- thissimudat
	} else
	{
		allsimudat <-rbind(allsimudat, thissimudat)
	}	

	if (first){
		col_names = T
		app = F
		first = F
	} else{
		col_names = F
		app = T
	}
	write.table(thissimudat,file=csv_file,row.names=F,append=app,sep=",",col.names=col_names)
	print(paste("saved in", csv_file))
}




