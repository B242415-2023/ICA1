#!/bin/bash

#1. IMPORT SEQ DATA INTO tempfiles DIRECTORY
####Make a check for if there are files aready in tempdata or files in directory?
mkdir seqdata
cp -u /localdisk/data/BPSM/ICA1/fastq/* ./seqdata
awk 'BEGIN{FS="\t";}{print $1,$2,$3,$4,$5}' ./seqdata/Tco2.fqfiles > report.txt



#2. PERFORM fastqc QUALITY CHECK ON COMPRESSED fastq PAIRED END RAW SEQUENCE DATA 
#2a. Gather end1 and end2 column data (lists available fastq files) from Tco2.fqfiles to fastqlist.txt
touch ./temp/fastqlist_end1.txt
awk 'BEGIN{FS="\t";}{if($6 != "End1"){print $6}}' ./seqdata/Tco2.fqfiles | cut -d "." -f 1 > ./temp/fastqlist_end1.txt
touch ./temp/fastqlist_end2.txt
awk 'BEGIN{FS="\t";}{if($7 != "End2"){print $7}}' ./seqdata/Tco2.fqfiles | cut -d "." -f 1 > ./temp/fastqlist_end2.txt
#2b. end 1 fastqc on all files in fastqlist.txt, then count number of pass/fail/warn, then counts to results
mkdir fastqcreport
mkdir temp
echo "end1_fastqc_pass" > ./temp/end1_pass.txt
echo "end1_fastqc_fail" > ./temp/end1_fail.txt
echo "end1_fastqc_warn" > ./temp/end1_warn.txt

while read line
do
fastqc -o ./fastqcreport --extract ./seqdata/${line}.fq.gz
awk 'BEGIN{FS="\t";}{if($1 == "PASS"){print $1}}' ./fastqcreport/${line}_fastqc/summary.txt | wc -l >> ./temp/end1_pass.txt
awk 'BEGIN{FS="\t";}{if($1 == "FAIL"){print $1}}' ./fastqcreport/${line}_fastqc/summary.txt | wc -l >> ./temp/end1_fail.txt
awk 'BEGIN{FS="\t";}{if($1 == "WARN"){print $1}}' ./fastqcreport/${line}_fastqc/summary.txt | wc -l >> ./temp/end1_warn.txt
done < ./temp/fastqlist_end1.txt
#2c. same as 2b. but with end2
echo "end2_fastqc_pass" > ./temp/end2_pass.txt
echo "end2_fastqc_fail" > ./temp/end2_fail.txt
echo "end2_fastqc_warn" > ./temp/end2_warn.txt

while read line
do
fastqc -o ./fastqcreport --extract ./seqdata/${line}.fq.gz
awk 'BEGIN{FS="\t";}{if($1 == "PASS"){print $1}}' ./fastqcreport/${line}_fastqc/summary.txt | wc -l >> ./temp/end2_pass.txt
awk 'BEGIN{FS="\t";}{if($1 == "FAIL"){print $1}}' ./fastqcreport/${line}_fastqc/summary.txt | wc -l >> ./temp/end2_fail.txt
awk 'BEGIN{FS="\t";}{if($1 == "WARN"){print $1}}' ./fastqcreport/${line}_fastqc/summary.txt | wc -l >> ./temp/end2_warn.txt
done < ./temp/fastqlist_end2.txt
#2d. append all counts onto report6.txt
paste ./report.txt ./temp/end1_pass.txt | paste - ./temp/end1_fail.txt | paste - ./temp/end1_warn.txt |paste - ./temp/end2_pass.txt |paste - ./temp/end2_fail.txt |paste - ./temp/end2_warn.txt > ./temp/reportfinal.txt
cp ./temp/reportfinal.txt ./report.txt

#3. IMPORT T.congo GENOME SEQ INTO refseqdatam
mkdir refseqdata
cp -u /localdisk/data/BPSM/ICA1/Tcongo_genome/* ./refseqdata/



#4. ALIGN READ PAIRS ONTO REFERENCE GENOME















