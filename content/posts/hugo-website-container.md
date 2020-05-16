+++
title = "Serve Hugo Website With Nginx"
date = 2020-05-16T21:10:39+02:00
draft = false
tags = []
categories = ["hugo", "nginx", "docker"]
+++

This post covers how to generate and serve a Hugo website with Nginx using
Docker. After following the excellent [Hugo Quick
Start](https://gohugo.io/getting-started/quick-start/) on the project page you
want to share your static website with the world. If the cloud is your thing
then there are many options in the [Hosting &
Deployment](https://gohugo.io/hosting-and-deployment/) but not how to do
deploy it yourself. Maybe, just maybe that should be a hint that those
alternatives probably are better if all you want is a reliable site. But if
you are like me, then what is the fun in paying someone to manage everything
for you. But yes, the most practical thing is probably to use something like
the [Renders free static site offer](https://render.com/pricing).

But let figure out how to do this ourselves, it is really not hard. This
simple Dockerfile essentially does it all.

```Dockerfile
FROM alpine:latest as build
ARG WEBSITE_BASE_URL
RUN \
    apk add --no-cache \
    hugo
COPY / /
RUN hugo --baseURL $WEBSITE_BASE_URL

FROM nginx:latest
COPY --from=build public /usr/share/nginx/html
```

First, Hugo is installed on top of an alpine base, the website project folder
is copied into the container so that Hugo that we just installed can generate
the static site pages. Once the site files are generated there is no need for
neither the Hugo package nor all the project files. This is where multi-staged
builds comes in.

By adding a second `FROM` statements in the Dockerfile the plate is swept
clean of all the cruft from the generation not needed any more. Only the
directory `public` created by hugo is copied from the build phase.

When the job we need Nginx for is to serve a bunch of static files it turns
out that there is actually no configuration of the official image needed. The
image, per default serves files from `/usr/share/nginx/html` over port 80 and
8000.

To make sure we do not unintentionally copy things into the container it is
wise to create a `.dockerignore` to make the `COPY / /` command ignore the
`public` directory.

```bash
echo public >> .dockerignore
```

The `docker-compose.yml` file in the root of the project need not be more
complicated than this to build and expose the site on port 8080.

```yaml
version: '3'

services:
  static-webpage:
    build:
      context: .
      args:
        WEBSITE_BASE_URL: http://localhost:8080
    ports:
     - "8080:80"
```

Build and run the container with the following command.

```bash
docker-compose up -d --build
```

Final note, in this day and age https is really expected. In the quest to
[Decouple
applications](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#decouple-applications)
the concern of https is best separated into its own container and worthy of
its own post.
