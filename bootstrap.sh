#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")"/shellscriptloader-0.2/loader.sh

loader_addpath "$(dirname "${BASH_SOURCE[0]}")"

function bootstrap::finish() {
  loader_finish
}


