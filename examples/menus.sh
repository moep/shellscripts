#!/usr/bin/env bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then
  DIR="$PWD";
fi

source ${DIR}/../bootstrap.sh
include lib/ansi.sh
include lib/cli.sh
include lib/os.sh
include lib/str.sh
include lib/ui.sh
bootstrap::finish

trap on_ctrl_c INT

function main() {

  # Start with a blank screen and disable cursor
  clear
  ansi::cur_hide

  #ansi::fg_256 $((RANDOM%256))
  #figlet -d ~/.figlet -f 3d -c  "main 3" #| lolcat -S 80
  #ansi::reset

  # First Header
  print_header "Installation Options"

  # Prompt Mockup
  #ansi::fg_256 250
  #echo -n "Do something? "
  #ansi::fg_256 4
  #echo -n "[y|n]"
  #ansi::fg_256 250
  #echo -n " > "
  #ansi::reset_fg
  #ansi::bg_256 4
  #ansi::bold
  #echo -n " Y "
  #ansi::reset
  #echo

  # The values that are asked from the user
  local selection1
  local selection2
  local selection3

  ansi::fg_256 250
  printf 'Choose application to install:'
  ansi::reset
  ACTIVE_LINE_MARKER=$(ansi::yellow; ansi::bold; printf '❯ '; ansi::reset_bold) \
    ui::show_menu 'extras/lolcat' 'lolcat' \
                  'essentials/nc' 'netcat' \
                  'essentials/cat' 'cat' \
                  'extras/topcat' 'topcat'

  echo
  selection1=$(ui::get_last_return_value)

  ansi::fg_256 250
  echo 'Choose your extras:'
  ansi::reset
  ui::show_option_menu false 'Man pages' \
                       false 'Source code' \
                       true  'All mailing list conversations containing swear words'
  echo
  selection2=$(ui::get_last_return_label)

  ansi::fg_256 250
  printf 'Select Version:'
  ansi::reset
  ui::show_radio_menu false 'Nightly' \
                      false 'Unstable' \
                      true  'Stable' \
                      false 'LTS'

  echo
  selection3=$(ui::get_last_return_label)




  print_header "Input Summary"

  ansi::fg_256 250
  printf "First selection (value): "
  ansi::reset
  printf "%s" "${selection1}"

  echo
  ansi::fg_256 250
  printf "Second selection (labels): "
  ansi::reset
  printf "%s" "${selection2}"

  echo
  ansi::fg_256 250
  printf "Third selection (label): "
  ansi::reset
  printf "%s" "${selection3}"


  echo
  ansi::fg_256 250
  cli::prompt_yn "Continue installation?" "y"
  rc=$?
  ansi::reset

  if [[ $rc -eq $FALSE ]]; then
    echo
    ansi::bold
    echo "The End."
    cleanup

    exit $RC_OK
  fi

  echo
  print_header 'Installation'


  printf 'Installing'
  ui::disable_keyboard_input
  os::exec_and_wait sleep 4 2> /dev/null
  ui::enable_keyboard_input
  #echo -n "Done."

  echo
  ui::show_error "This is just a mockup. Nothing was installed."


  cleanup
}

function print_header() {
  local str=$1

  printf "━━━ "
  ansi::red
  ansi::bold
  str::stretch "${str}"
  ansi::reset
  printf " "
  str::fill "" "━" "" $(ui::remaining_columns)
  echo

  echo ""
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
