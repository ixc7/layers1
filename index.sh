#!/usr/local/bin/bash

# shellcheck disable=SC1091
source "./utils.sh"

trap cleanup EXIT SIGINT

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
  imgHeight=$(wc -l "${imgFile}" | cut -d ' ' -f 1)
  imgXMargin=$(($(($(tput cols) - ${#imgWidth})) / 2))
  imgYMargin=$(( $(( $(tput lines) - imgHeight )) / 2 ))
  imgXSpace=$(for i in $(seq ${imgXMargin}); do echo -n "${space}"; done)

  # 1
  txtWidth=$(head -n 1 "${txtFile}")
  txtHeight=$(wc -l "${txtFile}" | cut -d ' ' -f 1)
  txtXMargin=$(($(($(tput cols) - ${#txtWidth})) / 2))
  txtYMargin=$(( $(($(tput lines) - txtHeight)) / 2 ))
  txtXSpace=$(for i in $(seq ${txtXMargin}); do echo -n "${space}"; done)

  # 2 (render img)
  echo -ne "\x1Bc\x1b[3J\x1b[?25l\x1b[38;5;$(random256)m\x1b[1m\x1b[1;1H"
  for i in $(seq ${imgYMargin}); do echo; done
  while IFS= read -r line; do
    echo -e "${imgXSpace}${line}" | sed "s/ /${space}/g"
  done <${imgFile} | tail -n $(( $(tput lines) - 5 ))
  tput cup 0 0

  # 2 (render txt)
  echo -ne "\x1b[38;5;$(random256)m\x1b[1m"
  for i in $(seq ${txtYMargin}); do echo; done
  while IFS= read -r line; do
   echo -e "${txtXSpace}${line}" | sed "s/ /${space}/g"
  done <${txtFile} | tail -n $(( $(tput lines) - 5 ))

  # 3 (prompt 1)
  prompt="press <ANY KEY> to generate another image"
  promptXMargin=$(( $(( $(tput cols) - ${#prompt} )) / 2 ))
  promptXSpace=$(for i in $(seq ${promptXMargin}); do echo -n "${space}"; done)
  formattedPrompt=$(echo -e "${promptXSpace}${prompt}" | sed "s/ /${space}/g")

  # 3 (prompt 2)
  quitTxt="press <q> to quit"
  quitXMargin=$(( $(( $(tput cols) - ${#quitTxt} )) / 2 ))
  quitXSpace=$(for i in $(seq ${quitXMargin}); do echo -n "${space}"; done)
  # quitXSpace=(seq 0 "${quitXMargin}") echo -n "${space}"

  # 4
  if [[ ${imgYMargin} -lt 1 ]]; then
    quitPos=$(( imgHeight + 1 ))
  else
    quitPos=$(( imgHeight + imgYMargin + 1 ))
  fi

  # 4
  if [[ ${quitPos} -ge $(( $(tput lines) - 2 )) ]]; then
    tput cup $(( $(tput lines) - 2 )) 0
  else
    tput cup $(( imgHeight + imgYMargin + 1 )) 0
  fi
  echo -e "${quitXSpace}${quitTxt}"

  # 4
  if [[ ${imgYMargin} -gt 2 ]]; then
    tput cup $(( imgYMargin - 2 )) 0
  else
    tput cup 0 0
  fi

  # auto
  # echo -e "${formattedPrompt}"
  # sleep 0.9
  
  # manual
  read -p "${formattedPrompt}" -rn1 key
  if [[ ${key} == "q" ]]; then exit 0; fi
done
