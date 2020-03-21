#!/usr/bin/env bash

include lib/core.sh

function is::_() {
  if [[ "$#" == 0 ]]; then
    return $RC_USAGE
  fi

  local condition=$1
  local val_1=$2

  case $condition in
    declared)
      [[ -z "${val_1}" ]]; return $?
    ;;
    directory)
      [[ -d "${val_1}" ]]; return $?
    ;;
    empty)
      [[ "${val_1}" == "" ]]; return $?
    ;;
    even)
      [[ $((val_1%2)) -eq 0 ]]; return $?
    ;;
    file)
      [[ -f "${val_1}" ]]; return $?
    ;;
    function)
      declare -f "${val_1}" > /dev/null; return $?
    ;;
    true)
      [[ "${val_1}" == $TRUE ||  "${val_1}" == "true" ]]; return $?
    ;;
    *)
      return $RC_USAGE
    ;;
  esac
}

