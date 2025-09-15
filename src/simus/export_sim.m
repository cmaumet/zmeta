function export_sim(niter)
  addpath('~/code/zmeta/Scripts')
  addpath('~/code/spm12-r7771')

  % ----- Load configuration file ----
  base_dir = config_path();
  
  ndatapoints = 30*30*30*niter
  export_full_simulations(ndatapoints, base_dir, false)
end
