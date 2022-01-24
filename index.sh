#!/usr/local/bin/bash

source "./utils.sh"
source "./spacing.sh"

trap cleanup EXIT SIGINT

###################
#### constants ####
###################

promptTxt="press <ANY KEY> to generate another image"
quitTxt="press <q> to quit"
imgFile=$(mktemp)
txtFile=$(mktemp)

while true; do

  ###############
  #### setup ####
  ###############

  clearScreen
  maxHeight=$(setMaxHeight)
  
  randomTxt "${txtFile}"
  randomImg "${imgFile}"
  defineMargins "img" "${imgFile}"
  defineMargins "txt" "${txtFile}"
  
  # get positions for 'keypress' and 'quit' prompts
  # use defineMargins?
  promptXMargin=$(getXMargin "${promptTxt}")
  promptXSpace=$(printXMargin "${promptXMargin}")
  quitXMargin=$(( $(( $(tput cols) - ${#quitTxt} )) / 2 ))
  quitXSpace=$(printXMargin ${quitXMargin})
  
  # replace 'keypress' prompt whitespace w/ esc chars
  formattedPrompt=$(printSpace "${promptXSpace}${promptTxt}")


  #############################
  #### render image + text ####
  #############################
  
  render "${imgFile}" "${imgYMargin}" "${imgXSpace}" "${maxHeight}"
  render "${txtFile}" "${txtYMargin}" "${txtXSpace}" "${maxHeight}"


  ########################
  #### render prompts ####
  ########################

  # place 'quit' prompt 1 line below the image
  [[ ${imgYMargin} -le 1 ]] && 
    # if image takes up entire screen height
    quitPos=$(( imgHeight + 1 )) ||
    # else, if image can be centered on screen
    quitPos=$(( imgHeight + imgYMargin + 1 ))

  (
    # if quit position is below the screen, move up 1 line
    [[ ${quitPos} -ge $(( $(tput lines) - 2 )) ]] &&
    cursorTo $(($(tput lines) - 1)) 0
  ) || 
  # else, position normally
  # cursorTo $((imgHeight + imgYMargin + 1)) 0
  cursorTo $((imgHeight + imgYMargin + 2)) 0
  echo -e "${quitXSpace}${quitTxt}"

  # place 'keypress' prompt directly above the image
  # if image can be centered on screen, cursor to (2 lines above image)
  (
    [[ ${imgYMargin} -ge 2 ]] &&
    cursorTo $((imgYMargin - 1)) 0
  ) ||
  # else, if image takes up entire screen height, cursor to (0, 0)
  cursorTo 0 0
  read -p "${formattedPrompt}" -rn1 key


  ########################
  #### get user input ####
  ########################
  
  # read keypresses, break if key == 'q'
  if [[ ${key} == "q" ]]; then exit 0; fi
done
