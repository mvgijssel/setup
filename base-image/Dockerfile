FROM ubuntu:bionic

ENV DISTRO_NAME ubuntu
ENV RELEASE bionic
ENV CACHE_KEY "$DISTRO_NAME:$RELEASE"

ENV container docker
ENV DEBIAN_FRONTEND noninteractive

# Setup locale
RUN apt-get update \
    && apt-get install -y locales \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG en_US.utf8
ENV LC_ALL en_US.utf8

# Setup the timezone
ENV TZ 'Europe/Amsterdam'

RUN echo $TZ > /etc/timezone \
    && apt-get update \
    && apt-get install -y tzdata \
    && rm /etc/localtime \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*
