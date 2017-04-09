FROM rocker/geospatial:latest
MAINTAINER "Hiroaki Yutani" yutani.ini@gmail.com

COPY packages.list packages.list
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    openssh-client

RUN install2.r --error --deps TRUE $(cat packages.list)