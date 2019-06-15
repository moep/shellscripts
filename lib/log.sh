#!/usr/bin/env bash

declare -c K_LOGLEVEL_NONE=0
declare -c K_LOGLEVEL_FATAL=1
# ...
declare -c K_LOGLEVEL_DEBUG=5

echo "LOG"

function log::_init() {
  if [[ -z $LOGLEVEL ]]; then
    LOGLEVEL=$K_LOGLEVEL_NONE
    echo "xxx setting loglevel default"
  else 
    echo "xxx using loglevel ${LOGLEVEL}"
  fi
}

function log::log() {
  local log_level=$1; shift
  
  printf "%s %s\r\n" "${log_level}" "$*"
}

function log::x() {
  echo "xxxx"
}

function log::d() {
  log::log "DEBUG ${LOGLEVEL}" $* 
}

# initialize module
log::_init
