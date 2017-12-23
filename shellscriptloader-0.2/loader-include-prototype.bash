#!/bin/bash

# ----------------------------------------------------------------------

# loader-include-prototype.bash
#
# This script is a prototype implementation of the include() function of
# Shell Script Loader (RS0) for all versions of Bash starting 4.0.
#
# Features like compatibility checks, resets, cleanups and detailed
# failure messages are not included.
#
# Author: konsolebox
# Copyright Free / Public Domain
# June 25, 2016

# ----------------------------------------------------------------------

LOADER_PATHS=()
declare -A LOADER_FLAGS=()
declare -A LOADER_PATHS_FLAGS=()

function include {
	[[ $# -eq 0 ]] && loader_fail "Function called with no argument." include

	case $1 in
	'')
		loader_fail "File expression cannot be null." include
		;;
	/*|./*|../*)
		loader_getcleanpath "$1"
		[[ -n ${LOADER_FLAGS[$__]} ]] && return

		if [[ -f $__ ]]; then
			[[ -r $__ ]] || loader_fail "File not readable: $__" include
			loader_load "${@:2}"
			return
		fi
		;;
	*)
		[[ -n ${LOADER_FLAGS[$1]} ]] && return

		for __ in "${LOADER_PATHS[@]}"; do
			loader_getcleanpath "$__/$1"

			if [[ -n ${LOADER_FLAGS[$__]} ]]; then
				LOADER_FLAGS[$1]=.
				return
			elif [[ -f $__ ]]; then
				[[ -r $__ ]] || loader_fail "Found file not readable: $__" include
				LOADER_FLAGS[$1]=.
				loader_load "${@:2}"
				return
			fi
		done
		;;
	esac

	loader_fail "File not found: $1" include
}

function loader_addpath {
	for __; do
		[[ -d $__ ]] || loader_fail "Directory not found: $__" loader_addpath
		[[ -x $__ ]] || loader_fail "Directory not accessible: $__" loader_addpath
		[[ -r $__ ]] || loader_fail "Directory not searchable: $__" loader_addpath
		loader_getcleanpath "$__"

		if [[ -z ${LOADER_PATHS_FLAGS[$__]} ]]; then
			LOADER_PATHS[${#LOADER_PATHS[@]}]=$__
			LOADER_PATHS_FLAGS[$__]=.
		fi
	done
}

function loader_load {
	LOADER_FLAGS[$__]=.
	. "$__"
}

function loader_getcleanpath {
	local T1 T2=() I=0 IFS=/

	case $1 in
	/*)
		read -ra T1 <<< "${1#/}"
		;;
	*)
		read -ra T1 <<< "${PWD#/}/$1"
		;;
	esac

	for __ in "${T1[@]}"; do
		case $__ in
		..)
			[[ I -gt 0 ]] && (( --I ))
			;;
		.|'')
			;;
		*)
			T2[I++]=$__
			;;
		esac
	done

	__="/${T2[*]:0:I}"
}

function loader_fail {
	echo "loader: $2(): $1" >&2
	exit 1
}
