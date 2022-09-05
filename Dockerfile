# Docker definition file to build 
# Install MrBayes+Beagle3 inside an Ubuntu 20.04 Docker container

FROM ubuntu:focal 

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
    apt-get -y --quiet install git file wget gzip bash less vim procps ;\
    test -d /opt/gitrepo/mrbayes || mkdir -p /opt/gitrepo/mrbayes ;\
    echo ''

COPY . /opt/gitrepo/mrbayes/


RUN echo  ''  ;\
    cd /opt/gitrepo/mrbayes ;\
    echo 'Invoking install script...' ;\
    echo '==========================' ;\
    bash -x ./install4ubuntu.sh 2>&1 | tee install_script.log ;\
    echo '========done====Invoking install script===========================' ;\
    echo ''

RUN  cd / \
  && touch _TOP_DIR_OF_CONTAINER_  \
  && echo  "--------" >> _TOP_DIR_OF_CONTAINER_   \
  && TZ=PST8PDT date  >> _TOP_DIR_OF_CONTAINER_   \
  && echo  "Dockerfile 2022.0905.1319"   >> _TOP_DIR_OF_CONTAINER_   \
  && echo  "Grand Finale for Dockerfile"

ENV DBG_CONTAINER_VER  "Dockerfile 2022.0905.1319"
ENV DBG_DOCKERFILE Dockerfile_plain

ENV TZ America/Los_Angeles
# ENV TZ likely changed/overwritten by container's /etc/csh.cshrc
ENV TEST_DOCKER_ENV_REF https://vsupalov.com/docker-arg-env-variable-guide/#setting-env-values

#ENTRYPOINT [ "/bin/bash" ]
ENTRYPOINT [ "/opt/gitrepo/mrbayes/MrBayes/src/mb" ]

# run as:
# docker run -it --entrypoint=/bin/bash  ghcr.io/tin6150/mrbayes:docker-sn50
# docker run -it -v /home:/mnt           ghcr.io/tin6150/mrbayes:docker-sn50
# singularity run docker://ghcr.io/tin6150/mrbayes:docker-sn50                  # for system with inet access
# singularity pull --name mrBayes docker://ghcr.io/tin6150/mrbayes:docker-sn50  # on login node
# singularity exec mrBayes /opt/gitrepo/mrbayes/MrBayes/src/mb                  # on compute node w/oout inet access
#### if "mb" fails to run with error "Illegal instruction"
#### it is CPU microcode optimization used by the build process.  Try with machine with newer CPU :)
#### the docker hub image below was build on my old desktop that does not have the newer CPU microcodes
#### and thus work in more places
# manual build
# docker build -t tin6150/mybayes:vbeta -f Dockerfile .  | tee LOG.Dockerfile
# docker image push tin6150/mybayes:vbeta 
# docker run -it -v /home:/mnt           tin6150/mrbayes:vbeta                 # require docker login now??!!
# singularity pull --name mrBayes4oldCpu docker://tin6150/mrbayes:vbeta

