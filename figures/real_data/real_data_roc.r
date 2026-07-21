
	test_type=1;
	# allsimudat=NA;

	source(file.path('..','commons','get_expected_pval_and_equiv_z.R'))
	source(file.path('..','commons','multiplot.R'))
	source(file.path('..','commons','plot_lib.R'))
	source(file.path('..', 'commons','prepare_data.R'))
	source(file.path('..', 'commons','plot_unit_mismatch.R'))
	source(file.path('..', 'commons','plot_blandaldman_z.R'))
	source(file.path('..', 'commons','plot_grid_methods_color_within.R'))
	source(file.path('..', 'commons','plot_qq_p.R'))
	source(file.path('..', 'commons','load_data_from_files.R'))

	simu_dir = file.path('..', '..', 'results', 'simus')

	# Simulated data (to get false positive rate)
	iter = 38
    if (all(is.na(allsimudat))){
        allsimudat = load_data_from_files(simu_dir, iter, test_type)
    }

    data_positive_z <- subset(allsimudat, equivz>0 & (unitMism=="nominal"))

    # Real data (to get true positive rate)
    realdata <- read.csv(file.path('..', '..', 'results', 'realdata_TPR.csv'), header=T, sep=",")
	# Harmonize naming of method column
	names(realdata)[names(realdata) == 'Method'] <- 'methods'
	realdata[realdata$methods=="megaFFX",]$methods <- "megaFFX_FSL"
	realdata$methods <- factor(realdata$methods)
