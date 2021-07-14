ARG IMAGE_SHA_TAG=latest
ARG DOCKER_REGISTRY
FROM ${DOCKER_REGISTRY}/base-image:${IMAGE_SHA_TAG}

# Copied from https://github.com/j8r/dockerfiles/blob/master/systemd/ubuntu/20.04.Dockerfile
# Install dependencies to run systemd inside of docker
RUN apt-get update \
  && apt-get install -y systemd systemd-sysv systemd-container \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /lib/systemd/system/sysinit.target.wants/ \
  && ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
  /etc/systemd/system/*.wants/* \
  /lib/systemd/system/local-fs.target.wants/* \
  /lib/systemd/system/sockets.target.wants/*udev* \
  /lib/systemd/system/sockets.target.wants/*initctl* \
  /lib/systemd/system/basic.target.wants/* \
  /lib/systemd/system/anaconda.target.wants/* \
  /lib/systemd/system/plymouth* \
  /lib/systemd/system/systemd-update-utmp*

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/lib/systemd/systemd"]

RUN apt-get update && \
    apt-get install -y \
    squashfs-tools \
    curl \
    wget \
    sudo \
    qemu-utils \
    qemu-user-static \
    iptables \
    kpartx \
    python3-pip \
    git \
    build-essential \
    debian-keyring \
    linux-virtual \
    libguestfs-tools \
    debootstrap \
    shim-signed \
    syslinux \
    isolinux \
    syslinux-common \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install diskimage-builder

ADD load_env.sh /usr/local/sbin
