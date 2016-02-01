# dkubb/alpine-ruby

FROM alpine:edge
MAINTAINER Dan Kubb <dkubb@fastmail.com>

# Upgrade installed system dependencies
COPY apk-packages /tmp/
RUN echo '@testing http://dl-4.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
  && sed 's/#.*$//;/^$/d' /tmp/apk-packages \
  | tr -d ' ' \
  | xargs apk add --update-cache \
  && rm /tmp/apk-packages

COPY etc  /etc
COPY sbin /usr/local/sbin

# Replace default sh command
RUN ln -sfv /usr/local/sbin/sh-wrapper.sh /bin/sh

# Create system directories and service symlinks
RUN setup-directories.sh root r /opt /etc/runit /etc/sv /etc/service \
  && ln -s /etc/service /service

# Upgrade rubygems and bundler
RUN echo 'gem: --no-document' > ~/.gemrc \
  && umask 0022 \
  && gem update --system \
  && gem install bundler

# Setup bundler for the root user
RUN bundle config --global build.nokogiri '--use-system-libraries' \
  && bundle config --global disable_shared_gems '1' \
  && bundle config --global frozen '1' \
  && bundle config --global jobs '8' \
  && bundle config --global path 'vendor/bundle' \
  && bundle config --global without 'development:test'

# Set the entrypoint for children docker images
ENTRYPOINT ["/sbin/runit"]
