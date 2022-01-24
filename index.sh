#!/usr/local/bin/bash

source "./utils.sh"
source "./spacing.sh"

promptTxt="press <ANY KEY> to generate another image"
quitTxt="press <q> to quit"
imgFile=$(mktemp)
txtFile=$(mktemp)

trap cleanup EXIT SIGINT

while true; do
  clearScreen
  maxHeight=$(setMaxHeight)

  # render random image + text  
  randomTxt "${txtFile}"
  randomImg "${imgFile}"
  defineMargins "img" "${imgFile}"
  defineMargins "txt" "${txtFile}"
  render "${imgFile}" "${imgYMargin}" "${imgXSpace}" "${maxHeight}"
  render "${txtFile}" "${txtYMargin}" "${txtXSpace}" "${maxHeight}"

  # get positions for 'keypress' and 'quit' prompts
  promptXMargin=$(getXMargin "${promptTxt}")
  promptXSpace=$(printXMargin "${promptXMargin}")
  quitXMargin=$(( $(( $(tput cols) - ${#quitTxt} )) / 2 ))
  quitXSpace=$(printXMargin ${quitXMargin})

  # position 'quit' text 2 lines below the image
  # if image takes up entire screen height, position 1 line below image
  [[ ${imgYMargin} -le 2 ]] && 
    quitPos=$(( imgHeight + 1 )) ||
    quitPos=$(( imgHeight + imgYMargin + 1 ))
    
  # if position is below the screen, position at bottom
  [[ ${quitPos} -ge $(( $(tput lines) - 2 )) ]] && 
    qcursorPos=$(($(tput lines) - 1)) ||
    qcursorPos=$((imgHeight + imgYMargin + 2))

  # render 'quit' text
  cursorTo ${qcursorPos} 0
  echo -ne "${quitXSpace}${quitTxt}"

  # position 'keypress' prompt 2 lines above the image
  # if image takes up entire screen height, position at top
  [[ ${imgYMargin} -ge 2 ]] &&
    pcursorPos=$((imgYMargin - 1)) || 
    pcursorPos=0

  # escape whitespace, render 'keypress' prompt, break if 'q'
  cursorTo ${pcursorPos} 0
  formattedPrompt=$(printSpace "${promptXSpace}${promptTxt}")
  read -p "${formattedPrompt}" -rn1 key
  if [[ ${key} == "q" ]]; then exit 0; fi
done
