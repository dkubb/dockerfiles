#!/usr/bin/env bash

set -feuo pipefail
IFS=$'\n\t'

readonly IMAGES=(
  alpine-nix
)

for image in "${IMAGES[@]}"; do
  (cd "$(dirname "$0")/$image"; docker build --tag "dkubb/$image" .)
done
