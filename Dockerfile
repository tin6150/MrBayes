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
    [[ -d /opt/gitrepo/mrbayes ]] || mkdir -p /opt/gitrepo/mrbayes ;\
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
  && echo  "Dockerfile 2022.0905.1249"   >> _TOP_DIR_OF_CONTAINER_   \
  && echo  "Grand Finale for Dockerfile"

ENV DBG_CONTAINER_VER  "Dockerfile 2022.0905.1249"
ENV DBG_DOCKERFILE Dockerfile_plain

ENV TZ America/Los_Angeles
# ENV TZ likely changed/overwritten by container's /etc/csh.cshrc
ENV TEST_DOCKER_ENV_REF https://vsupalov.com/docker-arg-env-variable-guide/#setting-env-values

ENTRYPOINT [ "/bin/bash" ]

# run as:
# docker run -it --entrypoint=/bin/bash  ghcr.io/tin6150/mrbayes:docker-sn50
