FROM alpine:3.5 as build

ENV HUGO_VERSION 0.70.0
ENV HUGO_BINARY hugo_${HUGO_VERSION}_Linux-64bit.tar.gz

# Install Hugo
RUN set -x && \
  apk add --update wget ca-certificates && \
  wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} && \
  tar xzf ${HUGO_BINARY} && \
  rm -r ${HUGO_BINARY} && \
  mv hugo /usr/bin && \
  apk del wget ca-certificates && \
  rm /var/cache/apk/*

COPY ./blog /site

WORKDIR /site

RUN /usr/bin/hugo

FROM nginx:alpine

LABEL maintainer Pieter De Cremer <pieter.decremer@gmail.com>

COPY ./conf/default.conf /etc/nginx/conf.d/default.conf

COPY --from=build /site/public /var/www/site

WORKDIR /var/www/site
