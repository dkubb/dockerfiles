# dkubb/alpine-rails-nginx

FROM alpine:edge
MAINTAINER Dan Kubb <dkubb@fastmail.com>

# Create system users
RUN adduser -DSH -G nogroup nginx \
  && adduser -DSH -G nogroup rails

# Upgrade installed system dependencies
RUN echo '@testing http://dl-4.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories
COPY apk-packages /tmp/
RUN sed 's/#.*$//;/^$/d' /tmp/apk-packages \
  | tr -d ' ' \
  | xargs apk add --update-cache

# Install nginx
COPY install-nginx.sh /tmp/
COPY nginx-remove-server-name.patch /tmp/
RUN /tmp/install-nginx.sh \
  && rm -rf /usr/local/src /tmp/*

# Upgrade bundler
RUN echo 'gem: --no-document' > ~/.gemrc \
  && gem install bundler

# Add utility scripts
COPY setup-directories.sh /root/

# Setup system configuration
COPY etc /etc/

# Create system directories and service symlinks
RUN mkdir -m 1750 -- /opt \
  && chown root:nogroup -- /opt \
  && /root/setup-directories.sh root  r  /etc/runit /etc/sv /etc/service /etc/service/nginx /etc/service/rails \
  && /root/setup-directories.sh nginx r  /etc/nginx \
  && /root/setup-directories.sh nginx rw /var/run/nginx /var/cache/nginx /var/log/nginx \
  && /root/setup-directories.sh rails rw /opt/rails /var/run/rails \
  && ln -s -- /etc/sv/nginx /etc/service/nginx/run \
  && ln -s -- /etc/sv/rails /etc/service/rails/run \
  && ln -s -- /etc/service /service

USER rails
WORKDIR /opt/rails

# Setup bundler
RUN bundle config --local build.nokogiri '--use-system-libraries' \
  && bundle config --local frozen 'true' \
  && bundle config --local jobs '8' \
  && bundle config --local path 'vendor/bundle' \
  && bundle config --local without 'development test'

USER root

# Set the entrypoint for children docker images
ENTRYPOINT ["/sbin/runit"]
