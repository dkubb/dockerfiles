#!/usr/bin/env bash

set -o errexit -o pipefail -o noglob -o noclobber -o nounset
IFS=$'\n\t'

readonly IMAGES=(
  alpine-nix
  alpine-nix-rails-nginx
  alpine-nix-rails-nginx/example
)

(cd alpine-nix-rails-nginx && rails new example --template example-rails-template.rb --force)

for image in "${IMAGES[@]}"; do
  (cd "$(dirname "$0")/$image" && docker build --tag "dkubb/$image" .)
done
