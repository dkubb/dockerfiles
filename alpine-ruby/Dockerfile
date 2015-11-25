# dkubb/alpine-ruby

FROM alpine:edge
MAINTAINER Dan Kubb <dkubb@fastmail.com>

COPY etc /etc

# Upgrade installed system dependencies
COPY apk-packages /tmp/
RUN echo '@testing http://dl-4.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
  && sed 's/#.*$//;/^$/d' /tmp/apk-packages \
  | tr -d ' ' \
  | xargs apk add --update-cache \
  && rm -- /tmp/apk-packages

# Add utility scripts
COPY setup-directories.sh /root/

# Create system directories and service symlinks
RUN mkdir -m 1750 -- /opt \
  && chown root:nogroup -- /opt \
  && /root/setup-directories.sh root r /etc/runit /etc/sv /etc/service \
  && ln -s -- /etc/service /service

# Upgrade rubygems and bundler
RUN echo 'gem: --no-document' > ~/.gemrc \
  && gem update --system \
  && gem install bundler

# Setup bundler for the root user
RUN bundle config --global build.nokogiri '--use-system-libraries' \
  && bundle config --global frozen 'true' \
  && bundle config --global jobs '8' \
  && bundle config --global without 'development test'

# Set the entrypoint for children docker images
ENTRYPOINT ["/sbin/runit"]
