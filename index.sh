#!/usr/local/bin/bash

# shellcheck disable=SC1091
source "./utils.sh"
source "./spacing.sh"

trap cleanup EXIT SIGINT

prompt="press <ANY KEY> to generate another image"ß
imgFile=$(mktemp)
txtFile=$(mktemp)

####

while true; do

  # TODO random/manual positions
  randomTxt "${txtFile}"
  randomImg "${imgFile}"
  defineMargins "img" "${imgFile}"
  defineMargins "txt" "${txtFile}"

  # 2 (render img)
  echo -ne "\x1Bc\x1b[3J\x1b[?25l\x1b[38;5;$(random256)m\x1b[1m\x1b[0;0H"
  printYMargin "${imgYMargin}"
  while IFS= read -r line; do
    printSpace "${imgXSpace}${line}"
  done <"${imgFile}" | tail -n $(( $(tput lines) - 5 ))
  echo -ne "\x1b[0;0H"

  # 2 (render txt)
  echo -ne "\x1b[38;5;$(random256)m\x1b[1m"
  printYMargin "${txtYMargin}"
  while IFS= read -r line; do
  printSpace "${txtXSpace}${line}"
  done <"${txtFile}" | tail -n $(( $(tput lines) - 5 ))

  promptXMargin=$(getXMargin "${prompt}")
  promptXSpace=$(printXMargin "${promptXMargin}")
  formattedPrompt=$(printSpace "${promptXSpace}${prompt}")

  quit="press <q> to quit"
  quitXMargin=$(( $(( $(tput cols) - ${#quit} )) / 2 ))
  quitXSpace=$(printXMargin ${quitXMargin})

  [[ ${imgYMargin} -le 1 ]] && 
    quitPos=$(( imgHeight + 1 )) ||
    quitPos=$(( imgHeight + imgYMargin + 1 ))

  (
    [[ ${quitPos} -ge $(( $(tput lines) - 2 )) ]] &&
    echo -e "\x1b[$(($(tput lines) - 3));0H"
  ) || 
  echo -e "\x1b[$((imgHeight + imgYMargin + 1));0H" 
  echo -e "${quitXSpace}${quit}"

  (
    [[ ${imgYMargin} -ge 2 ]] &&
    echo -e "\x1b[$((imgYMargin - 2));0H"
  ) ||
  echo -ne "\x1b[0;0H"
  
  read -p "${formattedPrompt}" -rn1 key
  if [[ ${key} == "q" ]]; then exit 0; fi

  # echo -e "${formattedPrompt}"
  # sleep 0.9
done
