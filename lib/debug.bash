#!/usr/bin/env false

function _debug {
  [[ $BASH_COMMAND =~ trap\ -|_debug\ DEBUG ]] && return 0
  local size=${#BASH_SOURCE[@]} contextLines=3 currentLine= currentFile= orow= cmdlines=$(cat $_dbg_log | wc -l)

  currentLine=${BASH_LINENO[size - 2]}
  currentFile="${BASH_SOURCE[size - 1]}"
  _get_cpos
  orow=$CROW

  [[ "$(awk -v line=$currentLine 'FNR == line { print $0 }' "$currentFile")" != *"$BASH_COMMAND"* ]] && return 0
  [ "$currentFile:$currentLine:$BASH_COMMAND" = "${_dbg_last_source_line:-}" ] && return 0
  _dbg_last_source_line="$currentFile:$currentLine:$BASH_COMMAND"

  echo -e "\033[30;47m" "INTERACTIVE EVAL" \
    "\033[0;37m" "$currentFile" \
    "\033[0m"
  echo -e "\033[30;45m" \
    "$cmdlines OUTPUT LINE$([ $cmdlines != 1 ] && echo "S")" \
    "\033[0m"
  cat "$_dbg_log" | sed -r $'s,^.*$,\033[35m │ \033[0m\\0\033[0K,gm'

  echo -e "\033[30;44m" "NEXT" "\033[0;34m" "$BASH_COMMAND" "\033[0m"
  _file_context_debug \
    $(( currentLine - contextLines )) \
    $(( currentLine + contextLines )) \
    $currentLine \
    "$currentFile"
  while read -rep "debug$ " -a cmd; do
    if [ -n "${cmd[*]}" ]; then
      "${cmd[@]}"
    else
      break
    fi
  done
  echo -ne "\033[$orow;0H\033[0J"
}

: ${_dbg_log:="$(mktemp)-debug"}
_get_cpos
_dbg_source_row=$CROW
exec 3>&1 4>&2
exec 1>$_dbg_log 2>&1
_dbg_prev_trap=($(trap -p EXIT))
trap 'trap - DEBUG; exec 1>&3 2>&4; cat $_dbg_log; rm -f $_dbg_log; ${_dbg_prev_trap[2]}' EXIT
trap '_debug 1>&3 2>&4' DEBUG
