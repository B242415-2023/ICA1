#!/bin/bash

#1. IMPORT SEQ DATA INTO tempfiles DIRECTORY
####Make a check for if there are files aready in tempdata or files in directory?
mkdir tempdata
cp /localdisk/data/BPSM/ICA1/fastq/* ./tempdata
awk 'BEGIN{FS="\t";}{print $1,$2,$3,$4,$5}' ./tempdata/Tco2.fqfiles > report.txt




#2. PERFORM fastqc QUALITY CHECK ON COMPRESSED fastq PAIRED END RAW SEQUENCE DATA 
#2a. Gather end1 and end2 column data (lists available fastq files) from Tco2.fqfiles to fastqlist.txt
awk 'BEGIN{FS="\t";}{if($6 != "End1"){print $6}}' ./tempdata/Tco2.fqfiles | cut -d "." -f 1 > ./temp/fastqlist_end1.txt
awk 'BEGIN{FS="\t";}{if($7 != "End1"){print $7}}' ./tempdata/Tco2.fqfiles | cut -d "." -f 1 > ./temp/fastqlist_end2.txt

#2b. end 1 fastqc on all files in fastqlist.txt, then count number of pass/fail/warn, then counts to results
mkdir fastqcreport

mkdir temp
echo "end1_fastqc_pass" > ./temp/end1_pass.txt
echo "end1_fastqc_fail" > ./temp/end1_fail.txt
echo "end1_fastqc_warn" > ./temp/end1_warn.txt

while read fastqfiles
do
fastqc -o ./fastqcreport --extract ${fastqcfiles}.fq.gz
awk 'BEGIN{FS="\t";}{if($1 == "PASS"){print $1}}' ./fastqcreport/${fastqcfiles}_fastqc/summary.txt | wc -l >> ./temp/end1_pass.txt
awk 'BEGIN{FS="\t";}{if($1 == "FAIL"){print $1}}' ./fastqcreport/${fastqcfiles}_fastqc/summary.txt | wc -l >> ./temp/end1_fail.txt
awk 'BEGIN{FS="\t";}{if($1 == "WARN"){print $1}}' ./fastqcreport/${fastqcfiles}_fastqc/summary.txt | wc -l >> ./temp/end1_warn.txt
done < ./temp/fastqlist_end1.txt

#2c. same as 2b. but with end2
echo "end2_fastqc_pass" > ./temp/end2_pass.txt
echo "end2_fastqc_fail" > ./temp/end2_fail.txt
echo "end2_fastqc_warn" > ./temp/end2_warn.txt

while read fastqfiles
do
fastqc -o ./fastqcreport --extract ${fastqcfiles}.fq.gz
awk 'BEGIN{FS="\t";}{if($1 == "PASS"){print $1}}' ./fastqcreport/${fastqcfiles}_fastqc/summary.txt | wc -l >> ./temp/end2_pass.txt
awk 'BEGIN{FS="\t";}{if($1 == "FAIL"){print $1}}' ./fastqcreport/${fastqcfiles}_fastqc/summary.txt | wc -l >> ./temp/end2_fail.txt
awk 'BEGIN{FS="\t";}{if($1 == "WARN"){print $1}}' ./fastqcreport/${fastqcfiles}_fastqc/summary.txt | wc -l >> ./temp/end2_warn.txt
done < ./temp/fastqlist_end2.txt


#2d. append all counts onto report6.txt
paste ./report.txt ./temp/end1_pass.txt > ./temp/report1.txt
paste ./report1.txt ./temp/end1_pass.txt > ./temp/report2.txt
paste ./report2.txt ./temp/end1_pass.txt > ./temp/report3.txt
paste ./report3.txt ./temp/end2_pass.txt > ./temp/report4.txt
paste ./report4.txt ./temp/end2_pass.txt > ./temp/report5.txt
paste ./report5.txt ./temp/end2_pass.txt > ./temp/report6.txt




















