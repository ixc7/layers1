#!/usr/local/bin/bash

# shellcheck disable=SC1091
source "./utils.sh"

trap cleanup EXIT SIGINT

lineCount () {
  wc -l "${1}" | cut -d ' ' -f 1
}

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

export space="\x1b[1C"

imgFile=$(mktemp)
txtFile=$(mktemp)

declare -a txtList

while IFS= read -r line; do
  txtList+=("${line}") 
done <text.txt

####

while true; do

  figlet -f elite -w $(( $(( $(tput cols) / 3 )) * 2 )) "$(randomTxt)" > "${txtFile}"
  python3 vendor/img2braille.py "$(randomImg)" > "${imgFile}"

  # TODO random/manual position
  # TODO make functions remove duplicate code

  # 1
  imgWidth=$(head -n 1 "${imgFile}")
  imgHeight=$(lineCount "${imgFile}")
  imgXMargin=$(($(($(tput cols) - ${#imgWidth})) / 2))
  imgYMargin=$(getYMargin "${imgHeight}")
  imgXSpace=$(printXMargin ${imgXMargin})

  # 1
  txtWidth=$(head -n 1 "${txtFile}")
  txtHeight=$(lineCount "${txtFile}")
  txtXMargin=$(($(($(tput cols) - ${#txtWidth})) / 2))
  txtYMargin=$(getYMargin "${txtHeight}")
  txtXSpace=$(printXMargin ${txtXMargin})

  # 2 (render img)
  echo -ne "\x1Bc\x1b[3J\x1b[?25l\x1b[38;5;$(random256)m\x1b[1m\x1b[1;1H"
  printYMargin "${imgYMargin}"
  while IFS= read -r line; do
    printSpace "${imgXSpace}${line}"
    # echo -e "${imgXSpace}${line}" | sed "s/ /${space}/g"
  done <"${imgFile}" | tail -n $(( $(tput lines) - 5 ))
  tput cup 0 0

  # 2 (render txt)
  echo -ne "\x1b[38;5;$(random256)m\x1b[1m"
  printYMargin "${txtYMargin}"
  while IFS= read -r line; do
  printSpace "${txtXSpace}${line}"
  done <"${txtFile}" | tail -n $(( $(tput lines) - 5 ))

  prompt="press <ANY KEY> to generate another image"
  promptXMargin=$(getXMargin "${prompt}")
  promptXSpace=$(printXMargin "${promptXMargin}")
  formattedPrompt=$(printSpace "${promptXSpace}${prompt}")

  quit="press <q> to quit"
  quitXMargin=$(( $(( $(tput cols) - ${#quit} )) / 2 ))
  quitXSpace=$(printXMargin ${quitXMargin})

  [[ ${imgYMargin} -lt 1 ]] && 
    quitPos=$(( imgHeight + 1 )) ||
    quitPos=$(( imgHeight + imgYMargin + 1 ))

  (
    [[ ${quitPos} -ge $(( $(tput lines) - 2 )) ]] &&
    tput cup $(( $(tput lines) - 2 )) 0 
  ) || 
  tput cup $(( imgHeight + imgYMargin + 1 )) 0

  echo -e "${quitXSpace}${quit}"

  (
    [[ ${imgYMargin} -gt 2 ]] &&
    tput cup $(( imgYMargin - 2 )) 0
  ) ||
  tput cup 0 0
  
  read -p "${formattedPrompt}" -rn1 key
  if [[ ${key} == "q" ]]; then exit 0; fi

  # echo -e "${formattedPrompt}"
  # sleep 0.9
done
