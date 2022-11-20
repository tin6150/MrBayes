#!/bin/bash

# script invoked by github workflow to contain docker container
# use Ubuntu base.
# commands from INSTALL-Docker-Ubuntu.md
# except for Beagle, which didn't work, and I used my own script
#
# Install MrBayes+Beagle3 inside an Ubuntu 20.04 Docker container


echo "======================================================================"
echo "===== installing Beagle and MrBayes from their git repo release ======"
echo "======================================================================"

# beagle-lib env to use with gpu created by previous install script
# make install to /usr/local
[[ -f /etc/profile.d/libbeagle.sh ]] && source /etc/profile.d/libbeagle.sh


# - Status (June 2020):
#     - CUDA: N/A
#    - OpenCL: OK
#    - OpenMPI: OK
#    - Beagle3: OK
#    - MrBayes+MPI: OK
#    - MrBayes: OK
#
#- This file describes a "proof-of-concept" installation of the develop branch
#  of MrBayes with Beagle. The installation is made inside a Docker container,
#  hence, this is *not* a Dockerfile.
#
#- Instructions for Debian are identical, but you would use a Debian container
#  such as `debian:sid` instead of `ubuntu:20.04`.
#
#- We could not get beagle to work from inside MrBayes unless Beagle is
#  configured using `-rpath`, or `LD_LIBRARY_PATH` is set before running
#  MrBayes.
#
#- When configuring the beagle library, we expect to see these warning messages
#  (since we asked for not using CUDA or Java):
#    - `WARNING: NVIDIA CUDA nvcc compiler not found`
#    - `WARNING: JDK installation not found`
#
#- We are not building the LaTeX version of the documentation for MrBayes. For
#  building the documentation, we recommend to use the `latexmk` script.  Using
#  `apt install latexmk texlive-latex-extra` will install the script an all
#  necessary TeX-libraries.
#
#- When running the MPI (parallel) version of MrBayes inside the Docker
#  container, we need to use `--allow-run-as-root` (since we are starting
#  `mpirun` as user `root`).

## Install and run
#
#    $ docker run -it ubuntu:20.04 /bin/bash

#### trying to reduce verbose log output
export TERM=dumb
export NO_COLOR=1
export DEBIAN_FRONTEND=noninteractive

    # Base system
    apt update -y && apt upgrade -y

    DEBIAN_FRONTEND=noninteractive apt install -y tzdata

    apt install -y \
        autoconf \
        g++ \
        git \
        libreadline-dev \
        libtool \
        make

echo "============================================================"
echo "============================================================"

echo "====installing openCL===="

    # OpenCL
    apt install -y \
        ocl-icd-opencl-dev \
        pocl-opencl-icd

echo "====installing openMPI===="

    # OpenMPI
    apt install -y \
        libopenmpi-dev

echo "==== beagle-lib pre-done by separate install script ===="

    # Beagle
    #xx git clone --depth=1 https://github.com/beagle-dev/beagle-lib.git
    #xx cd beagle-lib
    #xx ./autogen.sh
    #LDFLAGS=-Wl,-rpath=/usr/local/lib ./configure --without-jdk --disable-doxygen-doc
    #make -j2
    #make install

	### instructions per https://github.com/beagle-dev/beagle-lib/wiki/LinuxInstallInstructions

    ##cd /
    #xx cd ..

echo "====installing MrBayes ===="

    # MrBayes
    git clone --depth=1 --branch=develop https://github.com/NBISweden/MrBayes.git
    cd MrBayes
    ## ./configure --with-mpi --enable-doc=no
    #./configure --with-mpi --enable-doc=yes --with-beagle=/opt/beagle-lib
    #--./configure --with-mpi --enable-doc=yes --with-beagle=/usr/local					# from local comile v4.0.0 prerelease
    ./configure --with-mpi --enable-doc=yes --with-beagle=/usr/lib/x86_64-linux-gnu/  	# from apt install libhmsbeagle1v5 3.1.2
    make -j2

    # Test MPI (parallel) version
    mpirun --allow-run-as-root -np 1 src/mb <<< 'version;showb;quit'

	### this produce a serial version, but overwrite prev build?  why?  missing a test condition?
    #?? make clean
    #?? ./configure --enable-doc=no
    #?? make -j2

    # Test serial version
    src/mb <<< 'version;showb;quit'


echo $?
date
