#!/usr/local/bin/bash

space="\x1b[1C"
declare -a txtList

while IFS= read -r line; do
  txtList+=("${line}") 
done <"text.txt"

mapfile -t list < <(ls "images")
# https://github-wiki-see.page/m/koalaman/shellcheck/wiki/SC2207

cleanup () {
  tput reset && echo "quit" && exit 0
}

random256 () {
  echo $(( RANDOM % 256 + 1 ))
}

randomImg () {
  selection=${list[$RANDOM % ${#list[@]} ]}
  echo "images/${selection}"
}

randomTxt () {
  selection=${txtList[$RANDOM % ${#txtList[@]} ]}
  echo "${selection}"
}

export space
export list
export txtList
