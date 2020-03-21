#!/usr/bin/env bash
include lib/ansi.sh

function cli::raw() {
  stty raw
}

function cli::sane() {
  stty sane
}

# Waits for a keypress using 'read' and prints the hex value of the input
function cli::read_key() {
  read -sN1 key
  read -sN1 -t 0.0001 k1
  read -sN1 -t 0.0001 k2
  read -sN1 -t 0.0001 k3
  key+=${k1}${k2}${k3}

  printf "$key" | xxd -p
}

function cli::read_single_key() {
  read -sN1 key
  printf "$key" | xxd -p
}

# Creates a simple yes / no prompt. Continues as soon as a valid key is pressed.
#
# < message
# < default_selection (optional) The input to be set when user input is empty (= return key)
# ^ true if yes was selected; false otherwise
function cli::prompt_yn() {
  local question=$1; shift
  local preselection=$1

  local input
  # [y|n]
  local hint='['"$(ansi::green 'y'; ansi::reset_fg;)|$(ansi::red 'n'; ansi::reset_fg;)"']'

  if ! is::_ empty "${preselection}"; then
    case $preselection in
      'y'|'Y')
        # [Y|n]
        hint='['"$(ansi::green 'Y'; ansi::reset_fg)|$(ansi::red 'n'; ansi::reset_fg;)"']'
      ;;
      'n'|'N')
        # [y|N]
        hint='['"$(ansi::green 'y'; ansi::reset_fg;)|$(ansi::red 'N'; ansi::reset_fg)"']'
      ;;
      *)
        show_error "ui::prompt_yn was called with wrong hint."
      ;;
    esac

  fi

  echo -n "${question}"
  ansi::bold
  echo -n " ${hint} "
  ansi::reset

  while true; do
    read -n 1 -s input

    if is::_ empty "${input}"; then
      input=$preselection
    fi

    case $input in
      'Y'|'y')
        echo $input
        return $TRUE
      ;;
      'N'|'n')
        echo $input
        return $FALSE
      ;;
    esac
  done
}