#!/usr/bin/env bash

source alpine-ruby/sbin/strict-mode.sh

readonly IMAGES=(
  alpine-aws
  alpine-ruby
  alpine-rails-nginx
  alpine-rails-nginx/example
)

(
  cd alpine-rails-nginx \
    && gem install rails --version '~> 4.2' \
    && rm -rf example \
    && rails new example --template example-rails-template.rb --database postgresql --force
)

for image in "${IMAGES[@]}"; do
  (cd "$(dirname "$0")/$image" && docker build --tag "dkubb/$image" .)
done
