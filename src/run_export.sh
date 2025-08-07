#OAR -l walltime=2:00:00

oarsub \
    -S ./export_sim.sh \
    --array-param-file export_params
