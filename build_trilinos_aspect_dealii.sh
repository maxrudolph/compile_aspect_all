#!/bin/bash
# Build script to install p4est, trilinos, deal.ii, and aspect on cluster.
# Modified from deal.ii dockerfiles.

# Define build directory, installation prefix, and number of build threads
BUILD_DIR=$PWD
INSTALL_PREFIX=~/libs2
CPU=40

# load modules
module purge
module load openmpi-2.0/gcc-6.3.0

# create the installation directory for all programs
mkdir $INSTALL_PREFIX

# download and build p4est
cd $BUILD_DIR
export P4EST_VERSION=1.1
wget http://p4est.github.io/release/p4est-$P4EST_VERSION.tar.gz && \
wget http://www.dealii.org/developer/external-libs/p4est-setup.sh && \
    chmod +x p4est-setup.sh && \
    ./p4est-setup.sh p4est-$P4EST_VERSION.tar.gz $INSTALL_PREFIX/p4est-$P4EST_VERSION && \
    rm -rf p4est-build p4est-$P4EST_VERSION p4est-setup.sh p4est-$P4EST_VERSION.tar.gz && \

export P4EST_DIR=$INSTALL_PREFIX/p4est-$P4EST_VERSION && \
# download and build hdf5
#export HDF5_VERSION=1.10.0-patch1 && \
#cd $BUILD_DIR && \
#wget http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-$HDF5_VERSION.tar.bz2 && \
#    tar xjf hdf5-$HDF5_VERSION.tar.bz2 && \
#    cd hdf5-$HDF5_VERSION &&  \
#    CC=mpicc CXX=mpicxx ./configure \
#         --enable-parallel \
#         --enable-shared \
#         --prefix=$INSTALL_PREFIX/hdf5-$HDF5_VERSION/ && \
#    make -j$CPU && make install && \
#    cd $BUILD_DIR && \
#    rm -rf hdf5-$HDF5_VERSION hdf5-$HDF5_VERSION.tar.bz2 
#export HDF5_DIR=$INSTALL_PREFIX/hdf5-$HDF5_VERSION

# download and build netcdf
# download and build netcdf and netcdf-cxx4
VER=4.4.1.1
wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-$VER.tar.gz && \
tar -xzf netcdf-$VER.tar.gz && \
cd netcdf-$VER && \
mkdir build && cd build && \
    cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=mpicc \
    -DCMAKE_CXX_COMPILER=mpicc \
    -DCMAKE_PREFIX_PATH=$HDF5_DIR \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/netcdf-$VER \
    -DENABLE_NETCDF_4=ON \
    .. && \
    make -j$CPU install && \
    cd $BUILD_DIR && \
    rm -rf netcdf-$VER netcdf-$VER.tar.gz
NETCDF_DIR=$INSTALL_PREFIX/netcdf-$VER

NETCDF_CXX_VER=4.3.0
cd $BUILD_DIR
wget https://github.com/Unidata/netcdf-cxx4/archive/v4.3.0.tar.gz && \
tar -xzf v4.3.0.tar.gz && \
cd netcdf-cxx4-$NETCDF_CXX_VER && \
mkdir build && cd build && \
cmake \
    -DCMAKE_PREFIX_PATH=$NETCDF_DIR \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/netcdf-cxx4-$NETCDF_CXX_VER \
    -D CMAKE_CXX_FLAGS="-O3" \
    -D CMAKE_C_FLAGS="-O3" \
    ..
make -j$CPU install && \
    cd $BUILD_DIR && \
    rm -rf netcdf-cxx4-$NETCDF_CXX_VER

