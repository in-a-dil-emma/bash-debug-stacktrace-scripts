#!/usr/bin/env false

shopt -s extglob

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
function _trace {
  local contextLines=4 size=${#BASH_SOURCE[@]}

  if (( size < 1 )); then
    echo -e "\033[47;30m NO TRACE \033[0m"
    return 0
  fi

  echo -e "\033[47;30m" "TRACE" "\033[0m" \
    "\033[42;30m" $((size - 1)) "FRAME$( (( size != 2 )) && echo S)" "\033[0m" \
    "in" "\033[31mFILE\033[0m" \
    "at" "\033[33mLINE\033[0m" \
    "contained in" "\033[35mFUNCTION\033[0m" \
    "ordered ascending by relevancy"

  for (( i = size - 2; i >= 0; i-- )); do
    if (( i > 0 )); then
      echo -ne '\033[32m╠\033[0m'
    else
      echo -ne '\033[32m╙\033[0m'
    fi
    echo -e "\033[42;30m $(( size - i - 1 )) \033[0m" \
      "\033[31m${BASH_SOURCE[$i+1]}\033[0m:\033[33m${BASH_LINENO[$i]}\033[0m" \
      "\033[35m${FUNCNAME[$i+1]}()\033[0m"
    (( i > 1 && i < size - 2 )) && continue
    if (( i > 0 )); then
      _file_context_trace \
        $(( BASH_LINENO[$i] - contextLines )) \
        $(( BASH_LINENO[$i] + contextLines )) \
        ${BASH_LINENO[$i]} \
        "${BASH_SOURCE[$i+1]}" | sed $'s,^ ,\033[32m║\033[0m,gm'
    else
      _file_context_trace \
        $(( BASH_LINENO[$i] - contextLines )) \
        $(( BASH_LINENO[$i] + contextLines )) \
        ${BASH_LINENO[$i]} \
        "${BASH_SOURCE[$i+1]}"
    fi
  done
}

trap _trace ERR