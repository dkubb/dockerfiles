#!/usr/bin/env bash

source strict-mode.sh

user="$1"
perms="$2"
directories=("${@:3}")

for directory in "${directories[@]}"; do
  # Create the directory if it does not exist
  [ -d "$directory" ] || mkdir -- "$directory"

  # Set the directory to be owned by user and default group
  chown --recursive "$user:" -- "$directory"

  # Remove read/write perms for all
  # Set the file specified perms by the owner
  # Set the file to be executable by the owner if any execute bit is set
  # Set the directory to be executable by the owner
  # Remove executable permissions for group and other
  chmod -R "a-rw,u+${perms}X,go-x" -- "$directory"

  # Set the directory sticky bit
  chmod +t -- "$directory"
done
