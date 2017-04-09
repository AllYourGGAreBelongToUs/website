FROM rocker/geospatial:latest
MAINTAINER "Hiroaki Yutani" yutani.ini@gmail.com

FILE packages.list
RUN install2.r --error --deps TRUE $(cat packages.list)