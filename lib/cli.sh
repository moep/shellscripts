#!/usr/bin/env bash

function cli::prompt_yn() {
  local question=$1
  local input

  echo -n ":: ${question} [Y|n] "
  read -n1 input
  echo

  case $input in
    'Y'|'y'|'')
      return 0
    ;;
    *)
      return 1
    ;;
  esac
}
