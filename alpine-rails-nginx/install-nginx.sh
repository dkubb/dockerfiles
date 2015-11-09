#!/bin/bash

set -o errexit -o pipefail -o noglob -o noclobber -o nounset
IFS=$'\n\t'

NGINX_VERSION=1.9.5
NGINX_HASH=48e2787a6b245277e37cb7c5a31b1549a0bbacf288aa4731baacf9eaacdb481b
NGINX_HEADERS_MORE_VERSION=0.261
NGINX_HEADERS_MORE_HASH=03d1f5fbecba8565f247d87a38f5e4b6440b0a56d752bdd2b29af2f1c4aea480

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

# Remove server name from error pages
patch --strip 0 < /tmp/nginx-remove-server-name.patch

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
  --group=nogroup \
  --add-module=/usr/local/src/headers-more-nginx-module-$NGINX_HEADERS_MORE_VERSION \
  --with-http_gzip_static_module \
  --with-http_realip_module \
  --with-http_stub_status_module \
  --with-ipv6 \
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
