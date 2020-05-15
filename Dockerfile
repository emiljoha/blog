FROM alpine:latest as build

RUN \
    apk add --no-cache \
    hugo
COPY / /
RUN hugo

FROM nginx:latest

COPY --from=build public /usr/share/nginx/html
