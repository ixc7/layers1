#!/usr/local/bin/bash

# shellcheck disable=SC1091
# shellcheck disable=SC2154

source "./utils.sh"
source "./spacing.sh"

trap cleanup EXIT SIGINT

prompt="press <ANY KEY> to generate another image"ß
quitPrompt="press <q> to quit"

imgFile=$(mktemp)
txtFile=$(mktemp)

####

# render a new image + title + prompt(s) on every keypress, forever.
while true; do

  # TODO random/manual/non-centered position
  # get random text/image selection + position (centered)
  randomTxt "${txtFile}"
  randomImg "${imgFile}"
  defineMargins "img" "${imgFile}"
  defineMargins "txt" "${txtFile}"
  
  # clear/ reset screen + hide cursor
  echo -ne "\x1Bc\x1b[3J\x1b[?25l"
  
  # 1) set image to random color + bold + cursor to (0, 0)
  echo -ne "\x1b[38;5;$(random256)m\x1b[1m\x1b[0;0H"
  
  # 1) render image
  printYMargin "${imgYMargin}"
  while IFS= read -r line; do
    printSpace "${imgXSpace}${line}"
  done <"${imgFile}" |
  
  # 1) tail -n limits maximum height of image
  tail -n $(( $(tput lines) - 5 ))

  # 2) set text to random color + bold + cursor to (0, 0)
  echo -ne "\x1b[38;5;$(random256)m\x1b[1m\x1b[0;0H"

  # 2) render text
  printYMargin "${txtYMargin}"
  while IFS= read -r line; do
  printSpace "${txtXSpace}${line}"
  done <"${txtFile}" |
  
  # 2) tail -n, but for text. not really needed rn...
  tail -n $(( $(tput lines) - 5 ))

  # get positions for/ format 'keypress' prompt
  promptXMargin=$(getXMargin "${prompt}")
  promptXSpace=$(printXMargin "${promptXMargin}")
  formattedPrompt=$(printSpace "${promptXSpace}${prompt}")

  # get positions for 'quit' prompt
  quitXMargin=$(( $(( $(tput cols) - ${#quitPrompt} )) / 2 ))
  quitXSpace=$(printXMargin ${quitXMargin})

  # place 'quit' prompt 1 line below the image
  [[ ${imgYMargin} -le 1 ]] && 
    # if image takes up entire screen height
    quitPos=$(( imgHeight + 1 )) ||
    # else, if image can be centered on screen
    quitPos=$(( imgHeight + imgYMargin + 1 ))

  (
    [[ ${quitPos} -ge $(( $(tput lines) - 2 )) ]] &&
    echo -e "\x1b[$(($(tput lines) - 3));0H"
  ) || 
  echo -e "\x1b[$((imgHeight + imgYMargin + 1));0H" 
  echo -e "${quitXSpace}${quitPrompt}"

  # place 'keypress' prompt directly above the image
  # if image can be centered on screen, cursor to (2 lines above image)
  (
    [[ ${imgYMargin} -ge 2 ]] &&
    echo -e "\x1b[$((imgYMargin - 2));0H"
  ) ||
  # else, if image takes up entire screen height, cursor to (0, 0)
  echo -ne "\x1b[0;0H"

  # (read keypresses)
  # TODO read once then close
  read -p "${formattedPrompt}" -rn1 key
  if [[ ${key} == "q" ]]; then exit 0; fi
done
