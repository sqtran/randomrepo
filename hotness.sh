#!/bin/bash

# Queries github using the github search API and starts downloading random repos that are greater than 10MBs.

# Generates a random letter [a-zA-z]
generate_random_letter() {
  lower_or_upper=$(($RANDOM%2))
  base=65
  if [ "$lower_or_upper" -eq 1 ]
  then
    base=97
  fi
  random=$(( ( RANDOM % 25 )  + $base ))
  printf \\$(printf '%03o' $random)
}

# Will generate an array of random github urls.
#   Uses `generate_random_letter` function
generate_urls() {
  random_letter=`generate_random_letter`
  repos=`curl -G https://api.github.com/search/repositories       \
      --data-urlencode "q=$random_letter" \
      --data-urlencode "size>10000"                          \
      --data-urlencode "order=desc"                          \
      -H "Accept: application/vnd.github.preview"      \
  | grep clone_url | sed 's/\(  \)\+//g'`

  repo_array="(${repos// /})"
  for i in "${!repo_array[@]}"
  do
    echo "${repo_array[i]}" | sed "s/\"clone_url\":\"//g" | sed "s/\.git\"/.git/g" | sed "s/,/ /g" | sed "s/[\(\)]/ /g"
  done
}

# Will checkout a git repo into the repos directory.  Assuming this dir exists.
#   arg0: git repo
checkout() {
  (
    cd repos
    `git clone $1`
  )
}

# Will create a repos dir if it doesn't exist and then checkout random github projects.
#   Uses `generate_urls` and `checkout` functions.
main() {
  mkdir repos 2> /dev/null
  repo_array=(`generate_urls`)
  for i in "${!repo_array[@]}"
  do
    checkout "${repo_array[i]}"
  done
}

main
