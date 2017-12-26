#!/usr/bin/env bash

include lib/ansi.sh
include lib/str.sh

__TYPEWRITER_DELAY_SECONDS=0.01
__FADE_DELAY_SECONDS=0.01

function fx::typewriter() {
  local str=$*
  local strlen=$(str::length <<< $str)

  ansi::cur_hide
  for (( i = 0; i < $strlen; i++ )); do
    printf "${str:$i:1}"; sleep $__TYPEWRITER_DELAY_SECONDS
  done
  ansi::cur_show
}

function fx::fade() {
  ansi::cur_save
  ansi::fg_tc 0 0 0
  printf "%s" "$*"
  
  for (( i = 0; i <= 255; i+=5 )); do
    ansi::cur_restore
    ansi::fg_tc $i $i $i
    printf "%s" "$*"
    sleep $__FADE_DELAY_SECONDS
  done
}
