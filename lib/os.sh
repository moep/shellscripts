#!/usr/bin/env bash

__OS_ARCH=$(uname)

# All CPUs
function os::cpu_usage() {
  case "${__OS_ARCH}" in
    "Darwin")
      ps -A -o %cpu | awk '{s+=$1} END {print s}' | sed 's/,/./'
    ;;
    *)
      printf "TODO"
    ;;
  esac
}
