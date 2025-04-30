#!/usr/bin/env bash

source ./lib/basic.bash
source ./lib/trace.bash

function nest {
  [ $1 -gt 0 ] \
      && nest $(( $1 - 1 )) \
      || _trace
  return 0
}

{
  failme
  true
}

(
  failme
  true
)

nest 9

false

failure
