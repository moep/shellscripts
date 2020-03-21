#!/usr/bin/env bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then
  DIR="$PWD";
fi

source ${DIR}/../bootstrap.sh
include lib/ansi.sh
include lib/cli.sh
include lib/math.sh
include lib/str.sh
include lib/ui.sh
bootstrap::finish

trap on_ctrl_c INT

function main() {

  clear
  ansi::cur_hide
  local v1="1"
  local v2="2.0"
  local a=$(math::calc "(${v1} / ${v2})")
  a=$(math::calc "(${v1} / ${v2})")
  a=$(math::calc "(${v1} / ${v2})")
  a=$(math::calc "(${v1} / ${v2})")
  a=$(math::calc "(${v1} / ${v2})")
  a=$(math::calc "(${v1} / ${v2})")
  a=$(math::calc "(${v1} / ${v2})")
  a=$(math::calc "(${v1} / ${v2})")
  a=$(math::calc "(${v1} / ${v2})")

  
  printf "%s\n" "$a"
  cleanup
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
  cli::sane

  echo
}
main "$@"
