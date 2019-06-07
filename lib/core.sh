#!/usr/bin/env bash

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

