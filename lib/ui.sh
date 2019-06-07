#!/usr/bin/env bash

include lib/ansi.sh
include lib/core.sh
include lib/is.sh
include lib/str.sh
include lib/tmux.sh

readonly KEYCODE_UP='1b5b41'
readonly KEYCODE_DOWN='1b5b42'
readonly KEYCODE_ENTER='0a'
readonly KEYCODE_ESC='1b'
readonly KEYCODE_SPACE='20'
readonly KEYCODE_BACKSPACE='08'
readonly KEYCODE_SHIFT_BACKSPACE='7f'
readonly KEYCODE_TAB='09'
readonly KEYCODE_SHIFT_TAB='1b5b5a'
# TODO Are constants really necessary for those?
readonly KEYCODE_J='6a'
readonly KEYCODE_K='6b'
readonly KEYCODE_S='73'

readonly K_PROGRESS_BAR_SEGMENT_ACTIVE='━'
readonly K_PROGRESS_BAR_SEGMENT_INACTIVE='━'

# Overwrite these for custom styles
ACTIVE_LINE_MARKER=$(ansi::cyan; ansi::bold; printf '❯ '; ansi::reset_bold)
SELECT_ITEM_EMPTY='□ '
SELECT_ITEM_SELECTED='■ '
RADIO_ITEM_EMPTY='○ '
RADIO_ITEM_SELECTED='● '
#RADIO_ITEM_EMPTY='⬡ '
#RADIO_ITEM_SELECTED='⬢ '


__MENU_VALUES=()
__MENU_LABELS=()
__MENU_SELECTED_LINE=0
__MENU_RETURN_VALUES=()
__MENU_RETURN_LABELS=()

function ui::h1() {
  ansi::bold
  ansi::green
  printf ">"
  ansi::yellow
  printf ">"
  ansi::red
  printf "> "
  ansi::reset
  printf "$*"
  printf "\r\n"
}

function ui::h2() {
  printf "━━━┫"
  ansi::bold
  printf " $* "
  ansi::reset
  printf "┣━━━━━━━━━━━━━"
  printf "\r\n"
}

# Creates a simple yes / no prompt. Continues as soon as a valid key is pressed.
#
# < message
# < default_selection (optional) The input to be set when user input is empty (= return key)
# ^ true if yes was selected; false otherwise
function ui::prompt_yn() {
  local question=$1; shift
  local preselection=$1

  local input
  local hint='[y|n]'

  if ! is::_ empty "${preselection}"; then
    case $preselection in
      'y'|'Y')
        hint='[Y|n]'
      ;;
      'n'|'N')
        hint='[y|N]'
      ;;
      *)
        show_error "ui::prompt_yn was called with wrong hint."
      ;;
    esac

  fi

  echo -n "${question}"
  ansi::bold
  echo -n " ${hint} "
  ansi::reset

  while true; do
    read -n 1 -s input

    if is::_ empty "${input}"; then
      input=$preselection
    fi

    case $input in
      'Y'|'y')
        echo $input
        return $TRUE
      ;;
      'N'|'n')
        echo $input
        return $FALSE
      ;;
    esac
  done




}

# Prints a progress bar of a given width filled to a given percentage

# < width Width in characters
# < style_active   Style for filled part
# < style_inactive Style for the unfilled part
# < percent        Progress in Percent
function ui::progressbar() {
  # TODO use only shift or indices
  local width=$1; shift
  local style_active=$2
  local style_inactive=$3
  local percent=$(math::round $1)
  local width_active=$(math::calc "${percent} * 0.01 * ${width}")
  local width_inactive=$(math::calc "${width} - ${width_active}")

  printf "%s" "${style_active}"
  str::fill "" "${K_PROGRESS_BAR_SEGMENT_ACTIVE}" "" "${width_active}"
  printf "%s" "${style_inactive}"
  str::fill "" "${K_PROGRESS_BAR_SEGMENT_INACTIVE}" "" "${width_inactive}"
  ansi::reset
}

function ui::progressbar::white() {
  ui::progressbar $1 $2 $(ansi::bright_white) $(ansi::bright_black)
}

function ui::progressbar::red() {
  ui::progressbar $1 $2 $(ansi::red) $(ansi::bright_black)
}

function ui::progressbar::green() {
  ui::progressbar $1 $2 $(ansi::bright_green) $(ansi::bright_black)
}

