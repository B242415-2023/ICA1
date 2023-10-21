#!/bin/bash

#1. Mean the replicates for each condition
##1a. create list of all unique conditions
touch ./temp/replicateindex.txt
awk 'BEGIN{FS="\t"; OFS="\t"}{if(NR!=1){print $2,$4,$5}}' ./seqdata/Tco2.fqfiles | 
sort - | 
uniq - > ./temp/replicateindex.txt
##1b. create reference index
touch ./temp/replicateindexref.txt
awk 'BEGIN{FS="\t";}{if(NR!=1){print $1,$2,$4,$5}}' ./seqdata/Tco2.fqfiles > ./temp/replicateindexref.txt
##1c. separate search into 3 files for each condition
awk 'BEGIN{FS="\t";}{print $1;}' ./temp/replicateindex.txt | sort - | uniq - > ./temp/search1.txt
awk 'BEGIN{FS="\t";}{print $2;}' ./temp/replicateindex.txt | sort - | uniq - > ./temp/search2.txt
awk 'BEGIN{FS="\t";}{print $3;}' ./temp/replicateindex.txt | sort - | uniq - > ./temp/search3.txt
##1d. group replicates together
mkdir ./temp/search
while read search1
do
grep -w ${search1} ./temp/replicateindexref.txt > ./temp/search1temp.txt

  while read search2
  do
  grep -w ${search2} ./temp/search1temp.txt > ./temp/search2temp.txt
  
    while read search3
    do
    grep -w ${search3} ./temp/search2temp.txt > ./temp/search/${search1}_${search2}_${search3}
    echo ${search1}_${search2}_${search3}
    done < ./temp/search3.txt
  done < ./temp/search2.txt
done < ./temp/search1.txt

##1e.gather only counts of each gene of each sample
ls ./temp/search > ./temp/searchdirindex.txt
mkdir ./counts/groups

while read file
do
cat ./temp/search/${file} | awk '{FS=" ";}{print $1}' - > ./temp/repgroups.txt

  while read repgroups
  do
  cat ./counts/${repgroups:0:3}-${repgroups:3}_counts.txt | awk '{FS="\t";}{if($6 != "hot"){print $6}}' - > ./counts/groups/${repgroups:0:3}-${repgroups:3}_counts_only.txt
  
  done < ./temp/repgroups.txt
done < ./temp/searchdirindex.txt
#1f. append counts of each condition to one file
mkdir ./counts/reptotal

while read file
do
cat ./temp/search/${file} | awk '{FS=" ";}{print $1}' - > ./temp/repgroups.txt
>./counts/reptotal/${file}_all.txt

  while read repgroups
  do
  paste ./counts/reptotal/${file}_all.txt ./counts/groups/${repgroups:0:3}-${repgroups:3}_counts_only.txt > ./counts/reptotal/${file}_all1.txt && mv -f ./counts/reptotal/${file}_all1.txt ./counts/reptotal/${file}_all.txt

  echo ./counts/${repgroups:0:3}-${repgroups:3}_counts.txt
  echo ${file}
  
  done < ./temp/repgroups.txt
done < ./temp/searchdirindex.txt






#1. USER DEFINED GROUP SELECTIONS




#2. GENERAL METHOD FOR CALCULATING MEANS OF COUNTS PER GENE OF GROUP DEFINED IN 1. 


#3. CALCULATING VARIATION FOR REPLICATES
##3a. Gather number of replicates 
#search for same clone and treatment, then take range for all replicates 


