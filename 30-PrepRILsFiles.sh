#!/bin/bash

#SBATCH -A naiss2026-3-117
#SBATCH -p shared
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=40G
#SBATCH -t 03:00:00
#SBATCH -J Tiger
#SBATCH --mail-user kevin.sartori@slu.se
#SBATCH --mail-type=ALL

sample=$1

# Useful directories
refdir=[DIR to reference files .fa .gff etc]
outdir=[DIR for outputs]/RILs
scriptdir=[DIR to scripts]
softdir=[DIR to Tiger files]
dirvcf=[DIR to the individual vcfs]

MARKCOMP=$outdir/markers.complete.txt
MARKCORR=$outdir/markers.corrected.txt

# HOW TO RUN
#while read s cov; do sbatch 30-PrepRILsFiles.sh $s ; done < samplelist.txt

# modules
ml bcftools/1.20 samtools/1.20

# 1 - convert clean sorted bam file to vcf

echo "bam to vcf, bcftools mpileup"
bcftools mpileup -Oz -E -C --skip-indels -a DP,DV,SP,DP4 -f $refdir/Crubella_183.s.fa $outdir/$sample/bam/$sample.clean.sorted.bam > $outdir/$sample/bam/$sample.temp.tiger.vcf.gz
echo "index vcf"
bcftools index $outdir/$sample/bam/$sample.temp.tiger.vcf.gz
echo "bam to vcf, bcftools call"
bcftools call --output-type v --multiallelic-caller --skip-variants indels -R $MARKCOMP $outdir/$sample/bam/$sample.temp.tiger.vcf.gz > $outdir/$sample/bam/$sample.tiger.vcf

# 2 - extract DP4 lines
echo "extract DP"
bcftools query -f '%CHROM %POS %REF %ALT %QUAL [ %INDEL %DP %DP4]\n' $outdir/$sample/bam/$sample.tiger.vcf -o $outdir/$sample/bam/$sample.tiger.comma.txt

# 3 - replace comma separators with tabs
echo "comma to tab"
tr ',' '\t' < $outdir/$sample/bam/$sample.tiger.comma.txt > $outdir/$sample/bam/$sample.tiger.tabbed.txt

# 4 - get rid of mito and cp reads; create columns for read counts for ref allele and alt allele by adding the first two of the DP4 fields 
#and the second two of the DP4 fields. ##INFO=<ID=DP4,Number=4,Type=Integer,Description="# high-quality ref-forward bases, ref-reverse, alt-forward and alt-reverse bases">
#and  change chromosome column to numbers only (to match TIGER input)

awk '{if ($1 !="ChrC" && $1!="ChrM") print $1 "\t" $2 "\t" $3 "\t" $8+$9 "\t"  $4 "\t"  $10+$11}' $outdir/$sample/bam/$sample.tiger.tabbed.txt \
| awk '{gsub("scaffold_","")}1' > $outdir/$sample/bam/$sample.input.temp

# 6 - filter indels only (to generate "complete" file for TIGER)  
# Here I use custom bash cmds instead of provided scripts
echo "filter and make Tiger files"
# 6.1- create new column paste chrm and pos 
awk 'BEGIN {FS="\t"; OFS="\t"} {print $1,$2,$3,$4,$5,$6,$1"_"$2}' $outdir/$sample/bam/$sample.input.temp > $outdir/$sample/bam/$sample.input_.temp
# 6.2- list to keep
awk 'BEGIN {FS="_"} {print $2}' $MARKCOMP | awk 'BEGIN {FS="\t"} {print $1"_"$2}' > $dirvcf/markers.complete_.txt
awk 'BEGIN {FS="_"} {print $2}' $MARKCORR | awk 'BEGIN {FS="\t"} {print $1"_"$2}' > $dirvcf/markers.corrected_.txt
# 6.3- grep
echo "making complete file"
grep -w -f $dirvcf/markers.complete_.txt $outdir/$sample/bam/$sample.input_.temp | awk 'BEGIN {FS="\t"; OFS="\t"} {print $1,$2,$3,$4,$5,$6}' > $outdir/$sample/bam/$sample.input_complete.txt
echo "making corrected file"
grep -w -f $dirvcf/markers.corrected_.txt $outdir/$sample/bam/$sample.input_.temp | awk 'BEGIN {FS="\t"; OFS="\t"} {print $1,$2,$3,$4,$5,$6}' > $outdir/$sample/bam/$sample.input_corrected.txt
# 6.4- check
echo
echo "complete file :"
wc $outdir/$sample/bam/$sample.input_complete.txt
head $outdir/$sample/bam/$sample.input_complete.txt
echo
echo "corrected file :"
wc $outdir/$sample/bam/$sample.input_corrected.txt
head $outdir/$sample/bam/$sample.input_corrected.txt


echo "remove useless files"
rm $outdir/$sample/bam/*tabbed*
rm $outdir/$sample/bam/*temp
rm $outdir/$sample/bam/*comma*
rm $outdir/$sample/bam/*tiger.vcf*
