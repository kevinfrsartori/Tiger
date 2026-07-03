#!/bin/bash

# Useful directories
outdir=[DIR for outputs]/RILs
vcf=$outdir/RILs_samples_combined.$chrm.snp.filt.vcf
scriptdir=[DIR to scripts]

# Indentify markers
#---------------------------------------------
echo "Make marker lists"

rm $outdir/markers.complete.txt
touch $outdir/markers.complete.txt
for chrm in {1..8}
do
awk 'BEGIN {FS="_";OFS="\t"} {print $1"_"$2,$3}' $outdir/markers.complete.scaffold_$chrm.txt >> $outdir/markers.complete.txt
done

rm $outdir/markers.corrected.txt
touch $outdir/markers.corrected.txt
for chrm in {1..8}
do
awk 'BEGIN {FS="_"; OFS="\t"} {print $1"_"$2,$3}' $scriptdir/Markers_filtered_scaffold_$chrm.txt >> $outdir/markers.corrected.txt
done

echo "Nb markers complete list :"
wc -l $outdir/markers.complete.txt
echo "header:"
head $outdir/markers.complete.txt
echo
echo "Nb markers corrected list :"
wc -l  $outdir/markers.corrected.txt
echo "header:"
head $outdir/markers.corrected.txt
echo

echo "Chromosomes included in marker lists:"
echo "corrected"
awk '{print $1}' $outdir/markers.corrected.txt | uniq -c
echo "complete"
awk '{print $1}' $outdir/markers.complete.txt | uniq -c
