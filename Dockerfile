FROM continuumio/miniconda3:4.4.10

# Dumb init
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

USER root

## install packages from apt-get
RUN apt-get update \
  && apt-get install -yq libfuse-dev nano fuse gnupg gnupg2 make gfortran m4 curl libcurl4-openssl-dev liblapack-dev g++
ENV CC=gcc
ENV FC=gfortran

## update conda and pip
RUN conda update --yes conda
RUN pip install --upgrade pip


## NETCDF INSTALL
# set library location
ENV PREFIXDIR=/usr/local

## get zlib
RUN wget https://zlib.net/zlib-1.2.11.tar.gz && tar -xvzf zlib-1.2.11.tar.gz
RUN cd zlib-1.2.11; \
    ./configure --prefix=${PREFIXDIR}; \
    make check; \
    make install; \
    rm -rf /zlib-1.2.11.tar.gz /zlib-1.2.11


## get hdf5-1.8
RUN wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.21/src/hdf5-1.8.21.tar.gz && tar -xvzf hdf5-1.8.21.tar.gz
RUN cd hdf5-1.8.20; \
    ./configure --with-zlib=${PREFIXDIR} --prefix=${PREFIXDIR} --enable-hl; \
    make check; \
    make install; \
    rm -rf /hdf5-1.8.21.tar.gz /hdf5-1.8.21
    

## get hdf5-1.10
RUN wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.2/src/hdf5-1.10.2.tar.gz && tar -xvzf hdf5-1.10.2.tar.gz
RUN cd hdf5-1.10.2; \
    ./configure --with-zlib=${PREFIXDIR} --prefix=${PREFIXDIR} --enable-hl --enable-shared; \
    make check; \
    make install; \
    rm -rf /hdf5-1.10.2.tar.gz /hdf5-1.10.2


## get netcdf-c
RUN wget https://github.com/Unidata/netcdf-c/archive/v4.6.1.tar.gz && tar -xvzf v4.6.1.tar.gz
ENV LD_LIBRARY_PATH=${PREFIXDIR}/lib
RUN cd netcdf-c-4.6.1; \
    CPPFLAGS=-I${PREFIXDIR}/include LDFLAGS=-L${PREFIXDIR}/lib ./configure --prefix=${PREFIXDIR} --enable-netcdf-4 --enable-shared --enable-dap; \
    make check; \
    make install; \
    rm -rf /v4.6.1.tar.gz /netcdf-c-4.6.1
    
    
## get netcdf-fortran
RUN wget https://github.com/Unidata/netcdf-fortran/archive/v4.4.4.tar.gz && tar -xvzf v4.4.4.tar.gz
RUN cd netcdf-fortran-4.4.4; \
    CPPFLAGS=-I${PREFIXDIR}/include LDFLAGS=-L${PREFIXDIR}/lib ./configure --prefix=${PREFIXDIR}; \
    make check; \
    make install; \
    rm -rf /v4.4.4.tar.gz /netcdf-fortran-4.4.4


## CONDA INSTALLS
RUN conda install --yes -c conda-forge \
    bokeh=0.12.14 \
    cartopy \
    click \
    cytoolz \
    datashader \
    dask=0.17.2 \
    distributed=1.21.5 \
    esmpy \
    fastparquet \
    fusepy \
    gdal=2.2.4 \
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
    nomkl \
    nose \
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
    
RUN conda install --yes --channel conda-forge/label/dev geopandas
    
    
## GCSFUSE
RUN export GCSFUSE_REPO=gcsfuse-xenial \
  && echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
  && apt-get update \
  && apt-get install gcsfuse \
  && alias googlefuse=/usr/bin/gcsfuse


# install pip pacakges
RUN pip install \
    netCDF4 \
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
