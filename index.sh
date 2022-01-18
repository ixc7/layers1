#!/usr/local/bin/bash

# don't judge.

trap cleanup EXIT SIGINT

cleanup () {
  tput reset && echo "quit" && exit 0
}

random256 () {
  echo $(( $RANDOM % 256 + 1 ))
}

declare -a list=($(ls "images"))
declare -a txtList

randomImg () {
  selection=${list[$RANDOM % ${#list[@]} ]}
  echo "images/${selection}"
}

randomTxt () {
  selection=${txtList[$RANDOM % ${#txtList[@]} ]}
  echo "${selection}"
}

imgFile=$(mktemp)
txtFile=$(mktemp)
space="\x1b[1C"
input="${@}"
[[ -z "${@}" ]] && input="image.png"

while IFS= read -r line; do
  txtList+=("${line}") 
done <"text.txt"

while true; do

# figlet -f elite "it works" > "${txtFile}"
figlet -f elite "$(randomTxt)" > "${txtFile}"
python3 vendor/img2braille.py "$(randomImg)" > "${imgFile}"

imgWidth=$(head -n 1 "${imgFile}")
imgHeight=$(wc -l "${imgFile}" | cut -d ' ' -f 1)
imgXMargin=$(($(($(tput cols) - ${#imgWidth})) / 2))
imgYMargin=$(( $(( $(tput lines) - ${imgHeight} )) / 2 ))
imgXSpace=$(for i in $(seq ${imgXMargin}); do printf "${space}"; done)

txtWidth=$(head -n 1 "${txtFile}")
txtHeight=$(wc -l "${txtFile}" | cut -d ' ' -f 1)
txtXMargin=$(($(($(tput cols) - ${#txtWidth})) / 2))
txtYMargin=$(( $(( $(tput lines) - ${txtHeight} )) / 2 ))
txtXSpace=$(for i in $(seq ${txtXMargin}); do printf "${space}"; done)

echo -ne "\x1Bc\x1b[3J\x1b[?25l\x1b[38;5;$(random256)m\x1b[1m\x1b[1;1H"

for i in $(seq ${imgYMargin}); do echo; done
while IFS= read -r line; do
  echo -e "${imgXSpace}${line}" | sed "s/ /${space}/g"
done <${imgFile} | tail -n $(( $(tput lines) - 5 ))
tput cup 0 0

echo -ne "\x1b[38;5;$(random256)m\x1b[1m"
for i in $(seq ${txtYMargin}); do echo; done
while IFS= read -r line; do
 echo -e "${txtXSpace}${line}" | sed "s/ /${space}/g"
done <${txtFile} | tail -n $(( $(tput lines) - 5 ))

prompt="press <ANY KEY> to generate another image"
promptXMargin=$(( $(( $(tput cols) - ${#prompt} )) / 2 ))
promptXSpace=$(for i in $(seq ${promptXMargin}); do printf "${space}"; done)
formattedPrompt=$(echo -e "${promptXSpace}${prompt}" | sed "s/ /${space}/g")

quitTxt="press <q> to quit"
quitXMargin=$(( $(( $(tput cols) - ${#quitTxt} )) / 2 ))
quitXSpace=$(for i in $(seq ${quitXMargin}); do printf "${space}"; done)

if [[ ${imgYMargin} -lt 1 ]]; then
  quitPos=$(( ${imgHeight} + 1 ))
else
  quitPos=$(( ${imgHeight} + ${imgYMargin} + 1 ))
fi

if [[ ${quitPos} -ge $(( $(tput lines) - 2 )) ]]; then
  tput cup $(( $(tput lines) - 2 )) 0
else
  tput cup $(( ${imgHeight} + ${imgYMargin} + 1 )) 0
fi
echo -e "${quitXSpace}${quitTxt}"

if [[ ${imgYMargin} -gt 2 ]]; then
  tput cup $(( ${imgYMargin} - 2 )) 0
else
  tput cup 0 0
fi
read -p "${formattedPrompt}" -n1 key

if [[ ${key} == "q" ]]; then exit 0; fi

done
