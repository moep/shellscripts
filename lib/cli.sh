#!/usr/bin/env bash


# Waits for a keypress using 'read' and prints the hex value of the input
function cli::read_key() {
  read -sN1 key
  read -sN1 -t 0.0001 k1
  read -sN1 -t 0.0001 k2
  read -sN1 -t 0.0001 k3
  key+=${k1}${k2}${k3}

  printf "$key" | xxd -p
}