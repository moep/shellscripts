#!/usr/bin/env bash

include lib/ansi.sh
include lib/math.sh

function str::pad() {
  local width=$1; shift
  printf "%*b" "${width}" "$*"
}

function str::right() {
  width=$(tput cols)
  str::pad $width "$*"
}

function str::length() {
  local str=$1

  if [[ $# -eq 0 ]]; then
    read str
  fi 

  str=$(str::remove_ansi_codes $str)
  printf "${#str}"
}

function str::center() {
  local width=$(tput cols)
  local length=$(str::length "$*")
  ansi::cur_right $((width / 2 - length / 2))
  printf "$*"

}

function str::fill() {
  local left=$1; shift;
  local mid=$1; shift;
  local right=$1; shift
  local width
  local width_left
  local width_right

  if [[ $# -lt 1 ]]; then
    width=$(tput cols)
  else
    width=$1; shift
    width=$(math::round $width)
  fi
 
  width_left=$(str::length <<< $left)
  width_right=$(str::length <<< $right)
 
  width=$(math::calc "${width} - ${width_left} - ${width_right}")
  printf '%s' "${left}"
  printf "%${width}s" | tr ' ' $mid
  printf '%s' "${right}"
}

str::remove_ansi_codes() {
  local clean=$(sed "s,[[0-9;]*[a-zA-Z],,g" <<< "$*")
  printf "%s" "${clean}"
}
