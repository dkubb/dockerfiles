#!/bin/bash

NGINX_VERSION=1.11.6
NGINX_HASH=3153abbb518e2d9c032e1b127da3dc0028ad36cd4679e5f3be0b8afa33bc85bd
NGINX_HEADERS_MORE_VERSION=0.31
NGINX_HEADERS_MORE_HASH=b2e8162cce2d24861b1ed5bbb30fc51d5215e3f4bb9d01f53fc344904d5911e7
LIBRESSL_VERSION=2.4.4
LIBRESSL_HASH=6fcfaf6934733ea1dcb2f6a4d459d9600e2f488793e51c2daf49b70518eebfd1

function verified_curl {
  url="$1"
  file="$2"
  sha256_hash="$3"
  curl --silent --fail --location "$url" >| "$file" \
    && echo "$sha256_hash  $file" | sha256sum -cs \
    && tar xf "$file"
}

cd "$(dirname "$0")" || exit 1

verified_curl \
  "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz" \
  "nginx-$NGINX_VERSION.tar.gz" \
  "$NGINX_HASH"

verified_curl \
  "https://github.com/openresty/headers-more-nginx-module/archive/v$NGINX_HEADERS_MORE_VERSION.tar.gz" \
  "headers-more-nginx-module-$NGINX_HEADERS_MORE_VERSION.tar.gz" \
  "$NGINX_HEADERS_MORE_HASH"

verified_curl \
  "http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-$LIBRESSL_VERSION.tar.gz" \
  "libressl-$LIBRESSL_VERSION.tar.gz" \
  "$LIBRESSL_HASH"

cd nginx-$NGINX_VERSION || exit 1

# Patch nginx source
patch --strip 0 < "$(dirname "$0")/nginx.patch"

# Configure nginx
./configure \
  --with-cc-opt="-static -static-libgcc" \
  --with-ld-opt="-static" \
  --with-cpu-opt=generic \
  --prefix=/usr/local/nginx \
  --sbin-path=/usr/local/sbin/nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --pid-path=/var/run/nginx/nginx.pid \
  --lock-path=/var/lock/nginx.lock \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
  --http-client-body-temp-path=/var/cache/nginx/client_body_temp \
  --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
  --user=nginx \
  --group=nginx \
  --add-module=/usr/local/src/headers-more-nginx-module-$NGINX_HEADERS_MORE_VERSION \
  --with-http_gzip_static_module \
  --with-http_realip_module \
  --with-http_ssl_module \
  --with-http_stub_status_module \
  --with-http_v2_module \
  --with-openssl=/usr/local/src/libressl-$LIBRESSL_VERSION \
  --without-http_auth_basic_module \
  --without-http_autoindex_module \
  --without-http_browser_module \
  --without-http_empty_gif_module \
  --without-http_fastcgi_module \
  --without-http_geo_module \
  --without-http_map_module \
  --without-http_memcached_module \
  --without-http_referer_module \
  --without-http_scgi_module \
  --without-http_split_clients_module \
  --without-http_ssi_module \
  --without-http_upstream_ip_hash_module \
  --without-http_upstream_least_conn_module \
  --without-http_userid_module \
  --without-http_uwsgi_module \
  --without-mail_imap_module \
  --without-mail_pop3_module \
  --without-mail_smtp_module \
  --without-select_module

# Install nginx
make install
