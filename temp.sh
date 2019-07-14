#!/usr/bin/env bash

set -eE  # same as: `set -o errexit -o errtrace`
trap 'echo BOO!' ERR 

function func(){
  ls /root/
}

# Thanks to -E / -o errtrace, this still triggers the trap, 
# even though the failure occurs *inside the function*.
func 
