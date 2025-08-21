load_data_from_files <- function(simu_dir, iter, test_type=1) {

    if (is.numeric(test_type)) {
        test_type = as.character(test_type)
    }
    test_type = paste("test", test_type, "_", sep="")

    # # One-sample tests
    # # Load data from CSV
    allsimudat_k05 <- load_data_from_csv(paste('^', test_type, 'k005_n20.*_nominal', sep=""), simu_dir, iter)
    allsimudat_k10 <- load_data_from_csv(paste('^', test_type, 'k010_n20.*_nominal', sep=""), simu_dir, iter)
    allsimudat_k25 <- load_data_from_csv(paste('^', test_type, 'k025_n20.*_nominal*', sep=""), simu_dir, iter)
    allsimudat_k50 <- load_data_from_csv(paste('^', test_type, 'k050_n20.*_nominal*', sep=""), simu_dir, iter)
    allsimudat_k25_n100 <- load_data_from_csv(paste('^', test_type, 'k025_n100.*_nominal', sep=""), simu_dir, iter)

    allsimudat <- rbind(
                        allsimudat_k05, 
                        allsimudat_k10, 
                        allsimudat_k25, 
                        allsimudat_k25_n100,
                        allsimudat_k50
    )

    allsimudat$withinVar <- allsimudat$Within/allsimudat$nSubjects
    return(allsimudat)
}