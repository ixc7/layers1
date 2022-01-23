#!/usr/local/bin/bash

lineCount () {
  wc -l "${1}" | cut -d ' ' -f 1
}

mapfile -t list < <(ls -1 "images")
mapfile -t txtList < <(echo -e "$(cat "text.txt")")
# can you do w/ mapfile -t ${1} < <(ls "${2}")
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
