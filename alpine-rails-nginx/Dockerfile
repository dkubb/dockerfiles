# dkubb/alpine-rails-nginx

FROM dkubb/alpine-ruby
MAINTAINER Dan Kubb <dkubb@fastmail.com>

COPY etc /etc

# Upgrade installed system dependencies
COPY apk-packages /tmp/
RUN echo '@testing http://dl-4.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
  && sed 's/#.*$//;/^$/d' /tmp/apk-packages \
  | tr -d ' ' \
  | xargs apk add --update-cache \
  && rm -- /tmp/apk-packages

# Create system users
RUN adduser -DSH nginx \
  && adduser -DS rails

# Create system directories and service symlinks
RUN setup-directories.sh  root  r  /etc/service/nginx /etc/service/rails \
  && setup-directories.sh nginx r  /etc/nginx \
  && setup-directories.sh nginx rw /var/run/nginx /var/cache/nginx /var/log/nginx \
  && setup-directories.sh rails rw /opt/rails /var/run/rails \
  && ln -s -- /etc/sv/nginx /etc/service/nginx/run \
  && ln -s -- /etc/sv/rails /etc/service/rails/run

# Install nginx
COPY install-nginx.sh /tmp/
COPY nginx.patch /tmp/
RUN /tmp/install-nginx.sh \
  && setup-directories.sh nginx r /etc/nginx \
  && rm -rf -- /usr/local/src /tmp/*

# Setup bundler for the root user
RUN bundle config --global -- gemfile '/opt/rails/Gemfile' \
  && bundle config --global -- deployment

# Setup bundler for the rails user
RUN cp --recursive -- ~/.bundle ~rails \
  && setup-directories.sh rails rw ~rails/.bundle
