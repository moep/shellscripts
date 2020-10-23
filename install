#!/usr/bin/env bash

REPOSITORY="https://github.com/moep/shellscripts"
LIB_DIR="${HOME}/.local/lib/shellscripts"
SRC_DIR=$(dirname "${BASH_SOURCE[0]}")
FISH_DIR=${XDG_CONFIG_HOME:-$HOME/.config}/fish

# 1 = false; 0 = true
opt_dl=false
opt_force=false
opt_uninstall=false

function is_from_source() {
  local remote=$(cd "${SRC_DIR}" && git remote -v 2> /dev/null | head -1 | cut -f 2 | cut -d ' ' -f 1)
  if [[ "${remote}" == "${REPOSITORY}" ]]; then
    return 0
  else 
    return 1
  fi
}

function clone() {
  local tmp_dir=$(mktemp -d)
  rc=$?
  
  if [[ $rc -ne 0 ]]; then
    echo "Could not create tmp dir."
    exit 1
  fi

  echo " [*] Cloning into ${tmp_dir}..."
  git clone "${REPOSITORY}" "${tmp_dir}"

  SRC_DIR=$tmp_dir
}

function promptyn() {
  local question=$1
  local input

  echo -n "${question} [y|n]: "
  while true; do
    read -n 1 -s input

    case "$input" in
      'y'|'Y')
        echo "${input}"
        return $(true)
      ;;
      'n'|'N')
        echo "${input}"
        return $(false)
      ;;
    esac

  done
}

function has_fish_config() {
  [[ -f "${FISH_DIR}/config.fish" ]]
}

function fish_config_contains_path() {
  grep -q 'set -ux BASH_SCRIPT_PATH' "${FISH_DIR}/config.fish"
}

function install() {
  echo " [*] Copying sources from ${SRC_DIR} to ${LIB_DIR}"
  cp "${SRC_DIR}/bootstrap.sh" "${LIB_DIR}/"
  cp -r "${SRC_DIR}/contrib" "${LIB_DIR}/"
  cp -r "${SRC_DIR}/lib" "${LIB_DIR}/"
  cp -r "${SRC_DIR}/shellscriptloader-0.2" "${LIB_DIR}/"
  
  if has_fish_config && ! fish_config_contains_path; then
    echo " [*] Found${FISH_DIR}/config.fish."
    if promptyn "Do you want to add the library path variable to your config.fish?"; then
      echo " == ~/.config/fish/fish.config =="
      echo " +"
      echo " + # Autmatically added by shell script lib installer"
      echo " + set -gx BASH_SCRIPT_PATH ${LIB_DIR}"

      echo "" >> "${FISH_DIR}/config.fish"
      echo "# Autmatically added by shell script lib installer" >> "${FISH_DIR}/config.fish"
      echo "set -gx BASH_SCRIPT_PATH ${LIB_DIR}" >> "${FISH_DIR}/config.fish"
      echo
    fi
  fi
}

function uninstall() {
  promptyn "Do you really want to remove the shell script library?" || exit 1
  
  echo " [*] Removing ${LIB_DIR}"
  rm -rf "${LIB_DIR}"

  # TODO remove from configs

  echo " !! Please clean your config.fish | .bashrc manually !!"

  exit 0
}

function print_help() {
  echo "$(basename $0) (OPTS)"
  cat <<EOF
OPTS:
  --download       Force download even if called from git sources.
  --force          Force reinstallation.
  --uninstall      Uninstall and exit.
  -h, --help, -?   Print this message.
EOF
}

function parse_args() {
  for arg in "$@"; do
    case $arg in
      --download)
        opt_dl=true
        shift
      ;;
      --force)
        opt_force=true
        shift
      ;;
      --help|-h|-?)
        print_help
        exit 0
      ;;
      --uninstall)
        uninstall
      ;;
      *)
        print_help
        exit 1
      ;;
    esac
  done
}

function main() {
  parse_args "$@"

  #has_fish_config && echo "has fish config"
  #is_from_source && echo "is from source"
  #$opt_dl && echo "opt_dl"
  #$opt_force && echo "opt_force"

  if [[ -d "${LIB_DIR}" ]]; then
    echo "DEBUG: " $(pwd $LIB_DIR)
    echo "It looks like the library is already installed at ${LIB_DIR}."
    promptyn "Do you want to proceed?" || exit 0
  else
    echo " [*] mkdir ${LIB_DIR}"
    mkdir -p "${LIB_DIR}" 
  fi 

  # Script was called via curl -> download sources
  if ! is_from_source || $opt_dl; then
    clone
  fi

  install
}

main "$@"



# DEBUG

#parse_args "$@"
#has_fish_config && echo "has fish config"
#is_from_source && echo "is from source"
#$opt_dl && echo "opt_dl"
#$opt_force && echo "opt_force"
