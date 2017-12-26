#!/usr/bin/env bash

include lib/ansi.sh
include lib/str.sh

K_PROGRESS_BAR_SEGMENT_ACTIVE='━'
K_PROGRESS_BAR_SEGMENT_INACTIVE='━'

function ui::h1() {
  ansi::bold
  ansi::green
  printf ">"
  ansi::yellow
  printf ">"
  ansi::red
  printf "> "
  ansi::reset
  printf "$*"
  printf "\r\n"
}

function ui::h2() {
  printf "━━━┫"
  ansi::bold
  printf " $* "
  ansi::reset
  printf "┣━━━━━━━━━━━━━"
  printf "\r\n"
}

function ui::progressbar() {
  local width=$1; shift
  local style_active=$2
  local style_inactive=$3
  local percent=$(math::round $1)
  local width_active=$(math::calc "${percent} * 0.01 * ${width}")
  local width_inactive=$(math::calc "${width} - ${width_active}")

  printf "%s" "${style_active}"
  str::fill "" "${K_PROGRESS_BAR_SEGMENT_ACTIVE}" "" "${width_active}"
  printf "%s" "${style_inactive}"
  str::fill "" "${K_PROGRESS_BAR_SEGMENT_INACTIVE}" "" "${width_inactive}"
  ansi::reset
}

function ui::progressbar::white() {
  ui::progressbar $1 $2 $(ansi::bright_white) $(ansi::bright_black)
}

function ui::progressbar::red() {
  ui::progressbar $1 $2 $(ansi::red) $(ansi::bright_black)
}

function ui::progressbar::green() {
  ui::progressbar $1 $2 $(ansi::bright_green) $(ansi::bright_black)
}

function ui::progressbar::yellow() {
  ui::progressbar $1 $2 $(ansi::bright_yellow) $(ansi::bright_black)
}
