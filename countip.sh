#!/usr/bin/bash

##
## Collects all the failed ssh login attempts from /var/log/auth.log
## and selects the ip addresses, sorts them, and counts the amount
## of times the ip tried to login to the ssh service
## 
## If you want to also collect the username the ip address tried to
## login with you can use the following awk command. Do note that
## the script need to be changed as some of the files will no longer
## follow the right format
## awk -F ' ' '{print $10" "$11}' sshlog.txt > sshlog_cleaned.txt
## 


## Out files

sshlog=/var/log/auth.log
grepoutput=grepoutput.txt
awkoutput=awkoutput.txt
sshlogcleaned=sshlog_cleaned.txt
uniqtemp=uniqtemp.txt
finaloutput=sshlog_result.txt

## Do some cleaning of older files
## leftovers if the script exited
## early etc
if [ -f "$grepoutput" ]; then
    rm $grepoutput
fi

if [ -f "$awkoutput" ]; then
  rm $awkoutput
fi

if [ -f "$sshlogcleaned" ]; then
    rm $sshlogcleaned
fi

if [ -f "$uniqtemp" ]; then
    rm $uniqtemp
fi

if [ -f "$sorttemp" ]; then
    rm $sorttemp
fi 

## If the final output file exist,
## name the current output with a
## higher number than before
if [ -f "$finaloutput" ]; then
    counter=1
    while [ -f "$finaloutput.$counter" ]; do
        counter=$((counter+1))
    done
    finaloutput=$finaloutput.$counter
fi

echo Start script

echo Fetching info from /var/log/auth.log

## Get the relevant lines from our auth.log
grep invalid $sshlog > $grepoutput
awk -F ' ' '{print $11}' $grepoutput > $awkoutput

## Count the ip addresses
while read p; do
    command=$(grep -o $p $awkoutput | wc -l)
    echo $p $command >> $sshlogcleaned
done <$awkoutput

## Sort the file, and get the uniq lines
sort $sshlogcleaned | uniq > $uniqtemp

## Sort again to get the highest number
## first then write the result to the
## final output file
sort -g -r -k2 $uniqtemp > $finaloutput
 
## Clean up temp files
rm $grepoutput
rm $awkoutput
rm $sshlogcleaned
rm $uniqtemp

## We're done, inform the user
echo "Script done. Output can be found in ${finaloutput}"

## Exit the program
exit 0



