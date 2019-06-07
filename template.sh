#!/usr/bin/env bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then
  DIR="$PWD";
fi

source ${DIR}/bootstrap.sh
include lib/ansi.sh
include lib/ui.sh
bootstrap::finish

trap cleanup SIGTERM ERR EXIT
trap on_ctrl_c INT

main() {
  echo "Hello World."
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
  # Kill all child processes
  pkill -P $$

  echo
}

main "$@"