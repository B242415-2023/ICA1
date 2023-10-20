#!/bin/bash

#1. Mean the replicates for each condition

touch ./temp/replicateindex.txt
awk '{FS="\t";}{if(NR!=1){print $2,$4,$5}}' ./seqdata/Tco2.fqfiles | 
sort - | 
uniq - > ./temp/replicateindex.txt

replicatewc=$(wc -l ./temp/replicateindex.txt| awk 'BEGIN{FS=" ";}{print $1}')
for number in {1..${replicatewc}};
do
clone=$(awk 'BEGIN{FS="\t";}{if(NR == $number){print $1}}' ./seqdata/Tco2.fqfiles)
time=$(awk 'BEGIN{FS="\t";}{if(NR == $number){print $2}}' ./seqdata/Tco2.fqfiles)
state=$(awk 'BEGIN{FS="\t";}{if(NR == $number){print $3}}' ./seqdata/Tco2.fqfiles)

echo ${clone},${time},${state}
done

for number in {1..}

> ./temp/replicateindex.txt



#1. USER DEFINED GROUP SELECTIONS




#2. GENERAL METHOD FOR CALCULATING MEANS OF COUNTS PER GENE OF GROUP DEFINED IN 1. 


#3. CALCULATING VARIATION FOR REPLICATES
##3a. Gather number of replicates 
#search for same clone and treatment, then take range for all replicates 


