#!/bin/bash

indir=[DIR for outputs]/RILs
scriptdir=[DIR of these scripts]
softdir=[DIR to TIGER scripts]
outdir=$scriptdir/clean_bed

ml perl/5.34.0

ls $indir/RTIGER_output.R*/*/Com*.bed | awk 'BEGIN {FS="/";OFS="\t"} {print $0,$12}' > $scriptdir/files.txt

mkdir $outdir

#test
#cat $outdir/RTIGER_output*/$sample/CompleteBlock-state-$sample.bed | awk '{gsub("AA","CC")}1' \
#| awk '{gsub("AB","CL")}1' | awk '{gsub("BB","LL")}1' | awk -F="\t" -v s=$sample '{print s,$1,$2,$3,$4}' > $outdir/RTIGER_output*/$sample/raw.$sample.txt

while read file sample
do

echo
echo $sample

echo "change genetic code"
cat $file | awk '{gsub("AA","CC")}1' | awk '{gsub("AB","CL")}1' | awk '{gsub("BB","LL")}1' \
| awk -F="\t" -v s=$sample '{print s,$1,$2,$3,$4}' > $outdir/raw.$sample.txt

echo "refined breaks"
cd $outdir
perl $softdir/TIGER/refine_recombination_break.pl $indir/$sample/bam/$sample.input_complete.txt $outdir/raw.$sample.txt

done < $scriptdir/files.txt
