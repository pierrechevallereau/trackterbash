#!/usr/bin/env bash

##############################################################
#       trackterbash.sh
#       Version 1.0.0 - 25/03/2019
#       trackterbash is a bash library designed to trap/tag/color,
#       errors and stop smoothly the main process. 
##############################################################

##### PARSE ARGS #####
if [[ "${#}" -gt 0  ]] ; then
  for opts in "${@}"; do
    case "${opts}" in
      --no-exit)
        noexit=true
      ;;
      --exit-function=*)
        exitfunction=${opts//*=}
      ;;
      --no-ctrlc)
        noctrlc=true
      ;;
      --ctrlc-function=*)
        ctrlcfunction=${opts//*=}
      ;;
      --prefix-all)
        prefixall=true
      ;;
      --no-surround-errors)
        nosurrounderrors=true
      ;;
      --debug|-d|--verbose|-v)
        debug=true
      ;;
      --help|-h)
        echo "--no-exit                 : don't stop the main process on error"
        echo "--exit-function='_exit'   : change exit function when --no-exit isn't used"
        echo "--no-ctrlc                : don't trap ctrl+c SIGINT"
        echo "--ctrlc-function='_ctrlc' : change ctrl+c function when --no-ctrlc isn't used"
        echo "--prefix-all              : preffix all output from FD 1&2 with 'date hour script-name'"
        echo "--no-surround-errors      : don't surround errors with red color"
        echo "--debug|-d|--verbose|-v   : enable debug mode with set -x"
        echo "--help|-h                 : print help"
      ;;
      *)
        echo "error : ${opts}"
        exit
      ;;
    esac
  done
fi

# --no-exit if variable is true
if [[ ! "${noexit}" ]] ; then
  # Set up trap and soft _exit function
  # In _exit function you can do anything before exiting with exit code = 1 (examples: close ssh tunnel, or remove temp directory)
  _exit()
  {
    sleep 0.15 # little sleep time to prevent disordered log
    echo 'Exit due to an error'
    exit 1
  }

  # --exit-functions used if set, else _exit function is used
  # This trap commands exited with an error
  trap "${exitfunction:-_exit}" ERR
fi

# --no-ctrlc if variable is true
if [[ ! "${noctrlc}" ]] ; then
  # Set up trap and soft _ctrlc function
  # In _ctrlc function you can do anything before exiting with exit code = 2 (examples: close ssh tunnel, or remove temp directory)

  _ctrlc()
  {
    sleep 0.15 # little sleep time to prevent disordered log
    echo -e '\nExit due to a Ctrl+C'
    exit 2
  }

  # --ctrlc-function used if set, else _ctrlc function is used
  # This trap Ctrl+C maccro
  trap "${ctrlcfunction:-_ctrlc}" INT
fi

# --prefix-all if variable is true \
  # This prefix all line with date and script name
if [[ "${prefixall}" ]] ; then
  exec &> >(sed -u "s/\(^.*$\)/$(date "+%d-%m-%Y %H:%M ${0##*/}: ")\1/g")
fi

# --no-surround-errors if variable is true \
  # This print everything that goes in file descriptor 2 with red color
if [[ ! "${nosurrounderrors}" ]] ; then
  exec 2> >(while read -r line; do echo -e "\e[01;31m$line\e[0m" ; done)
fi

# logerr function, redirect message in file descriptor 2 and return 1 to be trapped
_logerr()
{
  echo "${@}" >&2
  sleep 0.15 # little sleep time to prevent disordered log
  return 1 # log and return 1 for exit with trap
}

# --debug|-d|--verbose|-v if variable is true \
  # Debug mode
if [[ "${debug}" ]] ; then
  { export BASH_XTRACEFD=1 ; set -x ; }
fi
