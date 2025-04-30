#!/usr/bin/env false

shopt -s extglob

export BASH_ARGV0="$(realpath "$0")"

function _get_cpos {
  IFS=';' read -sdR -p $'\033[6n' CROW CCOL
  CROW="${CROW#*\[}"
}
function _file_context_trace {
  awk \
    -v lower=$1 \
    -v upper=$2 \
    -v line=$3 \
    '
  FNR >= lower && FNR < line { print " \033[33m│\033[33m "   FNR" \033[0m "        $0"\033[0m\033[0K" }
  FNR == line                { print " \033[33m└\033[30;43m "FNR" \033[0m \033[33m"$0"\033[0m\033[0K" }
  FNR <= upper && FNR > line { print "  \033[33m "           FNR" \033[0m "        $0"\033[0m\033[0K" }
  ' "$4"
}
function _file_context_debug {
  awk \
    -v lower=$1 \
    -v upper=$2 \
    -v line=$3 \
    '
  FNR >= lower && FNR < line { print " \033[34m│\033[34m "   FNR" \033[0m "        $0"\033[0m\033[0K" }
  FNR == line                { print " \033[34m└\033[30;44m "FNR" \033[0m \033[34m"$0"\033[0m\033[0K" }
  FNR <= upper && FNR > line { print "  \033[34m "           FNR" \033[0m "        $0"\033[0m\033[0K" }
  ' "$4"
}
