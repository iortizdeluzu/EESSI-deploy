# ------------------------------------------------------------------------------
# Dockerfile: CVMFS‑enabled Rocky Linux 8 container
# ------------------------------------------------------------------------------

FROM rockylinux:8

LABEL maintainer="iker.ortiz@dipc.com"
ENV DEBIAN_FRONTEND=noninteractive

# ---- Install EPEL, CVMFS repo, and CVMFS itself -----------------------------
RUN dnf -y install epel-release curl gcc make which git sudo wget bzip2 rsync bc httpd && \
    yum install -y https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm && \
    dnf clean all && \
    dnf -y install cvmfs cvmfs-config-default && \
    dnf clean all

# ---- Add non-root user ------------------------------------------------------
RUN useradd -m scicomp && echo "scicomp ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# ---- Install EasyBuild ------------------------------------------------------
RUN git clone https://github.com/dilasgoi/sci-env  
    #cd sci-env/scripts/ && ./install.sh

# ---- Create directories and configuration -----------------------------------
RUN mkdir -p /etc/cvmfs/keys \
             /etc/cvmfs/config.d \
             /cvmfs/example.domain.tld && \
    echo "CVMFS_SERVER_URL=http://158.227.172.103/cvmfs/@fqrn@"   >  /etc/cvmfs/config.d/example.domain.tld.conf && \
    echo "CVMFS_PUBLIC_KEY=/etc/cvmfs/keys/example.domain.tld.pub" >> /etc/cvmfs/config.d/example.domain.tld.conf && \
    echo "CVMFS_HTTP_PROXY=DIRECT"                                >> /etc/cvmfs/config.d/example.domain.tld.conf

# ---- Inicialize CVMFS --------------------------------------------------------
#RUN cvmfs_config setup\
#    cvmfs_config reload example.domain.tld

# ---- Copy your stratum0 keys ----------------------------------------------------
COPY example.domain.tld.pub example.domain.tld.crt example.domain.tld.masterkey /etc/cvmfs/keys/

# ---- Default startup ---------------------------------------------------------
# You need FUSE privileges to mount; the CMD prints a hint, then drops to bash.
CMD echo "CVMFS container ready. Run with --cap-add SYS_ADMIN --device /dev/fuse and then execute:\n  cvmfs2 -o config=/etc/cvmfs/default.local example.domain.tld /cvmfs/example.domain.tld" && exec mount -t cvmfs example.domain.tld /cvmfs/example.domain.tld && /bin/bash
