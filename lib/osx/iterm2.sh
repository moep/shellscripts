#!/usr/bin/env bash

include lib/ansi.sh
include lib/tmux.sh

# TODO https://www.iterm2.com/documentation-escape-codes.html

# Sets iTerm2's profile to <profile>.
#
# < profile: The profile name to be set
function iterm2::set_profile() {
  local profile=$1

  iterm2::_escape_command "SetProfile=${profile}"
}

# Wraps a proprietary escape command with escape / bell codes
# 
# < escape_command: The escape command to be mapped (e.g. "SetProfile=...")
# ^ string
function iterm2::_escape_command() {
  local escape_command=$*
  
  # tmux needs some extra escape sequences
  if [[ tmux::is_tmux? ]]; then
    ansi::esc
    printf "Ptmux;"
    ansi::esc
  fi

  ansi::osc
  printf "1337;%s" "${escape_command}"
  ansi::bell

  if [[ tmux::is_tmux? ]]; then
    ansi::esc
    printf "\\"
  fi
}

# Renders an image.
#
# < image Path of image file to be rendered
function iterm2::render_image() {
  local image=$1
  local image_name_b64=$(base64 <<< $image)
  local image_data_b64=$(base64 $image)
  # TODO not needed for our case (we don't show a progress indicator"
  local image_data_size=$(wc -c <<< $image_data_b64)

  iterm2::_escape_command "File=name=${image_name_b64};size=${image_data_size};width=auto;height=15;inline=1:${image_data_b64}"
}
