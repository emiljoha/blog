FROM alpine:latest as build
ARG WEBSITE_BASE_URL
RUN \
    apk add --no-cache \
    hugo
COPY / /
RUN hugo --baseURL $WEBSITE_BASE_URL

FROM nginx:latest
COPY --from=build public /usr/share/nginx/html
