#!/usr/bin/env bash

include lib/core.sh

function tmux::is_tmux?() {
  if [[ -z ${TMUX+x} ]]; then 
    return $RC_ERROR
  else
    return $RC_OK
  fi
}

function tmux::message() {
  local msg=$1
  
  if [[ $# -eq 3 ]]; then
    tmux::message_style $2 $3
  else
    tmux::message_style "black" "#ffffff"
  fi

  tmux display-message $1
}

function tmux::message_red() {
  tmux::message $1 "black" "#ff0000"
}

function tmux::message_style() {
  tmux set message-style "fg=$1,bg=$2"
}
