#!/bin/bash

if [[ $# -lt 1 ]]
then
  echo "Pass a currency pair"
  exit 1
fi

currencyPair=$1

cp ~/Downloads/* .

for histdatazip in $(ls *.zip)
do
  unzip $histdatazip
done

rm *.txt
rm *.zip

for histdatacsv in $(ls *.csv)
do
  mv $histdatacsv "${currencyPair}_${histdatacsv:20}"
done

exit 0
