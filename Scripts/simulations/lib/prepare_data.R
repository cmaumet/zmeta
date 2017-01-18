prepare_data <- function(data_list){
    for (i in seq(1, length(data_list))){
        # Ignore soft2Factor=100 (too extreme)
        # print(length(data))
        # print(head(data))
        data_list[[i]] = subset(data_list[[i]], soft2Factor<100)
        data_list[[i]]$Within <- factor(data_list[[i]]$Within)
        }
    return(data_list)
}