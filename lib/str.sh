#!/usr/bin/env bash

include lib/ansi.sh
include lib/math.sh

function str::pad_right() { 
  local width=$1; shift
  printf "%-${width}s" "$*"
}

function str::pad_left() {
  local width=$1; shift
  printf "%*s" ${width} "$*"
}

function str::right() {
  local width=$(tput cols)

  str::pad_left $width "$*"
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

# Fills the line with <left> <mid> <right> <widht> whereby <mid>
# is repeated so that the string's length equals <width>.
#
# < left  Left string
# < mid   The filling string
# < right Right string
# < width Width in characters
#
# ^ "<left><mid>...<mid><right>"
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

function str::remove_ansi_codes() {
  local clean=$(sed "s,[[0-9;]*[a-zA-Z],,g" <<< "$*")
  printf "%s" "${clean}"
}

# Draws a line from (<row_s>, <col_s>) to (<row_e>, <col_e>)
# using <char> as render character.
#
# < row_s Start row
# < col_s Start column
# < row_e End Row
# < col_e End column
function str::draw_line() {
  local row_s=$1
  local col_s=$2
  local row_e=$3
  local row_e=$4
  local char=$5

  local d_row
  local d_col

  # TODO finish
  # TODO move to ui?
}

# Adds spaces after each character and right trims the string afterwards
#
# < str the String to convert
function str::stretch() {
  sed -E 's/(.)/\1 /g' <<< $1 | sed -e 's/\s*$//g' | tr -d '\n'
}

# Converts a hex value to its character representation.
# Supports single characters only.
# Has problems with special characters.
#
# < char The character to convert, eg: '61'
function str::from_hex() {
  printf "\x$1"
}