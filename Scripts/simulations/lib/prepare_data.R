prepare_data <- function(data_list, max_z=NA, min_z=NA){
    for (i in seq(1, length(data_list))){
        # Ignore soft2Factor=100 (too extreme)
        # print(length(data))
        # print(head(data))
        data_list[[i]] = subset(data_list[[i]], soft2Factor<100)
        data_list[[i]]$Within <- factor(data_list[[i]]$Within)
               
        if (! is.na(max_z)){
            data_list[[i]] = subset(data_list[[i]], expectedz<max_z)
        }
        if (! is.na(min_z)){
            data_list[[i]] = subset(data_list[[i]], expectedz>min_z)
        }
    }
        
    return(data_list)
}