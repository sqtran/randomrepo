#!/bin/bash

#Queries github using the github search API and starts downloading random repos that are greater than 10mbs


#random character to search github on
q=`expr substr $(cat /dev/urandom | tr  -dc 'a-zA-Z' | fold -w 32 | head -n 1) 1 1`i
curl -G https://api.github.com/search/repositories       \
    --data-urlencode "q=${q}" \
    --data-urlencode "size>10000"                          \
    --data-urlencode "order=desc"                          \
    -H "Accept: application/vnd.github.preview"      \
| grep clone_url | sed 's/\(  \)\+//g' | cut -d ' ' -f 2 | sed 's/,//g'  \
| while read w; do 
url=$(echo $w | sed 's/"//g'); 
name=$(echo $w | cut -d '/' -f 4)_$(echo $w | sed 's/,//g'| sed 's/"//g' | cut -d '/' -f 5);
git clone $url $name;
echo git clone $url $name >> repos;
done
