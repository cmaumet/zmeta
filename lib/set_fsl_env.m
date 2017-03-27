function set_fsl_env()
    setenv('PATH', [getenv('PATH') ':' fullfile(getenv('FSLDIR'), 'bin')]);
    setenv('FSLOUTPUTTYPE', 'NIFTI_GZ');
end