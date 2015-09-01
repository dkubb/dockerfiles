#!/usr/bin/env bash

set -o errexit -o pipefail -o noglob -o noclobber -o nounset
IFS=$'\n\t'

user="$1"
directories=("${@:2}")

for directory in "${directories[@]}"; do
  # Create the directory if it does not exist
  [ -d "$directory" ] || mkdir -- "$directory"

  # Set the directory to be owned by user and default group
  chown --recursive "$user:" -- "$directory"

  # Set the files to be readable and writable by the owner
  # Set the directory to be executable by the owner
  # Remove all other permissions from the group and other users
  chmod -R u+rwX,go-rwx -- "$directory"

  # Set the directory sticky bit
  chmod +t -- "$directory"
done
