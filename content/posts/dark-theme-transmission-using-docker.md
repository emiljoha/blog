+++
title = "Dark Theme Transmission Web UI Using Docker"
date = 2020-04-26T20:36:52+02:00
draft = false
tags = []
categories = ["transmission", "docker", "docker-compose", "dark theme"]
+++

Having a dark color schemme is becoming more and more popular. This post
covers how to create and run a transmission docker container modified to have
a dark website UI. The [linuxserver.io](linuxserver.io) transmission docker
images provide the base, taking care of all the nitty gritty in getting
transmission installed and ready for action. Installing
[transmission-web-soft-theme](https://git.eigenlab.org/sbiego/transmission-web-soft-theme)
on top of the transmission image will give a nice dark web ui.

Credit to the
[transmission-web-soft-theme](https://git.eigenlab.org/sbiego/transmission-web-soft-theme)
for the screenshot of the theme in action.

![soft dark](/transmission-web-soft-dark-screen.png)

To get everything up and running we need:

1. `Dockerfile` defining our changes to the `linuxserver/transmission`
   image.
2. A `docker-compose.yml` telling docker how to run the container image.

# The Dockerfile

The [`FROM`](https://docs.docker.com/engine/reference/builder/#from) statement
sets the base image over which we can make our custom changes to
[linuxserver.io](linuxserver.io).

Using [`RUN`](https://docs.docker.com/engine/reference/builder/#run) it is
possible to execute arbitrary shell commands. In this case the command is to
download the
[transmission-web-soft-theme](https://git.eigenlab.org/sbiego/transmission-web-soft-theme)
repository as a `tar` ball, extracting the files, and running the install
script provided in the theme repo. All according to the installation
instruction on the [project wiki](https://git.eigenlab.org/sbiego/transmission-web-soft-theme/wikis/home)

Finally, we expose the necessary ports and declare the persistent volumes for
configuration and downloads.

Save the `Dockerfile` in an empty directory.

```dockerfile
FROM linuxserver/transmission:latest

RUN \
    curl --output transmission-web-soft-theme-master.tar \
    https://git.eigenlab.org/sbiego/transmission-web-soft-theme/-/archive/master/transmission-web-soft-theme-master.tar && \
    tar --extract -f transmission-web-soft-theme-master.tar && \
    cd transmission-web-soft-theme-master && \
    printf '%s\n' 1 | bash install.sh && \
    rm -rf transmission-web-soft-theme-master.tar transmission-web-soft-theme-master

EXPOSE 9091 51413
VOLUME /config /downloads
```

# Docker Compose

In the same folder as the `Dockerfile` above create a `docker-compose.yml`
file. Specify where save configurations and downloaded files. Also change the
time zone if necessary. [Documentation for all parameters](https://github.com/linuxserver/docker-transmission#parameters)

```yml
version: "3"

services:
  transmission:
    build: .
    container_name: transmission
    restart: unless-stopped
    environment:
      PUID: 1000
      PGID: 1000
      TZ: Europe/Stockholm
    volumes:
      - <path to config>:/config
      - <path to downloads>:/downloads
    ports:
      - 9091:9091
      - 51413:51413
      - 51413:51413/udp
```

# Running the container

In the folder where you placed the `Dockerfile` and `docker-compose.yml` run
the command to build and run the container. If you haven't already you will
need to [install Docker](https://docs.docker.com/engine/install/) and [docker-compose](https://docs.docker.com/compose/install/).

```bash
docker-compose up -d --build
```

Go to `localhost:9091` and enjoy your dark themed transmission web ui.
