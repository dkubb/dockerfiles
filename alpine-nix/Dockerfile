# dkubb/alpine-nix

FROM alpine:3.2
MAINTAINER Dan Kubb <dkubb@fastmail.com>

ENV NIX_VERSION 1.9
ENV NIX_SHA256  8a47cd7c35dfa628a4acfaef387e7451013c61d250bbcf1f38067a7c73f9f3e1

# Upgrade installed system dependencies
COPY apk-packages /tmp/
RUN sed 's/#.*$//;/^$/d' /tmp/apk-packages | tr -d ' ' | xargs apk add --update-cache

ENV CC       x86_64-alpine-linux-musl-gcc
ENV CXX      x86_64-alpine-linux-musl-g++
ENV CFLAGS   -static
ENV CXXFLAGS -static

# Install WWW::Curl perl module (until perl-www-curl package is available)
RUN perl -MCPAN -e 'install WWW::Curl'

# Add patch to fix build errors
COPY nix.patch /tmp/

# Install nix from source
RUN cd /tmp \
  && curl --remote-name "https://nixos.org/releases/nix/latest/nix-$NIX_VERSION.tar.xz" \
  && echo "$NIX_SHA256  nix-$NIX_VERSION.tar.xz" | shasum --algorithm 256 --check \
  && tar xJf "nix-$NIX_VERSION.tar.xz" \
  && cd "/tmp/nix-$NIX_VERSION" \
  && patch -p1 < /tmp/nix.patch \
  && ./bootstrap.sh \
  && ./configure --sysconfdir=/etc --enable-gc \
  && make \
  && make install \
  && rm -r /tmp/*

# Create dummy user and group for nix
RUN addgroup -S nixbld
RUN adduser -DHS -G nixbld nixbld

# NOTE: the /nix/store and /nix/store/trash directories need to be setup at the
# same time in order for symlinks to be renamed between them. Otherwise EXDEV
# errors are thrown, which is not handled properly by nix.

# Setup nix for root user
RUN mkdir -p -m 1755 /nix/store/trash \
  && echo 'https://nixos.org/channels/nixpkgs-unstable nixpkgs' > /root/.nix-channels \
  && nix-channel --update \
  && ln -s /nix/var/nix/profiles/default /root/.nix-profile

# TODO: install musl-gcc using nix
#   * Make sure it links against musl as the libc instead of glibc
#   * Remove alpine linux system gcc and other nix build dependencies

# TODO: figure out if it's possible to change the nix global settings to
# prefer musl-gcc instead of gcc + glibc

ENTRYPOINT ["/bin/bash", "--login", "-c"]
CMD ["bash"]
