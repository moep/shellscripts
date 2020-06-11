#!/usr/bin/env bash

if [[ -z "${BASH_SCRIPT_PATH}" ]]; then
  echo "ERROR: BASH_SCRIPT_PATH is not set!"
  exit 1
fi

source ${BASH_SCRIPT_PATH}/bootstrap.sh
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
