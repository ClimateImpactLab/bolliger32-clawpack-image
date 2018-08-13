FROM rhodium/worker:2018-08-07.01

USER root

## install packages from apt-get
RUN apt-get update \
  && apt-get install -yq make gfortran m4 curl libcurl4-openssl-dev liblapack-dev g++
ENV CC=gcc
ENV FC=gfortran


## update pip
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


## install Clawpack
ENV CLAW=/clawpack
RUN pip install --src=/ -e git+https://github.com/ClimateImpactLab/clawpack.git#egg=clawpack --no-cache-dir


## install nose for clawpack testing
RUN conda install --yes -c conda-forge \
    nose
    pyshp


## clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN conda clean -tipsy


ENTRYPOINT ["/usr/local/bin/dumb-init", "/usr/bin/prepare.sh"]
