#!/usr/bin/env bash

source loader.sh

loader_addpath .

function start::finish() {
  loader_finish
}

load main.sh
