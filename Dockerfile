FROM continuumio/miniconda3:4.4.10

# Dumb init
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

USER root


## install packages from apt-get
RUN apt-get update \
  && apt-get install -yq --no-install-recommends libfuse-dev nano fuse gnupg gnupg2 make gfortran m4 curl libcurl4-openssl-dev


## update conda and pip
RUN conda update --yes conda
RUN pip install --upgrade pip


## get netcdf-c
RUN conda install --yes hdf5 zlib
RUN wget https://github.com/Unidata/netcdf-c/archive/v4.6.1.tar.gz && tar -xvzf v4.6.1.tar.gz
ENV LD_LIBRARY_PATH=/opt/conda/lib
ENV NCDIR=/usr/local
RUN cd netcdf-c-4.6.1; \
    CPPFLAGS=-I/opt/conda/include LDFLAGS=-L/opt/conda/lib ./configure --prefix=${NCDIR}; \
    make check; \
    make install; \
    rm -rf /v4.6.1.tar.gz /netcdf-c-4.6.1
    
    
## get netcdf-fortran
RUN wget https://github.com/Unidata/netcdf-fortran/archive/v4.4.4.tar.gz && tar -xvzf v4.4.4.tar.gz
ENV LD_LIBRARY_PATH=${NCDIR}/lib:/opt/conda/lib
ENV CC=gcc
ENV FC=gfortran
ENV NFDIR=/usr/local
RUN cd netcdf-fortran-4.4.4; \
    CPPFLAGS=-I${NCDIR}/include LDFLAGS=-L${NCDIR}/lib ./configure --prefix=${NFDIR}; \
    make check; \
    make install; \
    rm -rf /v4.4.4.tar.gz /netcdf-fortran-4.4.4


## conda installs
RUN conda install --yes -c conda-forge \
    bokeh=0.12.14 \
    click \
    cytoolz \
    datashader \
    dask=0.17.2 \
    distributed=1.21.5 \
    esmpy \
    fastparquet \
    fusepy \
    gdal=2.2.4 \
    geopandas \
    gfortran_linux-64 \
    git \
    ipywidgets \
    jedi \
    jupyterlab \
    kubernetes \
    holoviews \
    lz4=1.1.0 \
    matplotlib \
    nb_conda_kernels \
    netcdf4 \
    nomkl \
    numba=0.37.0 \
    numcodecs \
    numpy=1.14.2 \
    pandas \
    pyasn1 \
    pyshp \
    python-blosc=1.4.4 \
    rasterio \
    scikit-image \
    scipy \
    setuptools \
    tornado \
    urllib3 \
    wget \
    xarray=0.10.7 \
    xesmf \
    zarr \
    zict
    
    
## GCSFUSE
RUN export GCSFUSE_REPO=gcsfuse-xenial \
  && echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
  && apt-get update \
  && apt-get install gcsfuse \
  && alias googlefuse=/usr/bin/gcsfuse


# install pip pacakges
RUN pip install \
    google-cloud==0.32.0 \
    google-cloud-storage \
    gsutil \
    daskernetes==0.1.3 \
    git+https://github.com/dask/dask-kubernetes@5ba08f714ef38e585e9f2038b6be530c578b96dd \
    git+https://github.com/ioam/holoviews@3f015c0a531f54518abbfecffaac72a7b3554ed3 \
    git+https://github.com/dask/gcsfs@2fbdc27e838a531ada080886ae778cb370ae48b8 \
    git+https://github.com/jupyterhub/nbserverproxy \
    --no-cache-dir
    
    
## install Clawpack
ENV CLAW=/clawpack
RUN pip install --src=/ -e git+https://github.com/ClimateImpactLab/clawpack.git#egg=clawpack --no-cache-dir


## clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN conda clean -tipsy


## misc
ENV OMP_NUM_THREADS=1
ENV DASK_TICK_MAXIMUM_DELAY=5s

USER root
COPY prepare.sh /usr/bin/prepare.sh
RUN chmod +x /usr/bin/prepare.sh
RUN mkdir /opt/app
RUN mkdir /gcs

ENTRYPOINT ["/usr/local/bin/dumb-init", "/usr/bin/prepare.sh"]
