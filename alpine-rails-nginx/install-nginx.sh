#!/bin/bash

source strict-mode.sh

NGINX_VERSION=1.9.9
NGINX_HASH=de66bb2b11c82533aa5cb5ccc27cbce736ab87c9f2c761e5237cda0b00068d73
NGINX_HEADERS_MORE_VERSION=0.28
NGINX_HEADERS_MORE_HASH=67e5ca6cd9472938333c4530ab8c8b8bc9fe910a8cb237e5e5f1853e14725580

function verified_curl {
  url="$1"
  file="$2"
  sha256_hash="$3"
  curl --silent --fail --location "$url" >| "$file" \
    && echo "$sha256_hash  $file" | sha256sum -cs \
    && tar xf "$file"
}

mkdir /usr/local/src
cd /usr/local/src

verified_curl \
  "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz" \
  "nginx-$NGINX_VERSION.tar.gz" \
  "$NGINX_HASH"

verified_curl \
  "https://github.com/openresty/headers-more-nginx-module/archive/v$NGINX_HEADERS_MORE_VERSION.tar.gz" \
  "headers-more-nginx-module-$NGINX_HEADERS_MORE_VERSION.tar.gz" \
  "$NGINX_HEADERS_MORE_HASH"

cd nginx-$NGINX_VERSION

# Patch nginx source
patch --strip 0 < /tmp/nginx.patch

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
  --with-ipv6 \
  --with-openssl=/usr \
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
