#!/usr/bin/env bash

source "$(dirname -- "$(readlink -f -- "$0")")/strict-mode.sh"

umask 0077

exec bash "$@"
