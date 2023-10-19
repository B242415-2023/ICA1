#!/bin/bash

#1. USER DEFINED GROUP SELECTIONS




#2. GENERAL METHOD FOR CALCULATING MEANS OF COUNTS PER GENE OF GROUP DEFINED IN 1. 


#3. CALCULATING VARIATION FOR REPLICATES
##3a. Gather number of replicates 
#search for same clone and treatment, then take range for all replicates 


while read 
do

while read gene 
do
grep -n gene 

done < ./refseqdata/TriTrypDB-46_TcongolenseIL3000_2019.bed

done < 