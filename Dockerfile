# Docker definition file to build 
# Install MrBayes+Beagle3 inside an Ubuntu 20.04 Docker container
# MPI 
# MrBayes at github master (v3.2.7a)

#FROM ubuntu:focal 
FROM nvidia/cuda:11.4.2-devel-ubuntu20.04

LABEL Source1="https://github.com/NBISweden/MrBayes"
LABEL Source2="https://github.com/beagle-dev/beagle-lib/wiki/LinuxInstallInstructions"
LABEL Source3="https://hub.docker.com/r/nvidia/cuda/tags?page=1&name=11.4.2-devel-ubuntu"
LABEL description="this is a containerazation of the MrBayes phylogenetic software, \
build with beagle-lib with GPU support, utilizing nvidia CUDA docker images as substrate"

MAINTAINER Tin_at_berkeley.edu
ARG DEBIAN_FRONTEND=noninteractive
#ARG TERM=vt100
ARG TERM=dumb
ARG TZ=PST8PDT
#https://no-color.org/
ARG NO_COLOR=1

RUN echo  ''  ;\
    touch _TOP_DIR_OF_CONTAINER_  ;\
    echo "begining docker build process at " | tee -a _TOP_DIR_OF_CONTAINER_  ;\
    date | tee -a       _TOP_DIR_OF_CONTAINER_ ;\
    echo "installing packages via apt"       | tee -a _TOP_DIR_OF_CONTAINER_  ;\
    export TERM=dumb      ;\
    export NO_COLOR=TRUE  ;\
    apt-get update ;\
    apt-get -y --quiet install git git-all file wget curl gzip bash zsh fish tcsh less vim procps screen tmux ;\
    apt-get -y --quiet install apt-file ;\
    test -d /opt/gitrepo/mrbayes || mkdir -p /opt/gitrepo/mrbayes ;\
    echo ''

#COPY . /opt/gitrepo/mrbayes/
COPY . /opt/gitrepo/container/

RUN echo  ''  ;\
    touch _TOP_DIR_OF_CONTAINER_  ;\
    date | tee -a       _TOP_DIR_OF_CONTAINER_ ;\
    export TERM=dumb      ;\
    export NO_COLOR=TRUE  ;\
    cd /     ;\
    cd /opt/gitrepo/container     ;\
    git branch |tee /opt/gitrepo/container/git.branch.out.txt                 ;\
    cd /    ;\
    echo ""

RUN echo  ''  ;\
    touch _TOP_DIR_OF_CONTAINER_  ;\
    date | tee -a       _TOP_DIR_OF_CONTAINER_ ;\
    export TERM=dumb      ;\
    export NO_COLOR=TRUE  ;\
    cd /     ;\
    echo ""  ;\
    echo '==================================================================' ;\
    echo '==== install beagle gpu lib ======================================' ;\
    echo '==================================================================' ;\
    echo " calling external shell script..." | tee -a _TOP_DIR_OF_CONTAINER_  ;\
    echo " cd to /opt/                  "    | tee -a _TOP_DIR_OF_CONTAINER_  ;\
    echo '==================================================================' ;\
    # the install from source repo create dir, so cd /opt             ;\
    cd /opt                                                                   ;\
    ln -s /opt/gitrepo/container/install_beagle_src.sh .                      ;\
    bash -x install_beagle_src.sh 2>&1 | tee install_beagle_src.log           ;\
    cd /    ;\
    echo ""



RUN echo  ''  ;\
    echo '==================================================================' ;\
    echo '==== install MrBayes phylo sw ====================================' ;\
    echo '==================================================================' ;\
    echo " calling external shell script..." | tee -a _TOP_DIR_OF_CONTAINER_  ;\
    date | tee -a      _TOP_DIR_OF_CONTAINER_                                 ;\
    echo '==================================================================' ;\
    # the install from source repo create dir, so cd /opt/ gitrepo             ;\
    cd /opt ;\
    #XXln -s /opt/gitrepo/mrbayes/./install4ubuntu.sh /opt ;\
    ln -s /opt/gitrepo/container/install4ubuntu.sh /opt ;\
    bash -x ./install4ubuntu.sh 2>&1 | tee install_script.log ;\
    echo '========done====Invoking install script===========================' ;\
    #xxln -s /opt/gitrepo/container/src/mb /bin ;\
    ln -s /opt/MrBayes/src/mb /bin ;\
    ln -s /opt/MrBayes/src/mb /opt ;\
    echo ''

ENV DBG_CONTAINER_VER  "Dockerfile 2022.1119.0958"
ENV DBG_DOCKERFILE Dockerfile_plain

RUN  cd / \
  && touch _TOP_DIR_OF_CONTAINER_  \
  && echo  "--------" >> _TOP_DIR_OF_CONTAINER_   \
  && TZ=PST8PDT date  >> _TOP_DIR_OF_CONTAINER_   \
  && echo  "$DBG_CONTAINER_VER"   >> _TOP_DIR_OF_CONTAINER_   \
  && echo  "Grand Finale for Dockerfile"


ENV TZ America/Los_Angeles

#ENTRYPOINT [ "/bin/bash" ]
#ENTRYPOINT [ "/opt/gitrepo/mrbayes/MrBayes/src/mb" ]
#ENTRYPOINT [ "/opt/gitrepo/container/src/mb" ]
ENTRYPOINT [ "/opt/MrBayes/src/mb" ]

# run as:
# docker run -it --entrypoint=/bin/bash  ghcr.io/tin6150/mrbayes:docker-sn50
# docker run -it -v /home:/mnt           ghcr.io/tin6150/mrbayes:docker-sn50
# singularity run docker://ghcr.io/tin6150/mrbayes:docker-sn50                  # for system with inet access
# singularity pull --name mrBayes docker://ghcr.io/tin6150/mrbayes:docker-sn50  # on login node
# singularity exec mrBayes /opt/gitrepo/mrbayes/MrBayes/src/mb                  # on compute node w/out inet access
#### if "mb" fails to run with error "Illegal instruction"
#### it is CPU microcode optimization used by the build process.  Try with machine with newer CPU :)
#### the docker hub image below was build on my old desktop that does not have the newer CPU microcodes
#### and thus work in more places
# manual build
# docker build -t tin6150/mybayes:vbeta -f Dockerfile .  | tee LOG.Dockerfile
# docker image push tin6150/mybayes:vbeta 
# docker run -it -v /home:/mnt           tin6150/mrbayes:vbeta                 # TBD...require docker login now??!!
# singularity pull --name mrBayes4oldCpu docker://tin6150/mrbayes:vbeta

