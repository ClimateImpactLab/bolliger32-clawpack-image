FROM rhodium/worker:v0.2.5

## install Clawpack
ENV CLAW=/clawpack

# need to change shell in order for source command to work
SHELL ["/bin/bash", "-c"]

RUN source activate worker && \
  pip install --src=/ -e git+https://github.com/ClimateImpactLab/clawpack.git#egg=clawpack --no-cache-dir

## currently also pinning rhg_compute_tools
## until the workers get updated with a newer version
## that has the commands we need
RUN source activate worker && \
  pip install pytides rhg_compute_tools>=0.1.6 --no-cache-dir

ENTRYPOINT ["/usr/local/bin/dumb-init", "/usr/bin/prepare.sh"]
