method_labels <- function(string) {
    string[string=="megaMFX"] <- "MFX"
    string[string=="megaRFX"] <- "RFX"
    string[string=="permutCon"] <- "Perm. E"
    string[string=="permutZ"] <- "Perm. Z"
    string[string=="stouffers"] <- "Stouffer's"
    string[string=="fishers"] <- "Fisher's"
    string[string=="fishers"] <- "Fisher's"
    string[string=="weightedZ"] <- "Weighted Z"
    string[string=="megaFFX_FSL"] <- "FFX"
    string
}

between_labels <- function(value){
    value[value==0] <- "Fixed effects"
    value[value==1] <- "Random effects"
    value
}

test_labels <- function(value){
    value[value==1] <- "One-sample"
    value[value==2] <- "Two-sample"
    value[value==3] <- "Unbalanced"
    value
}

nstudies_labels <- function(string){
    string <- paste(as.character(string), 'studies')
}

nsubjects_labels <- function(string){
    string <- paste(as.character(string), 'subjects')
}

units_labels <- function(string){
    string[string=="contscl"] <- "Different contrasts"    
    string[string=="datascl"] <- "Different scaling"
    string[string=="nominal"] <- "Matched units"
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

soft2_labels <- function(value){
    out_value=value
    out_value[value==0] = ""
    out_value[value!=0] = paste(as.numeric(as.character(value[value!=0]))*100, '% of the studies') 
    out_value
}

load_data_from_csv <- function(pattern, folder, iter){
    suffix <- gsub('[^a-zA-Z_0-9]', '', pattern)
    suffix <- paste(suffix, '_', iter, sep="")
    simufilename <- paste('allsimudat_', suffix,'.csv', sep="")
    csv_file = paste(getwd(), '/../../results/', simufilename, sep="")

    if (! file.exists(csv_file)){
        print(paste('pattern=', suffix))
        print(paste('CSV file', csv_file,' not found, reprocessing the data.'))
        get_expected_pval_and_equiv_z(pattern, csv_file, folder, iter)
    } else {
        print(paste('Reading from ', simufilename))
    }
    simudata <- read.csv(csv_file, header=T, sep=",")
    # Reorder unit mismatch factor levels
    simudata$unitMism = factor(simudata$unitMism,c('nominal', 'datascl', 'contscl'))
    
    return(simudata)
}





