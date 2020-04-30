FROM lsiobase/alpine:3.11 as build

RUN \
    apk add --no-cache \
    hugo
COPY / /
RUN hugo

FROM nginx:latest

COPY default.conf /etc/nginx/conf.d/default.conf
COPY --from=build public /usr/share/nginx/html
