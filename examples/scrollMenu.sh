#!/usr/bin/env bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then
  DIR="$PWD";
fi

source ${DIR}/../bootstrap.sh
include lib/ansi.sh
include lib/cli.sh
include lib/math.sh
include lib/os.sh
include lib/str.sh
include lib/ui.sh
bootstrap::finish

trap on_ctrl_c INT


  __MENU_SELECTED_LINE=0
  __MENU_SELECTED_VISIBLE_LINE=0
  __MENU_SCROLL_OFFSET=0

function main() {
  scrollbarEmpty=$(ansi::bright_black; printf '┃'; ansi::reset)
  scrollbarFull=$(ansi::white; printf '┃'; ansi::reset)
  #local scrollbarUpperHalf='╿'
  #local scrollbarLowerHalf='╽'

  # Start with a blank screen and disable cursor
  clear
  ansi::cur_hide
  
  
  printf "%s\r\n" '─╮╭╮╭╮╭╮╭╮╭╮'
  printf "%s\r\n" ' ╰╯╰╯╰╯╰╯╰╯╰────────────────────'
  echo "bla"

  #__MENU_VALUES=(0 1 2 3 4 5 6 7 8 9 a b c d e f)
  #__MENU_LABELS=(0 1 2 3 4 5 6 7 8 9 a b c d e f)
  __MENU_VALUES=(0 1 2 3 4 5 6 7 8 9 a)
  __MENU_LABELS=(0 1 2 3 4 5 6 7 8 9 a) 
  for i in $(seq 0 7); do
    echo "----- $i"
    python -c 'from time import time; print int(round(time() * 1000))'
    ui::scroll_menu::_render_lines 40 4 0 $i
    echo
  done
  

  cleanup
}

function ui::scroll_menu::show() {
  # TODO input validation
  local width=$1; shift
  local height=$1 shift 
  local params=("$@")
  local values=()
  local labels=()

  ansi::cur_hide
  local numItemsMinusOne=$(math::calc "$# / 2 - 1")
  local index

  # Reset last call's values
  __MENU_VALUES=()
  __MENU_LABELS=()
  __MENU_SELECTED_LINE=0
  __MENU_SELECTED_VISIBLE_LINE=0
  __MENU_SCROLL_OFFSET=0
}

function ui::scroll_menu::_render_lines() {
  local width=$1 
  local height=$2 
  local selectedVisibleLine=$3
  local scrollOffset=$4
  
  for i in $(seq 0 $((height-1))); do
    if [[ "$i" -eq "$selectedVisibleLine" ]]; then
      ansi::bg_256 15
      ansi::black
    fi
    #str::pad_right "${width}" "${__MENU_LABELS[$((i+scrollOffset))]}"
    printf "%s" "${__MENU_LABELS[$((i+scrollOffset))]}"
    ansi::reset_bg
    ansi::bright_black
    ui::scroll_menu::_render_scrollbar "$i" "${height}" "${scrollOffset}" 
    ansi::reset
    echo 
  done
}

function ui::scroll_menu::_render_scrollbar() {
  local line=$1
  local height=$2
  local scrollOffset=$3

  # TODO move outside of loop
  # Percentage of all lines displayed at once
  
  local visibleFraction=$(math::calc "(${height} / ${#__MENU_LABELS[@]})")
  # Determines active scroll bar's size
  #local scrollBarFullSegments=$(math::calc "ceil(${visibleFraction} * ${height})")
  #local scrollProgressPercent=$(math::calc "${scrollOffset} / (${#__MENU_LABELS[@]} - ${height})")

  local scrollBarFullSegments=$(( "${visibleFraction}" * "${height}" ))
  local scrollProgressPercent=$(( "${scrollOffset}" / "${#__MENU_LABELS[@]}" - "${height}" ))
  
  #local firstActiveLine=$(math::calc "min(floor(${scrollProgressPercent} / ${visibleFraction}), ${height} - 1)")
  #local lastActiveLine=$(math::calc "min(${firstActiveLine} + ${scrollBarFullSegments} - 1, ${height} - 1)")

  local barChar="${__SCROLLBAR_NONE}"
  if [[ "${firstActiveLine}" -le "${line}" ]] && [[ ${line} -le "${lastActiveLine}" ]]; then
    barChar="${__SCROLLBAR_ACTIVE}"
  fi

  #printf '%s l: %s vis: %s segs: %s prog: %s from: %s to: %s' \
  #  "${barChar}" "${line}" "${visibleFraction}" "${scrollBarFullSegments}" "${scrollProgressPercent}" "${firstActiveLine}" "${lastActiveLine}"

  printf '%s' "${barChar}"
}

function on_ctrl_c() {
  cleanup
  echo
  echo "Aborted."

  exit 0
}

function cleanup() {
  ansi::cur_show
  ansi::reset
  ui::enable_keyboard_input

  echo
}
main "$@"
