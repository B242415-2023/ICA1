#!/bin/bash

#1.User defined inputs
#condition1
echo -e "Please use format (SampleType Time Treatment) and exact names as seen on Tco2.fqfiles\nReference Condition:"
read refsample reftime reftreat

#condition2
echo -e "Please use format (SampleType Time Treatment), only vary one field from Reference Condition, and exact names as seen on Tco2.fqfiles\nQuery Condition:"
read quersample  quertime  quertreat

#range
echo -e "Please use one exact column name from Tco2.fqfiles (SampleType OR Time OR Treatment)\nRange:"
read range

echo -e "${refsample}, ${reftime}, ${reftreat}\n${quersample}, ${quertime}, ${quertreat}\n ${range}"


#2. Fold change between reference and query
mkdir foldchange
>./temp/pastefoldchange.txt





paste ./counts/replicatemeans/${refsample}_${reftime}_${reftreat}_all.txt ./counts/replicatemeans/${quersample}_${quertime}_${quertreat}_all.txt > ./temp/pastefoldchange.txt

>./foldchange/${refsample}_${reftime}_${reftreat}_vs_${quersample}_${quertime}_${quertreat}.txt
while read query ref 
do
echo ${query} ${ref}

  if test $ref -eq 0
  then
    #awk 'BEGIN{FS="\t";}{$(($2 / ($1 + 0.1)))}'>> ./foldchange/${refsample}_${reftime}_${reftreat}_vs_${quersample}_${quertime}_${quertreat}.txt
    echo "${query} / (${ref} + 1)" | bc -l >> ./foldchange/${refsample}_${reftime}_${reftreat}_vs_${quersample}_${quertime}_${quertreat}.txt
    echo "eq0"
    
  else
    #awk 'BEGIN{FS="\t";}{$(($2 / $1))}'>> ./foldchange/${refsample}_${reftime}_${reftreat}_vs_${quersample}_${quertime}_${quertreat}.txt
    echo "${query} / ${ref}" | bc -l >> ./foldchange/${refsample}_${reftime}_${reftreat}_vs_${quersample}_${quertime}_${quertreat}.txt
    echo "!=0"
  fi
  
done < ./temp/pastefoldchange.txt