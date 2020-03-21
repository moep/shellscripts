#!/usr/bin/env bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then
  DIR="$PWD";
fi

source ${DIR}/../bootstrap.sh
include lib/ansi.sh
include lib/ui.sh
bootstrap::finish

trap cleanup SIGTERM ERR EXIT
trap on_ctrl_c INT

main() {
  ansi::cur_hide

  echo "Deleting old files and pipes."
  rm -f pipe > /dev/null 2>&1
  rm -f file.tmp > /dev/null 2>&1
  rm -f curl.rc  > /dev/null 2>&1
  rm -f trace.txt  > /dev/null 2>&1


  echo "Creating pipe"
  mkfifo pipe

  # Idea taken from here:
  # https://gist.github.com/Szero/cd496ca43df4b871df75818ebcc40233
  echo "Downloading"
  #start_curl -L "$1" -o file.tmp
  start_curl2 "http://localhost:8080/Outcast-7693-DRMFREE.zip" &
  echo "Parsing"
  sleep 1
  while read line; do
    words=$(echo "$line" | tr " " "\n")
    echo "${words[0]};"
  done < trace.txt

  while IFS=" " read -a line > /dev/null 2>&1 < pipe; do
    tag="${line[0]} ${line[1]}"

    if [[ "${line[0]}" == "0000:" ]]; then
      ansi::yellow
    fi;

    if [[ "${line[1]}" == "Content-Length:" ]];then
      ansi::green
    fi;

    if [[ "${line[1]}" == "recv" ]];then
      ansi::cyan
    fi;

    echo "${line[@]}'"

    ansi::reset
  done

  return

  echo "Filling"
  mock_progress &

  # Read Progress from pipe and update progress bar accordingly
  echo "Doing something"

  while read line > /dev/null 2>&1 < pipe; do
    ansi::cur_save
    if [[ $line -lt 30 ]]; then
      ui::progressbar::red 40 $line
    elif [[ $line -lt 70 ]]; then
      ui::progressbar::yellow 40 $line
    else
      ui::progressbar::green 40 $line
    fi
    ansi::cur_restore
  done

  echo

  echo "We progressed enough for today"
}

function mock_progress() {
  for i in `seq 0 10`; do
    echo "$((10*i))" > pipe
    sleep 1
  done

  rm -f pipe
}

function start_curl() {
  (
  set +e
  curl --trace-ascii pipe -s "$@"
  curl_rc="$?"

  echo "$curl_exit_code" >> curl.rc
  echo "ENDE">> pipe
  rm -f pipe
  sync
  ) &
}

function start_curl2() {
  curl -s -# -L $1 -o file.tmp --trace-ascii trace.txt

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
  pkill -P $$

  echo "Cleaned up."
}

main "$@"