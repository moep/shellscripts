#!/usr/bin/env bash

include lib/ansi.sh
include lib/core.sh

__OS_ARCH=$(uname)
__LOADING_ANIMATION='os::_loading_animation'
__LOADING_ANIMATION_FRAMES=(" WAIT " " wAIT " " WaIT " " WAiT " " WAIt " " WAiT " " WaIT " " wAIT ")

# TODO Split os.sh in os/<arch>.sh; autoinclude

# All CPUs
function os::cpu_usage() {
  case "${__OS_ARCH}" in
    "Darwin")
      ps -A -o %cpu | awk '{s+=$1} END {print s}' | sed 's/,/./'
    ;;
    *)
      printf "TODO"
      # Linux -> Distro (gentoo, pop os, arco linux, void linux ...)
    ;;
  esac
}

# TODO -> ui
function os::_loading_animation() {
  local pid=$1
  local currentFrame=0
  local numFrames=${#__LOADING_ANIMATION_FRAMES[@]}
  local animationCol=50
  
  ansi::cur_col "${animationCol}"
  ansi::cur_save
  ansi::bg_256 8 "      "
  ansi::reset_fg
  while kill -0 $pid 2> /dev/null; do
    ansi::cur_restore
    ansi::bg_256 8 
    ansi::reset_fg
    ansi::bold
    echo -n "${__LOADING_ANIMATION_FRAMES[$currentFrame]}"
    
    currentFrame=$((currentFrame+1))
    currentFrame=$((currentFrame%numFrames))
    sleep 0.5
  done
  
  ansi::cur_restore

  if wait $pid; then
    ansi::cur_col "${animationCol}"
    ansi::bg_256 2; ansi::bold; printf "  OK  "; ansi::reset 
    return $RC_OK
  else 
    ansi::cur_col "${animationCol}"
    ansi::bg_256 1; ansi::bold; printf " FAIL "; ansi::reset 
    return $RC_ERROR
  fi
  
}

function os::exec_and_wait() {
  local pid

  $@ > /dev/null 2>&1 &
  pid=$! 
  
  $__LOADING_ANIMATION $pid
  return $?
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