# download and build trilinos
export TRILINOS_VERSION=12-8-1
cd $BUILD_DIR
wget https://github.com/trilinos/Trilinos/archive/trilinos-release-$TRILINOS_VERSION.tar.gz && \
    tar xfz trilinos-release-$TRILINOS_VERSION.tar.gz && \
    mkdir Trilinos-trilinos-release-$TRILINOS_VERSION/build && \
    cd Trilinos-trilinos-release-$TRILINOS_VERSION/build && \
    cmake \
     -D BUILD_SHARED_LIBS=ON \
     -D CMAKE_BUILD_TYPE=RELEASE \
     -D CMAKE_CXX_FLAGS="-O3" \
     -D CMAKE_C_FLAGS="-O3" \
     -D CMAKE_FORTRAN_FLAGS="-O5" \
     -D CMAKE_INSTALL_PREFIX:PATH=$INSTALL_PREFIX/trilinos-$TRILINOS_VERSION \
     -D CMAKE_VERBOSE_MAKEFILE=FALSE \
     -D TPL_ENABLE_Boost=OFF \
     -D TPL_ENABLE_MPI=ON \
     -D TPL_ENABLE_Netcdf:BOOL=OFF \
     -D TrilinosFramework_ENABLE_MPI:BOOL=ON \
     -D Trilinos_ASSERT_MISSING_PACKAGES:BOOL=OFF \
     -D Trilinos_ENABLE_ALL_OPTIONAL_PACKAGES:BOOL=ON \
     -D Trilinos_ENABLE_ALL_PACKAGES:BOOL=OFF \
     -D Trilinos_ENABLE_Amesos:BOOL=ON \
     -D Trilinos_ENABLE_AztecOO:BOOL=ON \
     -D Trilinos_ENABLE_Epetra:BOOL=ON \
     -D Trilinos_ENABLE_EpetraExt:BOOL=ON \
     -D Trilinos_ENABLE_Ifpack:BOOL=ON \
     -D Trilinos_ENABLE_Jpetra:BOOL=ON \
     -D Trilinos_ENABLE_Kokkos:BOOL=ON \
     -D Trilinos_ENABLE_Komplex:BOOL=ON \
     -D Trilinos_ENABLE_ML:BOOL=ON \
     -D Trilinos_ENABLE_MOOCHO:BOOL=ON \
     -D Trilinos_ENABLE_MueLu:BOOL=ON \
     -D Trilinos_ENABLE_OpenMP:BOOL=OFF \
     -D Trilinos_ENABLE_Piro:BOOL=ON \
     -D Trilinos_ENABLE_Rythmos:BOOL=ON \
     -D Trilinos_ENABLE_STK:BOOL=OFF \
     -D Trilinos_ENABLE_Sacado=ON \
     -D Trilinos_ENABLE_TESTS:BOOL=OFF \
     -D Trilinos_ENABLE_Stratimikos=ON \
     -D Trilinos_ENABLE_Teuchos:BOOL=ON \
     -D Trilinos_ENABLE_Thyra:BOOL=ON \
     -D Trilinos_ENABLE_Tpetra:BOOL=ON \
     -D Trilinos_ENABLE_TrilinosCouplings:BOOL=ON \
     -D Trilinos_EXTRA_LINK_FLAGS="-lgfortran" \
     -D Trilinos_VERBOSE_CONFIGURE=TRUE \
    -DLAPACK_LIBRARY_DIRS=/opt/intel/mkl/lib/intel64 \
    -DLAPACK_LIBRARY_NAMES="" \
    -D BLAS_LIBRARY_DIRS=/opt/intel/mkl/lib/intel64 \
    -D BLAS_LIBRARY_NAMES="mkl_intel_lp64;mkl_sequential;mkl_core;mkl_def" \
     .. && \

   make -j$CPU && make install && \
   cd $BUILD_DIR && \
   rm -rf Trilinos-trilinos-release-* && \
   rm -rf trilinos-release-*
export TRILINOS_DIR=$INSTALL_PREFIX/trilinos-$TRILINOS_VERSION

VER=master
BUILD_TYPE=DebugRelease
cd $BUILD_DIR && \
git clone https://github.com/dealii/dealii.git dealii-$VER-src && \
    cd dealii-$VER-src && \
    git checkout $VER && \
    mkdir build && cd build && \
    cmake -DDEAL_II_WITH_MPI=ON \
          -DDEAL_II_COMPONENT_EXAMPLES=OFF \
          -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/dealii-$VER \
          -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
          -DTRILINOS_DIR=$TRILINOS_DIR \
          -DP4EST_DIR=$P4EST_DIR \
          -DHDF5_DIR=$HDF5_DIR \
          ../ && \
    make -j$CPU install && \
    cd $BUILD_DIR && rm -rf dealii-$VER-src && \

export DEAL_II_DIR=$INSTALL_PREFIX/dealii-$VER

cd $BUILD_DIR && \
git clone https://github.com/geodynamics/aspect.git aspect-src && \
    cd aspect-src && \
    git checkout master && \
    mkdir build && cd build && \
    cmake -DDEAL_II_DIR=$DEAL_II_DIR \
          -DCMAKE_BUILD_TYPE=Release \
    ..
    make -j$CPU
    mkdir $INSTALL_PREFIX/aspect
    mv aspect $INSTALL_PREFIX/aspect.fast
    cd .. && \
	rm -rf build
    mkdir build && cd build && \
	cmake -DDEAL_II_DIR=$DEAL_II_DIR \
        -DCMAKE_BUILD_TYPE=Debug \
	..
    make -j$CPU && \
	mv aspect $INSTALL_PREFIX/aspect.debug 
    cd .. && \
	rm -rf build
    cd $BUILD_DIR && \
	rm -rf aspect-src
    
