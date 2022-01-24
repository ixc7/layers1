#!/usr/local/bin/bash

space="\x1b[1C"

getXMargin () {
  echo -ne "$(($(($(tput cols) - ${#1})) / 2))"
}

printXMargin () {
  for i in $(seq "${1}"); do echo -n "${space}"; done
}

getYMargin () {
  echo -ne "$(( $(($(tput lines) - ${1})) / 2 ))"
}

printYMargin () {
  for i in $(seq "${1}"); do echo ; done
}

printSpace () {
  echo -e "${1}" | sed "s/ /${space}/g"
}

defineMargins () {
  prefix="${1}"
  height="$(lineCount "${2}")"
  width="$(head -n 1 "${2}")"
  xMargin=$(($(($(tput cols) - ${#width})) / 2))
  export declare "${prefix}"Width="${width}"
  export declare "${prefix}"Height="${height}"
  export declare "${prefix}"XMargin="${xMargin}"
  export declare "${prefix}"YMargin="$(getYMargin "${height}")"
  export declare "${prefix}"XSpace="$(printXMargin "${xMargin}")"
}
