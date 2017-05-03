method_labels <- function(string) {
    string[string=="megaMFX"] <- "MFX"
    string[string=="megaRFX"] <- "RFX"
    string[string=="permutCon"] <- "Perm. E"
    string[string=="permutZ"] <- "Perm. Z"
    string[string=="stouffersMFX"] <- "Stouf."
    string[string=="megaFFX_FSL"] <- "FFX"
    string
}

nstudies_labels <- function(string){
    string <- paste(as.character(string), 'subjects')
}

percent_labels <- function(string){
    string <- paste(as.character(string), '% outliers')
}


nsubjects_labels <- function(string){
    string <- paste(as.character(string), 'scans')
}

units_labels <- function(string){
    string[string=="contscl"] <- "Different contrasts"    
    string[string=="datascl"] <- "Different scaling"
    string[string=="nominal"] <- "Nominal"
    # string[string=="contscl 1 0"] <- "Different contrast vector scaling"    
    # string[string=="contscl 1"] <- "Different contrast vector scaling"
    # string[string=="datascl 2"] <- "Different scaling algorithm (same target)"
    # string[string=="datascl 2 0.2"] <- "Different scaling algorithm (same target) - 20%"
    # string[string=="datascl 2 0.5"] <- "Different scaling algorithm (same target) - 50%"        
    # string[string=="nominal 1 0"] <- "Nominal"
    # string[string=="nominal 1"] <- "Nominal"
    # string[string=="datascl 100 0.2"] <- "Different scaling target - 20%"
    # string[string=="datascl 100"] <- "Different scaling target"
    # string[string=="datascl 100 0.5"] <- "Different scaling target - 50%"
    string
}

soft2Factor_labels <- function(string){
    string[string==1] <- "none"
    string[string==2] <- "algorithm"
    string[string==100] <- "baseline"
    string
}

soft2_labels <- function(string){
    string[string==0] = ""
    string
}

load_data_from_csv <- function(pattern, data_dir){
    suffix <- gsub('[^a-zA-Z_0-9]', '', pattern)
    csv_file = paste(getwd(), '/../data/allsimudat_', suffix,'.csv', sep="")

    if (! file.exists(csv_file)){
        print(paste('pattern=', suffix))
        print(paste('CSV file', csv_file,' not found, reprocessing the data.'))
        get_expected_pval_and_equiv_z(pattern, csv_file, data_dir)
    } else {
        print(paste('Reading from ', csv_file))
    }
    simudata <- read.csv(csv_file, header=T, sep=",")
    # Reorder unit mismatch factor levels
    simudata$unitMism = factor(simudata$unitMism,c('nominal', 'datascl', 'contscl'))
    
    return(simudata)
}





