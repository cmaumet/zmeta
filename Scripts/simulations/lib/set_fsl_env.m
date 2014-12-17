function set_fsl_env()
    setenv('PATH', [getenv('PATH') ':/usr/local/fsl/bin']);
    setenv('FSLOUTPUTTYPE', 'NIFTI_GZ');
end