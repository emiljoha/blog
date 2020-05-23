+++
title = "LaTeX CI Build Environment"
date = 2020-05-22T19:41:40+02:00
draft = false
tags = []
categories = ["texlive", "build"]
+++


Compiling TeX documents in a CI environment can be tricky if you do not have
root access or do not want to wait the long while it takes for a LaTeX
installation live TeX Live to install. Using docker we can both describe the
build configuration as code and make sure to reliable reproduce build result
locally.

Create a Dockerfile in you LaTeX projects root. If you do not use make to
build you can replace it with your own build command. The only important thing
is that it creates the output PDF in a separate directory. I use the
directory name `pdf`.

``` Dockerfile
FROM emijoh/texlive

COPY / /

RUN make
```

The image `emijoh/texlive` is auto built by docker hub from [this GitHub
repository](https://github.com/emiljoha/texlive).

Then build the Dockerfile, create the container, and copy out the build
directory.

``` bash
#!/bin/bash
docker build . -t cv
CID=$(docker create cv)
docker cp ${CID}:/pdf .
docker rm ${CID}
```

Now the resulting pdf will be available in the project root in a folder `pdf`.
