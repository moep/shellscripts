#!/usr/bin/env bash

# TODO Function for URLs (altough proprietary)
# TODO Function for Cursor Shape
# TODO check console color support ($COLORTERM)

# escape
function ansi::esc() {
  printf "\e"
}

# control sequence introduce
function ansi::csi() {
  printf "\033["
}

# operating system comand
function ansi::osc() {
  printf "\033]"
}

# bell command
function ansi::bell() {
  printf "\a"
}

# reset all formatting options
function ansi::reset() {
  ansi::csi
  printf "0m"
}

# Text Decoration

# Activates bold mode
#
# < text: Strings to format
function ansi::bold() {
  ansi::csi
  printf "1m%s" "$*"
}

# Activates low intensity mode
#
# < text: Strings to format
function ansi::lowint() {
  ansi::csi
  printf "2m%s" "$*"
}

# Activates underline mode
#
# < text: Strings to format
function ansi::underline() {
  ansi::csi
  printf "4m%s" "$*"
}

# Activates inverse mode
#
# < text: Strings to format
function ansi::inverse() {
  ansi::csi
  printf "7m%s" "$*"
}

#function ansi::invisible() {
#  ansi::csi
#  printf "8m%s" "$*"
#}

function ansi::reset_bold() {
  ansi::csi
  printf "22m%s" "$*"
}

function ansi::reset_underline() {
  ansi::csi
  print "24m%s" "$*"
}

function ansi::reset_blink() {
  ansi::csi
  print "25m%s" "$*"
}

function ansi::reset_inverse() {
  ansi::csi
  print "25m%s" "$*"
}

# Colors

function ansi::fg_256() {
  local col=$1; shift

  ansi::csi
  printf "38;5;${col}m%s" "$*"
}

function ansi::bg_256() {
  local col=$1; shift

  ansi::csi
  printf "48;5;${col}m%s" "$*"
}

function ansi::fg_tc() {
  local r=$1; shift
  local g=$1; shift
  local b=$1; shift

  ansi::csi
  printf "38;2;${r};${g};${b}m%s" "$*"
}

function ansi::bg_tc() {
  local r=$1; shift
  local g=$1; shift
  local b=$1; shift

  ansi::csi
  printf "48;2;${r};${g};${b}m%s" "$*"
}

function ansi::black() {
  ansi::fg_256 0 "$*"
}

function ansi::red() {
  ansi::fg_256 1 "$*"
}

function ansi::green() {
  ansi::fg_256 2 "$*"
}

function ansi::yellow() {
  ansi::fg_256 3 "$*"
}

function ansi::blue() {
  ansi::fg_256 4 "$*"
}

function ansi::magenta() {
  ansi::fg_256 5 "$*"
}

function ansi::cyan() {
  ansi::fg_256 6 "$*"
}

function ansi::white() {
  ansi::fg_256 7 "$*"
}

function ansi::bright_black() {
  ansi::fg_256 8 "$*"
}

function ansi::bright_red() {
  ansi::fg_256 9 "$*"
}

function ansi::bright_green() {
  ansi::fg_256 10 "$*"
}

function ansi::bright_yellow() {
  ansi::fg_256 11 "$*"
}

function ansi::bright_blue() {
  ansi::fg_256 12 "$*"
}

function ansi::bright_magenta() {
  ansi::fg_256 13 "$*"
}

function ansi::bright_cyan() {
  ansi::fg_256 14 "$*"
}

function ansi::bright_white() {
  ansi::fg_256 15 "$*"
}

function ansi::reset_fg() {
  ansi::csi
  printf "%s" "39m"
}

function ansi::reset_bg() {
  ansi::csi
  printf "%s" "49m"
}

# Cursor

function ansi::cur_up() {
  ansi::csi
  if [[ "$1" == "" ]]; then
    printf "%sA" "1"
  else
    printf "%sA" "$1"
  fi
}

function ansi::cur_down() {
  ansi::csi
  if [[ "$1" == "" ]]; then
    printf "%sB" "1"
  else
    printf "%sB" "$1"
  fi
}

function ansi::cur_right() {
  ansi::csi
  if [[ "$1" == "" ]]; then
    printf "%sC" "1"
  else
    printf "%sC" "$1"
  fi
}

function ansi::cur_left() {
  ansi::csi
  if [[ "$1" == "" ]]; then
    printf "%sD" "1"
  else
    printf "%sD" "$1"
  fi
}

function ansi::cur_next_line() {
  ansi::csi
  if [[ "$1" == "" ]]; then
    printf "%sE" "1"
  else
    printf "%sE" "$1"
  fi
}

function ansi::cur_prev_line() {
  ansi::csi
  if [[ "$1" == "" ]]; then
    printf "%sF" "1"
  else
    printf "%sF" "$1"
  fi
}


function ansi::cur_line() {
  ansi::csi
  printf "%sG" "$1"
}

function ansi::cur_save() {
  ansi::csi
  printf "s"
}

function ansi::cur_restore() {
  ansi::csi
  printf "u"
}

function ansi::cur_hide() {
  ansi::csi
  printf "?25l"
}

function ansi::cur_show() {
  ansi::csi
  printf "?25h"
}

function ansi::_cur_getpos() {
  # Workaround to prevent key presses to interfere
  read -t 0.01
  read -t 0.01
  read -t 0.01

  # based on a script from http://invisible-island.net/xterm/xterm.faq.html
  exec < /dev/tty
  oldstty=$(stty -g)
  stty raw -echo min 0
  # on my system, the following line can be replaced by the line below it
  echo -en "\033[6n" > /dev/tty
  # tput u7 > /dev/tty    # when TERM=xterm (and relatives)
  IFS=';' read -r -d R -a pos
  stty $oldstty
  row=$((${pos[0]:2}))   # strip off the esc-[
  col=$((${pos[1]}))

  echo "${row} ${col}"
}

# Determines the Terminal's size
#
# ^ [array] (rows cols)
function ansi::terminal_size() {
  #local pos=()
  #ansi::cur_save
  #ansi::cur_pos 99999 99999
  #pos=$(ansi::cur_pos)
  #echo "${pos[0]} ${pos[1]}"
  #ansi::cur_restore
  printf "%s %s" "$(tput lines)" "$(tput cols)"
}

function ansi::cur_pos() {
  if [[ $# -eq 0 ]]; then
    ansi::_cur_getpos
    return
  fi

  local row=$1; shift
  local col=$1; 

  ansi::csi
  printf "%s;%sH" "${row}" "${col}"
}

# Moves cursor to given column
#
# col (integer) The column to move to
function ansi::cur_col {
  local col=$1
  local lastPos=( $(ansi::cur_pos) )

  ansi::cur_pos "${lastPos[0]}" "${col}" 
  #ansi::cur_pos "17" "${col}" 
}

# TODO Other CLS modes
function ansi::cls() {
  ansi::csi
  printf "2J"
}

function ansi::nuke() {
  ansi::csi
  printf "3J"
}

function ansi::delete_line() {
  ansi::csi
  printf "2K"
}

function ansi::delete_left() {
  ansi::csi
  printf "1K"
}

function ansi::delete_right() {
  ansi::csi
  printf "K"
}

function ansi::scroll_up() {
  ansi::csi
  printf "%sT" "$1"
}

function ansi::scroll_down() {
  ansi::csi
  printf "%sT" "$1"
}