function ui::progressbar::yellow() {
  ui::progressbar $1 $2 $(ansi::bright_yellow) $(ansi::bright_black)
}

function ui::disable_keyboard_input() {
  stty raw -echo
}

function ui::enable_keyboard_input() {
  stty echo -raw
}

function ui::remaining_columns() {
   local cur_pos=($(ansi::cur_pos))
   local terminal_size=($(ansi::terminal_size))

   echo $(math::calc "${terminal_size[1]} - ${cur_pos[1]} + 1")
}

# Returns true if is last line; false otherwise
function ui::is_last_line?() {
  # TODO debug only
  return $FALSE

  local cur_pos=($(ansi::cur_pos))
  local terminal_size=($(ansi::terminal_size))

  if [[ "${cur_pos[0]}" == "${terminal_size[0]}" ]]; then
    return $TRUE
  else
    return $FALSE
  fi
}

# Creates an empty line at the bottom of the console.
# Uses tmux notification when in tmux mode.
#
# < str The error text to display
function ui::show_error() {
  local str=$1

  local terminal_size=($(ansi::terminal_size))

  #if tmux::is_tmux?; then
  #  tmux::message_red "${str}"
  #  return
  #fi

  # if last line: scroll 2 up
  #if ui::is_last_line? ;then
  #  ansi::scroll_up 2
  #fi

  ansi::cur_save

  # Create red line
  ansi::bg_256 1
  ansi::bold
  #ansi::cur_pos ${terminal_size[0]} 1
  # TODO conflicts with ansi.sh:267 when input buffer is not empty
  # Looks like this can be omitted
  #str::pad_right $(ui::remaining_columns)
  ansi::cur_pos ${terminal_size[0]} 1
  str::right "[⏎ to close]"
  ansi::cur_pos ${terminal_size[0]} 1
  printf "%s" "$1"
  ansi::reset

  while [ "$(cli::read_key)" != "$KEYCODE_ENTER" ]; do
    : # NOOP
  done

  # Hide error bar
  ansi::cur_pos ${terminal_size[0]} 1
  ansi::delete_line

  # Go back to last output
  ansi::cur_restore
}

