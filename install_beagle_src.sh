#!/bin/bash

## install beagle
## expect to be called by a container install script, eg Dockerfile

## 2022.11.19
## Hmm... these apt packages maybe the actual libs for the Baysian lib.
## libhmsbeagle-dev/focal 3.1.2+dfsg-7build1 amd64
##  High-performance lib for Bayesian and Maximum Likelihood phylogenetics (devel)
##libhmsbeagle-java/focal 3.1.2+dfsg-7build1 amd64
##  High-performance lib for Bayesian and Maximum Likelihood phylogenetics (java)
##libhmsbeagle1v5/focal 3.1.2+dfsg-7build1 amd64
##  High-performance lib for Bayesian and Maximum Likelihood phylogenetics


export TERM=dumb
export NO_COLOR=TRUE
export DEBIAN_FRONTEND=noninteractive


#apt-get -y --quiet install beagle beagle-doc 
# debiang baagle package is something else (phsing genotypes), not the gpu lib used by phylogeny tree sw.
# so for beast (and MrBayes), need to build from source., per URL
# beagle: https://github.com/beagle-dev/beagle-lib/wiki/LinuxInstallInstructions
# libs needed to build beagle:
apt-get -y --quiet install cmake build-essential autoconf automake libtool git pkg-config openjdk-11-jdk subversion

echo "======================================================================"
echo "======================= installing beagle from apt ====================="
echo "======================================================================"
apt-get -y --quiet install libhmsbeagle-dev libhmsbeagle-java  libhmsbeagle1v5 

# no need for the apt pkg, which is 3.1.2
# MrBayes compiled with beagle lib in /usr/local, which is the source install below, 
# and works, at least for CPU:
# show begle 4.0.0 (pre-lrease), this is from the compiled source.

exit 0

########
########  exit for now, getting strange error like below
########  it was with beagle 4.0.0 Prerelease compiled below
########  so skipping it and only use the apt pkg to see if that works
########  
######## Singularity> /opt/MrBayes/src/mb bla
######## X Error of failed request:  BadRequest (invalid request code or no such operation)
########   Major opcode of failed request:  153 (DRI2)
########   Minor opcode of failed request:  1 (DRI2Connect)
########   Serial number of failed request:  11
########   Current serial number in output stream:  11


#### install beagle ####

echo "======================================================================"
echo "======================= installing beagle from source ====================="
echo "======================================================================"

git clone --depth=1 https://github.com/beagle-dev/beagle-lib.git
cd beagle-lib
mkdir build
cd build

#xxmkdir -p /opt/libbeagle
#cmake -DCMAKE_INSTALL_PREFIX:PATH=$HOME ..
#cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/libbeagle ..
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -DBUILD_CUDA=ON -DBUILD_OPENCL=ON -DBUILD_JNI=ON ..
make install
echo $?

echo "======================================================================"
echo "==== running make test for beagle ====="
echo "======================================================================"
make test
echo $?

echo "======================================================================"
echo "==== running make check for beagle ====="
echo "======================================================================"
make check
echo $?

date

#echo "export LD_LIBRARY_PATH=/opt/libbeagle/lib:/lib64:$LD_LIBRARY_PATH"  	>  /etc/profile.d/libbeagle.sh
#x echo "export LD_LIBRARY_PATH=/usr/local/cuda-11.7/compat:$LD_LIBRARY_PATH" 	>  /etc/profile.d/libbeagle.sh
echo "export LD_LIBRARY_PATH=/usr/local/cuda/compat:$LD_LIBRARY_PATH" 	    >  /etc/profile.d/libbeagle.sh
echo "export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"  	>> /etc/profile.d/libbeagle.sh
echo "export BEAGLE_LIB=/usr/local/lib"										>> /etc/profile.d/libbeagle.sh
echo "export JAVA_HOME=/usr/bin"    										>> /etc/profile.d/libbeagle.sh
