# ------------------------------------------------------------------------------
# Dockerfile: Gentoo-prefix Rocky Linux 8 container
# ------------------------------------------------------------------------------

FROM rockylinux:8

LABEL maintainer="carlos.perez@dipc.com"
ENV DEBIAN_FRONTEND=noninteractive

## ---- Create directories and configuration -----------------------------------
#RUN mkdir -p /etc/cvmfs/keys \
             #/etc/cvmfs/config.d \
             #/cvmfs/example.domain.tld && \
    #echo "CVMFS_SERVER_URL=http://158.227.172.103/cvmfs/@fqrn@"   >  /etc/cvmfs/config.d/example.domain.tld.conf && \
    #echo "CVMFS_PUBLIC_KEY=/etc/cvmfs/keys/example.domain.tld.pub" >> /etc/cvmfs/config.d/example.domain.tld.conf && \
    #echo "CVMFS_HTTP_PROXY=DIRECT"                                >> /etc/cvmfs/config.d/example.domain.tld.conf

# ---- Inicialize CVMFS --------------------------------------------------------
#RUN cvmfs_config setup\
#    cvmfs_config reload example.domain.tld

## ---- Copy your public key ----------------------------------------------------
#COPY example.domain.tld.pub /etc/cvmfs/keys/example.domain.tld.pub

# ---- Default startup ---------------------------------------------------------
# You need FUSE privileges to mount; the CMD prints a hint, then drops to bash.
#CMD echo "CVMFS container ready. Run with --cap-add SYS_ADMIN --device /dev/fuse and then execute:\n  cvmfs2 -o config=/etc/cvmfs/default.local example.domain.tld /cvmfs/example.domain.tld" && exec mount -t cvmfs example.domain.tld /cvmfs/example.domain.tld && /bin/bash

## ---- Install EPEL, CVMFS repo, and CVMFS itself -----------------------------
#RUN dnf -y install epel-release curl gcc make which git sudo wget bzip2 rsync bc
#RUN yum install -y https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm
#RUN dnf clean all
#RUN dnf -y install cvmfs cvmfs-config-default
#RUN dnf clean all

# ---- Add non-root user ------------------------------------------------------
ARG UID=1001
ARG GID=1001

RUN groupadd -g $GID scicomp && \
    useradd -m -u $UID -g $GID scicomp && \
    echo "scicomp ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
ENV USER=scicomp
ENV HOME=/home/scicomp
WORKDIR /home/scicomp

## ---- Install EasyBuild ------------------------------------------------------
#RUN git clone https://github.com/dilasgoi/sci-env
#RUN chown -R scicomp:scicomp /sci-env
##New addition so easybuild is installed in the container build
#ENV USER=scicomp
#ENV HOME=/home/scicomp
#WORKDIR /home/scicomp
#USER scicomp
## Install EasyBuild during the build
#RUN cd /sci-env/scripts && bash install.sh

# ---- Install archspec -----
RUN dnf -y install python3.12
RUN dnf -y install python3.12-pip
RUN pip3 install archspec
WORKDIR /home/scicomp

# Download gentoo-prefix
RUN dnf -y install epel-release wget curl gcc make which git sudo wget bzip2 rsync bc
WORKDIR /home/scicomp
RUN wget https://gitweb.gentoo.org/repo/proj/prefix.git/plain/scripts/bootstrap-prefix.sh
RUN chmod +x ./bootstrap-prefix.sh

# Copy script to install gentoo prefix
COPY install_gentoo_prefix.sh ./install_gentoo_prefix.sh
RUN chmod +x ./install_gentoo_prefix.sh
