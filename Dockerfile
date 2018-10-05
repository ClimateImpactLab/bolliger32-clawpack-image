FROM rhodium/worker:dev

## install Clawpack
ENV CLAW=/clawpack
# need to change shell in order for source command to work
SHELL ["/bin/bash", "-c"]
RUN source activate worker && \
  pip install --src=/ -e git+https://github.com/ClimateImpactLab/clawpack.git#egg=clawpack --no-cache-dir

## install nose for clawpack testing
RUN conda install -n worker --yes -c conda-forge \
    nose \
    pyshp

## clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN conda clean -tipsy

ENTRYPOINT ["/usr/local/bin/dumb-init", "/usr/bin/prepare.sh"]
