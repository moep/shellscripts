#!/usr/bin/env bash

__OS_ARCH=$(uname)
__LOADING_ANIMATION='os::_loading_animation'

# TODO Split os.sh in os/<arch>.sh; autoinclude

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

# TODO -> ui
function os::_loading_animation() {
  local pid=$1

  while kill -0 $pid 2> /dev/null; do
    echo -n "."
    sleep 1
  done
}

function os::exec_and_wait() {
  local pid

  $@ > /dev/null 1>&2 &
  pid=$! 
  
  $__LOADING_ANIMATION $pid
  pid2=$!
}

function os::battery_percent() {
  case "${__OS_ARCH}" in
    "Darwin")
       pmset -g batt | grep "InternalBattery-0" | cut -f2 | cut -d ';' -f1 | cut -d '%' -f1
    ;;
    *)
      echo "TODO"
    ;;
  esac
}

function os::battery_charging?() {
  return 1
  local power_source

  case "${__OS_ARCH}" in
    "Darwin")
      power_source=$(pmset -g batt | head -n1 | cut -d "'" -f2)

      if [[ "${power_source}" == "AC Power" ]]; then
        echo "AC"
        return 0
      else
        echo "BAT"
        return 1
      fi
    ;;
    *)
      echo "TODO"
    ;;
  esac
}

function os::battery_remaining_time() {
  pmset -g batt | grep "InternalBattery-0" | cut -f2 | cut -d ';' -f3 | sed -E 's/^ ([0-9]{1,2}:[0-9]{1,2}).*/\1/g'
}

function os::is_installed?() {
  if [[ $# -eq 0 ]]; then 
    return 1; 
  fi

  hash $1 2> /dev/null
  return $? 
}
