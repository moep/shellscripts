#!/usr/bin/env bash

LANG=C
LC_NUMERIC=C

source ../bootstrap.sh
include lib/ui.sh
include lib/str.sh
include lib/os.sh
include lib/tmux.sh
include lib/fx.sh
include lib/hue.sh
include lib/osx/iterm2.sh
bootstrap::finish

trap ctrl_c INT

function ctrl_c() {
  ansi::cur_show
  ansi::reset
  echo
  echo "Aborted"
  exit 1
}

function main() {
  iterm2::set_profile "moep_black"

  local font_color="51 102 0"
  local colors1=("51 102 0" "102 204 0" "128 255 0")
  local colors2=("30 175 30" "47 115 47" "45 80 45" "51 98 51" "0 0 0")
  local sleep_time=0.1

  ansi::nuke
  ansi::cls
  ansi::cur_pos 1 1 
  ansi::cur_hide

  ansi::fg_tc $(echo $font_color) "┏━━━━"; ansi::bold "/ moep /"; ansi::reset_bold "━━━━━━━━━━━━━━┓"
  echo
  echo "┃ Lorem ipsum              ┃"
  echo "┃ Bla                      ┃"
  echo "┃                          ┃"
  echo "┃                          ┃"
  echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━┛"

  # Fade title in
  for c in "${colors1[@]}"; do
    ansi::cur_pos 1 6
    ansi::bg_tc $(echo $c)
    printf "        "
    ansi::reset_bg
    sleep $sleep_time
  done

  # Fade title in - show title
  for c in "${colors2[@]}"; do
    ansi::cur_pos 1 6
    ansi::bg_tc $(echo $c)
    ansi::bold "/ moep /"; ansi::reset_bold
    ansi::reset_bg
    sleep $sleep_time
  done

  ansi::cur_pos 4 3
  echo -n "Setting 1 .......... "; ansi::bg_256 238 " "; ansi::fg_256 256 "1"; ansi::bg_256 27 " ";
  ansi::reset
  echo
}


main


#read -p ""
#ansi::cur_show
#iterm2::set_profile "moep_dark"
#ansi::cls
