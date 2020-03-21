#!/usr/bin/env bash

include lib/debug.sh
include lib/os.sh

# Based on sysexits.h
# see https://www.freebsd.org/cgi/man.cgi?query=sysexits&apropos=0&sektion=0&manpath=FreeBSD+4.3-RELEASE&format=html

declare -g -r RC_OK=0
declare -g -r RC_ERROR=1

declare -g -r FALSE=$RC_ERROR
declare -g -r TRUE=$RC_OK

# The command was used incorrectly, e.g., with the
# wrong number of arguments, a bad flag, a bad syntax
# in a parameter, or whatever.
declare -g -r RC_USAGE=64

# The input data was incorrect in some way.  This
# should only be used for user's data and not system
# files.
declare -g -r RC_DATAERR=65

function core::print_error() {
  (>&2 printf "%s\r\n" "$@")
}

function core::assert_available() {
  for program; do
    if ! os::is_installed? "${program}"; then
      core::print_error "ERROR: '${program}' is not installed. Exiting."
      debug::print_stacktrace
      exit $RC_ERROR
    fi
  done
}
