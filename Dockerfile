FROM rhodium/worker:dev

## install Clawpack
ENV CLAW=/clawpack

# need to change shell in order for source command to work
SHELL ["/bin/bash", "-c"]

RUN source activate worker && \
  pip install --src=/ -e git+https://github.com/ClimateImpactLab/clawpack.git#egg=clawpack --no-cache-dir

ENTRYPOINT ["/usr/local/bin/dumb-init", "/usr/bin/prepare.sh"]
