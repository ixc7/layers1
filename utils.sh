#!/usr/local/bin/bash

imgSrc="./images"
txtSrc="text.txt"
font="Elite"

mapfile -t imgList < <(ls -1 "${imgSrc}")
mapfile -t txtList < <(echo -e "$(cat "${txtSrc}")")
# https://github-wiki-see.page/m/koalaman/shellcheck/wiki/SC2207

lineCount () {
  wc -l "${1}" | cut -d ' ' -f 1
}

cleanup () {
  tput reset && echo "quit" && exit 0
}

random256 () {
  echo $(( RANDOM % 256 + 1 ))
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
