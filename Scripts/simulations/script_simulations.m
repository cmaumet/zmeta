% Scipt run to get the simulation results
cd('/Users/cmaumet/Projects/Meta-analysis/Results/2014-06-23 Z-meta')

% Run simulations
simulations(fullfile(pwd, 'data'))

% Export p-values into csv file
export_full_simulations('/Volumes/camille/MBIA_buster')

// In R
get_expected_pval_and_equiv_z.R
plot_simluations()