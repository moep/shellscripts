#!/usr/bin/env bash

function tmux::is_tmux?() {
  if [[ -z ${TMUX+x} ]]; then 
    return 1
  else
    return 0
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
  echo "style: $1 $2"
  tmux set message-style "fg=$1,bg=$2"
}
