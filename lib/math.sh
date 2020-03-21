#!/usr/bin/env bash

include lib/core.sh

# TODO why "command not found"?!
#core::assert_available bc

# TODO Can now be done via bc; keep as an alias?
function math::round() {
  local val=$1

  if [[ $# -eq 0 ]]; then
    read val
  fi
  printf "%.f" "${val}"
}

function math::calc() {
  echo "scale=4;$1" | bc -l "$(dirname ${BASH_SOURCE[0]})/../contrib/bclib"
}

function math::to_hex() {
  echo "obase=16" | bc 
}