# Prints the value(s) of the last show_*menu call's selection(s).
function ui::get_last_return_value() {
  if [[ ${#__MENU_RETURN_VALUES[@]} == 1 ]]; then
    printf "%s" "${__MENU_RETURN_VALUES[@]}"
  else
    printf "\"%s\"" "${__MENU_RETURN_VALUES[@]}"
  fi
}

function ui::get_last_return_label() {
  if [[ ${#__MENU_RETURN_LABELS[@]} == 1 ]]; then
    printf "%s" "${__MENU_RETURN_LABELS[0]}"
  else
    printf "\"%s\"" "${__MENU_RETURN_LABELS[@]}"
  fi
}

# TODO rename functions similar to ui::progressbar
# TODO Maybe move them to custom folder, too
# Simple menu ------------------------------------------------
function ui::show_menu() {
   if [[ "$#" -eq "0" ]]; then
     ui::show_error "ui::show_menu expects at least two parameters."
     exit $RC_USAGE
   fi

   if ! is::_ even $#; then
     ui::show_error "ui::show_menu expects an even number of parameters."
     exit $RC_USAGE
   fi

  local params=("$@")
  local values=()
  local labels=()

  ansi::cur_hide

  local numItemsMinusOne=$(math::calc "$# / 2 - 1")
  local index

  # Reset last call's values
  __MENU_VALUES=()
  __MENU_LABELS=()
  __MENU_SELECTED_LINE=0

  for i in `seq 0 $numItemsMinusOne`; do
    index=$((2*i))
    __MENU_VALUES+=("${params[$index]}")
    __MENU_LABELS+=("${params[$index+1]}")
  done

  ansi::cur_save
  ansi::cur_next_line

  while true; do
    # Render
    ui::_render_menu_lines

    # Read input
    key=$(cli::read_key)
    val=$(str::from_hex "$key")

    case "${key}" in
      "${KEYCODE_UP}"|"${KEYCODE_K}")
        if [[ $__MENU_SELECTED_LINE != 0 ]]; then
          __MENU_SELECTED_LINE=$((__MENU_SELECTED_LINE-1))
        fi
      ;;
      "${KEYCODE_DOWN}"|"${KEYCODE_J}")
        if [[ $__MENU_SELECTED_LINE -lt $(math::round $numItemsMinusOne) ]]; then
          __MENU_SELECTED_LINE=$((__MENU_SELECTED_LINE+1))
        fi
      ;;
      "${KEYCODE_ENTER}"|"${KEYCODE_S}")
        ui::_menu_on_finish
        return $RC_OK
      ;;
      *)
        ansi::bell
      ;;
    esac

    ansi::cur_restore
    ansi::cur_next_line
  done;
}

function ui::_render_menu_lines() {
  local numItems=${#__MENU_LABELS[@]}

  for i in `seq 0 $((numItems-1))`; do
    ansi::delete_line

    if [[ $i -eq $__MENU_SELECTED_LINE ]]; then
      echo "${ACTIVE_LINE_MARKER}${__MENU_LABELS[$i]}"
    else
      echo "  ${__MENU_LABELS[$i]}"
    fi

    ansi::reset
  done
}

function ui::_menu_on_finish() {
  # TODO Make this behaviour configurable
  ansi::cur_restore
  ansi::cur_next_line

  __MENU_RETURN_VALUES=()
  __MENU_RETURN_LABELS=()

  local numItems=${#__MENU_VALUES[@]}
  for i in `seq 0 $(($numItems))`; do
    ansi::delete_line
    ansi::cur_next_line
  done

  ansi::cur_restore
  printf " ${__MENU_LABELS[$__MENU_SELECTED_LINE]}"
  __MENU_RETURN_VALUES=("${__MENU_VALUES[$__MENU_SELECTED_LINE]}")
  __MENU_RETURN_LABELS=("${__MENU_LABELS[$__MENU_SELECTED_LINE]}")
  echo
}

# Option menu ------------------------------------------------

function ui::show_option_menu() {
   if [[ "$#" -eq "0" ]]; then
     ui::show_error "ui::show_menu expects at least two parameters."
     exit $RC_USAGE
   fi

   if ! is::_ even $#; then
     ui::show_error "ui::show_menu expects an even number of parameters."
     exit $RC_USAGE
   fi

  local params=("$@")
  local values=()
  local labels=()

  ansi::cur_hide

  local numItemsMinusOne=$(math::calc "$# / 2 - 1")
  local index

  # Reset last call's values
  __MENU_VALUES=()
  __MENU_LABELS=()
  __MENU_SELECTED_LINE=0

  for i in `seq 0 $numItemsMinusOne`; do
    index=$((2*i))
    __MENU_VALUES+=("${params[$index]}")
    __MENU_LABELS+=("${params[$index+1]}")
  done

  ansi::cur_save

  while true; do
    # Render
    ui::_render_option_menu_lines

    # Read input
    key=$(cli::read_key)
    val=$(str::from_hex "$key")

    case "${key}" in
      "${KEYCODE_UP}"|"${KEYCODE_K}")
        if [[ $__MENU_SELECTED_LINE != 0 ]]; then
          __MENU_SELECTED_LINE=$((__MENU_SELECTED_LINE-1))
        fi
      ;;
      "${KEYCODE_DOWN}"|"${KEYCODE_J}")
        if [[ $__MENU_SELECTED_LINE -lt $(math::round $numItemsMinusOne) ]]; then
          __MENU_SELECTED_LINE=$((__MENU_SELECTED_LINE+1))
        fi
      ;;
      "${KEYCODE_SPACE}"|"${KEYCODE_S}")
        ui::_toggle_menu_value $__MENU_SELECTED_LINE
      ;;
      "${KEYCODE_ENTER}")
        ui::_option_menu_on_finish
        return $RC_OK
      ;;
      *)
        ansi::bell
      ;;
    esac

    ansi::cur_restore
  done;
}

