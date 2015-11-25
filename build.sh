#!/usr/bin/env bash

set -o errexit -o pipefail -o noglob -o noclobber -o nounset
IFS=$'\n\t'

readonly IMAGES=(
  alpine-ruby
  alpine-rails-nginx
  alpine-rails-buildkite
  alpine-rails-nginx/example
)

(cd alpine-rails-nginx && gem install rails && rails new example --template example-rails-template.rb --database postgresql --force)

for image in "${IMAGES[@]}"; do
  (cd "$(dirname "$0")/$image" && docker build --tag "dkubb/$image" .)
done
