get_expected_pval_and_equiv_z <- function(pattern="^nStudy50_subNumidentical_varidentical_Betw1") {

study_dir = '/Volumes/camille/IBMA_simu/'
suffix <- gsub('[^a-zA-Z_0-9]', '', pattern)
print(pattern)
study_dirs = dir(study_dir, pattern=paste(pattern, ".*", sep=''))

csv_file = paste(getwd(), '/../../../data/allsimudat_', suffix,'.csv', sep="")
if (file.exists(csv_file)){
	file.remove(csv_file)
}

tot_num_simu = length(study_dirs)

print(paste(tot_num_simu, "simulations"))
if (tot_num_simu == 0){
    stop(paste('No simulation found in', study_dir, 'with pattern', pattern))
}

first = T
for (simunum in seq(tot_num_simu, 1, -1)){
	print(paste('Reading ', simunum, ' / ', tot_num_simu))	
	simu_file = paste(study_dir, study_dirs[simunum], 'simu_400.csv', sep="/")
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

	simudat$allgroups <- paste(simudat$Between, simudat$Within, simudat$nStudies, simudat$nSubjects, simudat$nSimu, simudat$numSubjectsSame, simudat$WithinSame, simudat$soft2, simudat$soft2Factor, as.character(simudat$unitMism))

	# newsimudat$expectedp <- newsimudat$rankp/newsimudat$nSimu
	simudat$expectedz <- qnorm(simudat$expectedP, lower.tail = FALSE)

	# We have downsampled so can't find rank using rank function but from pvalue expected we can retreive rank
	# simudat$k = simudat$expectedp*simudat$nSimu^3
	simudat$p_upper <- qbeta(0.025, simudat$rankP, simudat$nSimu-simudat$rankP +1)
	simudat$z_upper <- qnorm(simudat$p_upper, lower.tail=FALSE)
	simudat$p_lower <- qbeta(0.975, simudat$rankP, simudat$nSimu-simudat$rankP +1)
	simudat$z_lower <- qnorm(simudat$p_lower, lower.tail=FALSE)

	simudat$unitMism <- as.character(simudat$unitMism)
	
    # In some previous version of the code (zmeta_buster) WithinSame was called varScheme
    names(simudat)[names(simudat)=="varScheme"] <- "WithinSame"
    
	# We want to keep the allsimudat variable (to be able to directly use it without re-reading from the file)
	if (first){
		col_names = T
		app = F
		first = F
	} else{
		col_names = F
		app = T
	}
	write.table(simudat,file=csv_file,row.names=F,append=app,sep=",",col.names=col_names)
	print(paste("saved in", csv_file))
}

}


