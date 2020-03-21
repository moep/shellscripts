include lib/ansi.sh

readonly COLOR_DEBUG=$(ansi::white)
readonly COLOR_INFO=$(ansi::fg_256 245)
readonly COLOR_WARN=$(ansi::yellow)
readonly COLOR_ERROR=$(ansi::red)

readonly PREFIX_DEBUG="${COLOR_DEBUG}┃ "
readonly PREFIX_INFO="${COLOR_INFO}┃"
readonly PREFIX_WARN="${COLOR_WARN}┃ "
readonly PREFIX_ERROR="${COLOR_ERROR}┃ "

# TODO get top caller
LOG_TAG="${COLOR_INFO} ${BASH_SOURCE[4]}: $(ansi::reset)" 
function log::d() {
  printf "%s%s\r\n" "${PREFIX_DEBUG}" "$*"
  ansi::reset
}

function log::i() {
  printf "%s%s%s\r\n" "${PREFIX_INFO}" "${LOG_TAG}" "$*"
  ansi::reset
}

function log::w() {
  printf "%s%s\r\n" "${PREFIX_WARN}" "$*"
  ansi::reset
}

function log::e() {
  printf "%s%s\r\n" "${PREFIX_ERROR}" "$*"
  ansi::reset
}