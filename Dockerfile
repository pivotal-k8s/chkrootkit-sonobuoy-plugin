FROM debian:stable

MAINTAINER Hannes Hoerl

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update \
  && apt-get -y install chkrootkit \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/cache/apt/*

COPY check.sh /check.sh

CMD [ "sh", "-c", "/check.sh ; sleep infinity" ]
