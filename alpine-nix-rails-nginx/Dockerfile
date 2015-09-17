# dkubb/alpine-nix-rails-nginx

FROM dkubb/alpine-nix:latest
MAINTAINER Dan Kubb <dkubb@fastmail.com>

# Configure nix
COPY config.nix /root/.nixpkgs/config.nix

# Install system dependencies
RUN nix-env --install \
    acl-2.2.52 \
    bundler-1.10.6 \
    gcc-wrapper-5.2.0 \
    git-2.5.2 \
    gnumake-4.1 \
    libressl-2.2.2 \
    libxml2-2.9.2 \
    libxslt-1.1.28 \
    nginx-1.9.4 \
    nodejs-0.12.7 \
    postgresql-9.4.4 \
    ruby-2.2.2-p0 \
    runit-2.1.2 \
    zlib-1.2.8 \
  && nix-collect-garbage --delete-old \
  && nix-store --optimize

RUN adduser -DS nginx
RUN adduser -DS rails

# Setup system configuration
COPY etc /etc/

# Create system directories and service symlinks
RUN mkdir -m 1750 -- /opt \
  && chown root:nogroup -- /opt \
  && /root/setup-directories.sh root /etc/runit /etc/sv /etc/service /etc/service/nginx /etc/service/rails \
  && /root/setup-directories.sh nginx /etc/nginx /var/run/nginx /var/cache/nginx /var/log/nginx \
  && /root/setup-directories.sh rails /opt/rails /var/run/rails \
  && ln -s -- /etc/sv/nginx /etc/service/nginx/run \
  && ln -s -- /etc/sv/rails /etc/service/rails/run \
  && ln -s -- /etc/service /service

WORKDIR /opt/rails

# Setup bundler system library dependencies
USER rails
RUN source /etc/profile.d/nix.sh \
  && bundle config --local build.nokogiri '--use-system-libraries --with-xml2-include=/nix/var/nix/profiles/default/include/libxml2 --with-xml2-dir=/nix/var/nix/profiles/default --with-xslt-dir=/nix/var/nix/profiles/default' \
  && bundle config --local build.pg '--use-system-libraries --with-zlib-dir=/nix/var/nix/profiles/default' \
  && bundle config --local build.puma '--use-system-libraries --with-opt-dir=/nix/var/nix/profiles/default' \
  && bundle config --local frozen 'true' \
  && bundle config --local jobs '8' \
  && bundle config --local path 'vendor/bundle' \
  && bundle config --local without 'development test'

USER root

EXPOSE 8080

# Set the entrypoint for children docker images
ENTRYPOINT ["/nix/var/nix/profiles/default/bin/runit"]
