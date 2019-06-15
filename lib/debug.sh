include lib/ui.sh

debug::print_stacktrace() {
  local i=1
  while [[ "$(caller $i)" != "" ]]; do
    caller $i
    i=$((i+1))
  done
}