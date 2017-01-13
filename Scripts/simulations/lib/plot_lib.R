method_labels <- function(string) {
    string[string=="megaMFX"] <- "MFX"
    string[string=="megaRFX"] <- "RFX"
    string[string=="permutCon"] <- "Perm. E"
    string[string=="permutZ"] <- "Perm. Z"
    string[string=="stouffersMFX"] <- "Stouf."
    string
}

units_labels <- function(string){
    string[string=="contscl 1 0"] <- "Different contrast vector scaling"    
    string[string=="contscl 1"] <- "Different contrast vector scaling"
    string[string=="datascl 2"] <- "Different scaling algorithm (same target)"
    string[string=="datascl 2 0.2"] <- "Different scaling algorithm (same target) - 20%"
    string[string=="datascl 2 0.5"] <- "Different scaling algorithm (same target) - 50%"        
    string[string=="nominal 1 0"] <- "Nominal"
    string[string=="nominal 1"] <- "Nominal"
    string[string=="datascl 100 0.2"] <- "Different scaling target - 20%"
    string[string=="datascl 100"] <- "Different scaling target"
    string[string=="datascl 100 0.5"] <- "Different scaling target - 50%"
    string
}

soft2Factor_labels <- function(string){
    string[string==1] <- "none"
    string[string==2] <- "algorithm"
    string[string==100] <- "baseline"
    string
}