function set_fsl_env()
    setenv('PATH', [getenv('PATH') ':/usr/local/packages/fsl-5.0.7/bin']);
    setenv('FSLOUTPUTTYPE', 'NIFTI_GZ');
end