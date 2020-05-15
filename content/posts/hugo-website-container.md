+++
title = "Serve Hugo Website With Nginx"
date = 2020-05-15T16:23:30+02:00
draft = true
tags = []
categories = ["hugo", "nginx", "docker"]
+++

This post covers how to generate and serve a Hugo website with Nginx using
Docker. After following the excellent [Hugo Quick
Start](https://gohugo.io/getting-started/quick-start/) on the project page you
want to share your static website with the world. If the cloud is your thing
then there are many options in the [Hosting &
Deployment](https://gohugo.io/hosting-and-deployment/). Maybe, just maybe that
should be a hint that those alternatives probably are better if all you want a
is reliable site. But if you are like me, then what is the fun in paying
someone to manage everything for you, when that is half the fun.

The most interesting thing in the Dockerfile below is the use of [multi-staged
builds](https://docs.docker.com/develop/develop-images/multistage-build/). The
first step installs Hugo on top of an alpine base, then copies the everything
in the website project folder into the container and runs Hugo to generate the
static site. However, once the site is generated there is now no need for
neither the Hugo install nor all the project files. This is where multi-staged
builds comes in. 

By adding a second `FROM` statements in the Dockerfile the plate is swept
clean of all the cruft from the generation not needed any more. Only the
necessary Nignx configuration file `default.conf` is copied in from the
repository. The last line shows the power of multi-staged builds when we copy
the directory `public` with the generated site. This means we only get the
result from the build not all the intermediate steps.

When the job we need Nginx for is to serve a bunch of static files it turns
out that there is actually no configuration of the official image needed. The
image, per default serves files from `/usr/share/nginx/html` over port 80 and
8000.

```Dockerfile
FROM lsiobase/alpine:3.11 as build
RUN \
    apk add --no-cache \
    hugo
COPY / /
RUN hugo

FROM nginx:latest
COPY --from=build public /usr/share/nginx/html
```

To make sure we do not unintentionally copy things into the container it is
wise to create a `.dockerignore` to make the `COPY / /` command ignore the
`public` directory.

```bash
echo public >> .dockerignore
```

The `docker-compose.yml` file in the root of the project need not be more
complicated than this to build and expose 8080 to the containers port 80.

```yaml
version: '2'

services:
  static-webpage:
    build: .
    ports:
     - "8080:80"
```

Build and run the container with the following command.

```bash
docker-compose up -d --build
```

Now you can browse your site at `localhost:8080`. Note that if you want to
properly test your site while the `baseUrl` parameter in `config.toml` need to
be set to http://localhost:8080.

Final note, in this day and age https is really expected. In the quest to
[Decouple applications](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#decouple-applications)
as described in the Docker documentation the concern of https is best
separated into its own container and worthy of its own post.
