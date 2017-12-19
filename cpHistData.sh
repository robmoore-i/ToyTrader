#!/bin/bash

if [[ $# -lt 2 ]]
then
  echo "Usage: ./cpHistData currencyPair dirOfZips"
  exit 1
fi

currencyPair=$1
downloadDir=$2

for histdatazip in $(ls $downloadDir | grep $currencyPair)
do
  cp "$downloadDir/$histdatazip" .
done

for histdatazip in $(ls *.zip | grep $currencyPair)
do
  unzip $histdatazip
done

rm *.txt
rm *.zip

for histdatacsv in $(ls *.csv | grep $currencyPair)
do
  mv $histdatacsv "${currencyPair}_${histdatacsv:20}"
done

exit 0
