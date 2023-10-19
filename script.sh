#!/bin/bash

#1. IMPORT SEQ DATA INTO tempfiles DIRECTORY
####Make a check for if there are files aready in tempdata or files in directory?
mkdir seqdata
cp -u /localdisk/data/BPSM/ICA1/fastq/* ./seqdata
awk 'BEGIN{FS="\t";}{print $1,$2,$3,$4,$5}' ./seqdata/Tco2.fqfiles > report.txt



#2. PERFORM fastqc QUALITY CHECK ON COMPRESSED fastq PAIRED END RAW SEQUENCE DATA 
##2a. Gather end1 and end2 column data (lists available fastq files) from Tco2.fqfiles
touch ./temp/fastqlist_end1.txt
awk 'BEGIN{FS="\t";}{if($6 != "End1"){print $6}}' ./seqdata/Tco2.fqfiles | cut -d "." -f 1 > ./temp/fastqlist_end1.txt
touch ./temp/fastqlist_end2.txt
awk 'BEGIN{FS="\t";}{if($7 != "End2"){print $7}}' ./seqdata/Tco2.fqfiles | cut -d "." -f 1 > ./temp/fastqlist_end2.txt
##2b. end 1 fastqc on all files in fastqlist.txt, then count number of pass/fail/warn, then append to results
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
##2c. same as 2b. but with end2
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
##2d. append all counts onto report.txt
paste ./report.txt ./temp/end1_pass.txt | paste - ./temp/end1_fail.txt | paste - ./temp/end1_warn.txt |paste - ./temp/end2_pass.txt |paste - ./temp/end2_fail.txt |paste - ./temp/end2_warn.txt > ./temp/reportfinal.txt
cp ./temp/reportfinal.txt ./report.txt

##############user input for no. of fails threshold to remove seq data?
##############flag bad seq data and input base no. for trimming?

#3. IMPORT T.congo GENOME SEQ AND .bed FILE INTO refseqdata and uncompress .gz
mkdir refseqdata
cp -u /localdisk/data/BPSM/ICA1/Tcongo_genome/* ./refseqdata/
gzip -d ./refseqdata/TriTrypDB-46_TcongolenseIL3000_2019_Genome.fasta.gz
cp -ur /localdisk/data/BPSM/ICA1/* ./refseqdata/


#4. ALIGN READ PAIRS ONTO REFERENCE GENOME
##4a. Reformat refseq into single line sequences, then select chromosome sequences only
############make check on refseq format?
awk '/^>/ {print (NR>1?"\n":"")$0;;next}{printf "%s",$0;} END{print "";}' ./refseqdata/TriTrypDB-46_TcongolenseIL3000_2019_Genome.fasta > ./refseqdata/genomeonlyref.fasta
grep -A1 "SO=chromosome" ./refseqdata/genomeonlyref.fasta > ./refseqdata/genomeonlyref1.fasta
##4b. Build bowtie2 index from ref chromosome sequences only 
bowtie2-build -f ./refseqdata/genomeonlyref1.fasta ./refseqdata/refbowtieindex
##4c. Align read pairs via bowtie2
cut -d "_" -f 1 ./temp/fastqlist_end1.txt > ./temp/fastqlist_base.txt #gather gene base names
mkdir ./aligned

while read base
do
bowtie2 -x ./refseqdata/refbowtieindex -q -1 ./seqdata/${base}_1.fq.gz -2 ./seqdata/${base}_2.fq.gz > ./aligned/${base}.sam
done < ./temp/fastqlist_base.txt
##4d. Convert .sam files from bowtie2 to .bam via samtools
while read base
do
samtools view -b -o ./aligned/${base}.bam ./aligned/${base}.sam
done < ./temp/fastqlist_base.txt
##4e. Generate index .bai files 
while read base
do
samtools sort --output-fmt BAM ./aligned/${base}.bam > ./aligned/${base}_sort.bam
samtools index -b ./aligned/${base}_sort.bam
done < ./temp/fastqlist_base.txt



#5. GENERATE COUNTS DATA VIA bedtools FROM REFSEQ .bed AND .bam 
mkdir counts
while read base
do
bedtools coverage -counts -a ./refseqdata/TriTrypDB-46_TcongolenseIL3000_2019.bed -b ./aligned/${base}_sort.bam > ./counts/${base}_counts.txt
done < ./temp/fastqlist_base.txt



#6. USER DEFINED GROUP SELECTIONS
#avail groups: 
#between replicates for variation
#sample type
#time
#treatment
#
#
#




#7. GENERAL METHOD FOR CALCULATING MEANS OF COUNTS PER GENE OF GROUP DEFINED IN 6. 


##########SANDBOX################





#cat "/localdisk/home/s2600569/ICA01/counts/Tco-935_counts.txt" | awk '{FS="\t"}{if($6 >= 1){print $0}}' -




