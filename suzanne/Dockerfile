FROM nginx:alpine

LABEL maintainer Pieter De Cremer <pieter.decremer@gmail.com>

COPY ./site /var/www/site

COPY ./conf/default.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/site
