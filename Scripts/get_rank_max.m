% Get rank taking max value in case of tied.
% e.g. get_rank_max([5 5 3 3 3 1 1 4])
% return [8 8 5 5 5 2 2 6]
function ranks = get_rank_max(v)
    [sorted_v, iv] = sort(v);
    
    [~, rank_nontied, isorted_v] = unique(sorted_v);
    unique_sorted_ranks = [rank_nontied(2:end)-1; numel(sorted_v)];
    sorted_ranks = unique_sorted_ranks(isorted_v);
    
    ranks(iv) = sorted_ranks;
end