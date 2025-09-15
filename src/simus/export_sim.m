function export_sim(spm_path, niter)
  code_dir = fileparts(mfilename('fullpath'));
    
  addpath(fullfile(code_dir, 'lib'))
  % SPM is required
  if isempty(which('spm'))
      addpath(path_to_spm)
  end

  % ----- Load configuration file ----
  base_dir = config_path();

  ndatapoints = 30*30*30*niter
  export_full_simulations(ndatapoints, base_dir, false)
end
