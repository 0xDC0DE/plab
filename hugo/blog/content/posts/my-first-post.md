---
title: "Setting up my blog"
date: 2020-05-14T11:12:46Z
---

This is my first post. I just generated this blog post from markdown files using a static site generator called Hugo.
I then served the blog using Nginx web server and Traefik reverse proxy. Here's some more details on how to do all of that.

<!--more-->

## Hugo
While I am capable of building a website from scratch, I find it tedious and frustrating.
I think many of you will agree that there are more fun things to do than messing around with HTML and CSS.
So I opted to use a static site generator that does the heavy lifting for me.
Using [Hugo](https://gohugo.io/ "Hugo") I can choose from many themes, and easily customize them.
Hugo takes those markdown files, and some configuration files and generates a static website.

After installing Hugo, creating a new website is very easy. I named mine `blog`.
{{< highlight bash >}}
hugo new site blog
{{< / highlight  >}}

To add a theme, download the git repository to the `themes` folder, and update the `config.toml` file to use your theme.
You can start writing your first post! Run the following command to create the file.

{{< highlight bash >}}
hugo new posts/my-first-post.md
{{< / highlight  >}}

Edit the `my-first-post.md` file to your liking.
Writing a new blog post is done in [markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet). You can easily add hyperlinks, images, highlighted code snippets and more.
To run a local draft server execute the following command:

{{< highlight bash >}}
hugo server -D
{{< / highlight  >}}

This will serve your site to `http://localhost:1313`. If you are satisfied, you can serve this site using any web server you like.
If you want to run the site, you will need to change the `baseURL` value in the `config.toml` file accordingly in order for all style sheets to load correctly.

## Web Server
I chose to use Nginx (pronounced "engine-x") to serve my blog. Using docker it is very easy to set up a Nginx instance.
In order to serve the Hugo blog, I created my own Dockerfile based on [this blogpost](https://reyes.im/post/docker-hugo-image/).
This Dockerfile starts from alpine, and installs the latest Hugo version.
It then takes the latest version of the input and configuration files to build a static website.
Finally it copies the generated website to the Nginx hosting folder, as well as an Nginx configuration file.

{{< highlight docker >}}
FROM alpine:3.5 as build

ENV HUGO_VERSION 0.70.0
ENV HUGO_BINARY hugo_${HUGO_VERSION}_Linux-64bit.tar.gz

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
{{< / highlight >}}

To build the `blog` container run

{{< highlight bash >}}
docker build -t blog .
{{< / highlight >}}

Start the container and forward the correct port

{{< highlight bash >}}
docker run --name blog -d -p 8080:80 blog
{{< / highlight >}}

## Reverse Proxy
I did not configure routing and any security settings using Nginx, because I already have Traefik running on my homelab.
How to install, configure and run Traefik is content for an entire blogpost by itself, and there are much better guides out there than I could ever write.
But I will share my configuration to help anyone who wants to mimick what I did. To configure Traefik I use labels in my `docker-compose.yaml` files.
Since I am routing traffic through Traefik I no longer need to forward the ports. Instead I create a router called `blog-rtr` that will serve content over https on the `blog` subdomain.
Since it is a static website and I want many people to visit my blog, I do not add any middlewares at this point.

{{< highlight docker >}}
version: '3.1'
networks:
  traefik2_proxy:
    external:
      name: traefik2_proxy
services:
  blog-nginx:
    container_name: blog
    restart: unless-stopped
    image: blog
    # ports:
    #   - 8088:80
    security_opt:
      - no-new-privileges:true
    networks:
      - traefik2_proxy
    labels:
      - "traefik.enable=true"
      ## HTTP Routers
      - "traefik.http.routers.blog-rtr.entrypoints=https"
      - "traefik.http.routers.blog-rtr.rule=Host(`blog.$DOMAINNAME`)"
      - "traefik.http.routers.blog-rtr.tls=true"
      ## HTTP Services
      - "traefik.http.routers.blog-rtr.service=blog-svc"
      - "traefik.http.services.blog-svc.loadbalancer.server.port=80"
{{< / highlight >}}

And that's the behind the scenes of this blog. I had a lot of fun setting this up and enjoyed writing this first post!

-- Pieter

