#!/usr/local/bin/bash

source "./utils.sh"
source "./spacing.sh"

trap cleanup EXIT SIGINT

promptTxt="press <ANY KEY> to generate another image"
quitTxt="press <q> to quit"
imgFile=$(mktemp)
txtFile=$(mktemp)
maxHeight=$(setMaxHeight)

while true; do
  clearScreen
  
  # define + render random image/text  
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
  # if image takes up entire screen, position at bottom
  [[ ${imgYMargin} -le 2 ]] && 
    qcursorPos=$(($(tput lines) - 1)) ||
    qcursorPos=$((imgHeight + imgYMargin + 2))

  # render 'quit' text
  cursorTo ${qcursorPos} 0
  echo -ne "${quitXSpace}${quitTxt}"

  # position 'keypress' prompt 2 lines above the image
  # if image takes up entire screen, position at top
  [[ ${imgYMargin} -ge 2 ]] &&
    pcursorPos=$((imgYMargin - 1)) || 
    pcursorPos=0

  # escape whitespace (remove later)
  formattedPrompt=$(printSpace "${promptXSpace}${promptTxt}")
  
  # render 'keypress' prompt
  cursorTo ${pcursorPos} 0
  read -p "${formattedPrompt}" -rn1 key

  # wait for 'q' to break loop and exit
  if [[ ${key} == "q" ]]; then exit 0; fi
done