function ui::_render_option_menu_lines() {
  local numItems=${#__MENU_LABELS[@]}

  for i in `seq 0 $((numItems-1))`; do
    ansi::delete_line

    local prefix=''
    if [[ $i -eq $__MENU_SELECTED_LINE ]]; then
      prefix+="${ACTIVE_LINE_MARKER}"
    else
      #prefix+=$(str::pad_right $(str::length "► ") "-")
      prefix+="  "
    fi

    if is::_ true ${__MENU_VALUES[$i]}; then
      prefix+="${SELECT_ITEM_SELECTED}"
    else
      prefix+="${SELECT_ITEM_EMPTY}"
    fi

    echo "${prefix}${__MENU_LABELS[$i]}"

    ansi::reset
  done
}

function ui::_toggle_menu_value() {
  local index=$1;

  if is::_ true ${__MENU_VALUES[$index]}; then
    __MENU_VALUES[$index]=false
  else
    __MENU_VALUES[$index]=true
  fi
}

function ui::_option_menu_on_finish() {
  # TODO Make this behaviour
  ansi::cur_restore

  __MENU_RETURN_VALUES=()
  __MENU_RETURN_LABELS=()

  # Delete old lines
  local numItems=${#__MENU_VALUES[@]}
  for i in `seq 0 $(($numItems))`; do
    ansi::delete_line
    ansi::cur_next_line
  done

  ansi::cur_restore

  # Output selected lines
  for i in `seq 0 $((numItems-1))`; do

    if is::_ true ${__MENU_VALUES[$i]}; then
      echo " - ${__MENU_LABELS[$i]}"
      __MENU_RETURN_VALUES+=("${__MENU_VALUES[$i]}")
      __MENU_RETURN_LABELS+=("${__MENU_LABELS[$i]}")
    fi

    ansi::reset
  done

}

# Radio menu ------------------------------------------------
function ui::show_radio_menu() {
   if [[ "$#" -eq "0" ]]; then
     ui::show_error "ui::show_menu expects at least two parameters."
     exit $RC_USAGE
   fi

   if ! is::_ even $#; then
     ui::show_error "ui::show_menu expects an even number of parameters."
     exit $RC_USAGE
   fi

  local params=("$@")
  local values=()
  local labels=()

  ansi::cur_hide

  local numItemsMinusOne=$(math::calc "$# / 2 - 1")
  local index

  # Reset last call's values
  __MENU_VALUES=()
  __MENU_LABELS=()
  __MENU_SELECTED_LINE=0

  for i in `seq 0 $numItemsMinusOne`; do
    index=$((2*i))
    __MENU_VALUES+=("${params[$index]}")
    __MENU_LABELS+=("${params[$index+1]}")
  done

  ansi::cur_save
  ansi::cur_next_line

  while true; do
    # Render
    ui::_render_radio_menu_lines

    # Read input
    key=$(cli::read_key)
    val=$(str::from_hex "$key")

    case "${key}" in
      "${KEYCODE_UP}"|"${KEYCODE_K}")
        if [[ $__MENU_SELECTED_LINE != 0 ]]; then
          __MENU_SELECTED_LINE=$((__MENU_SELECTED_LINE-1))
        fi
      ;;
      "${KEYCODE_DOWN}"|"${KEYCODE_J}")
        if [[ $__MENU_SELECTED_LINE -lt $(math::round $numItemsMinusOne) ]]; then
          __MENU_SELECTED_LINE=$((__MENU_SELECTED_LINE+1))
        fi
      ;;
      "${KEYCODE_SPACE}"|"${KEYCODE_S}")
        ui::_activate_radio_button $__MENU_SELECTED_LINE
      ;;
      "${KEYCODE_ENTER}")
        ui::_menu_on_finish
        return $RC_OK
      ;;
      *)
        ansi::bell
      ;;
    esac

    ansi::cur_restore
    ansi::cur_next_line
  done;
}

function ui::_render_radio_menu_lines() {
  local numItems=${#__MENU_LABELS[@]}

  for i in `seq 0 $((numItems-1))`; do
    ansi::delete_line

    local prefix=''
    if [[ $i -eq $__MENU_SELECTED_LINE ]]; then
      prefix+="${ACTIVE_LINE_MARKER}"
    else
      #prefix+=$(str::pad_right $(str::length "► ") "-")
      prefix+="  "
    fi

    if is::_ true ${__MENU_VALUES[$i]}; then
      prefix+="${RADIO_ITEM_SELECTED}"
    else
      prefix+="${RADIO_ITEM_EMPTY}"
    fi

    echo "${prefix}${__MENU_LABELS[$i]}"

    ansi::reset
  done
}

function ui::_activate_radio_button() {
  local index=$1

  local numItems=${#__MENU_VALUES[@]}

  for i in `seq 0 $((numItems-1))`; do
    if [[ $i == $index ]]; then
      __MENU_VALUES[$i]=true
    else
      __MENU_VALUES[$i]=false
    fi
  done
}
