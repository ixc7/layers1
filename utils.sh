#!/usr/local/bin/bash

imgSrc="./images"
txtSrc="text.txt"
font="Elite"

mapfile -t imgList < <(ls -1 "${imgSrc}")
mapfile -t txtList < <(echo -e "$(cat "${txtSrc}")")
# https://github-wiki-see.page/m/koalaman/shellcheck/wiki/SC2207

clearScreen () {
  echo -ne "\x1Bc\x1b[3J\x1b[?25l"
}

cursorTo () {
  echo -ne "\x1b[${1};${2}H"
}

lineCount () {
  wc -l "${1}" | cut -d ' ' -f 1
}

cleanup () {
  tput reset && echo "quit" && exit 0
}

random256 () {
  echo $(( RANDOM % 256 + 1 ))
}

setRandomColor () {
  echo -ne "\x1b[38;5;$(random256)m\x1b[1m\x1b[0;0H"
}

setMaxHeight () {
  echo -ne $(( $(tput lines) - 5 ))
}

randomTxt () {
  getRandomStr () {
    str=${txtList[$RANDOM % ${#txtList[@]} ]}
    echo "${str}"
  }
  
  figlet -f "${font}" -w $(( $(( $(tput cols) / 3 )) * 2 )) "$(getRandomStr)" > "${1}"
}

randomImg () {
  getRandomFile () {
    selection=${imgList[$RANDOM % ${#imgList[@]} ]}
    echo "${imgSrc}/${selection}"
  }
  python3 vendor/img2braille.py "$(getRandomFile)" > "${1}"
  
}

