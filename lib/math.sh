#!/usr/bin/env bash

function math::round() {
  local val=$1

  if [[ $# -eq 0 ]]; then
    read val
  fi
  printf "%.f" "${val}"
}

function math::calc() {
  echo "scale=1;$1" | bc
}
