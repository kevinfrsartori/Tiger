#!/bin/bash

#SBATCH -A naiss2025-22-1585
#SBATCH -p shared
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH -t 03:00:00
#SBATCH -J RILs_cleanbam
#SBATCH --mail-user kevin.sartori@slu.se
#SBATCH --mail-type=ALL
ulimit -c unlimited

sample=$1

# Useful directories
refdir=[DIR to reference files .fa .gff etc]
bamdir=[DIR to bam files]/01.RawData
outdir=[DIR for outputs]/RILs
scriptdir=[DIR to scripts]

#remove indiv e8 e9 e16 (low coverage)
#grep -v -w "e8$" listsamples.txt | grep -v -w "e9$" | grep -v -w "e16$" > newlistsamples.txt

# How to run:
#while read s; do sbatch 13-CleanBam.sh $s ; done < newlistsamples.txt

echo "loading modules"
ml systemdefault/1.0.0 bioinfo-tools samtools/1.20
echo
echo "samtools clean"
echo
samtools view -bh -q20 -f 0x2 $outdir/$sample/bam/$sample.nodup.bam > $outdir/$sample/bam/$sample.clean.bam
echo
echo "samtools sort"
echo
samtools sort $outdir/$sample/bam/$sample.clean.bam -o $outdir/$sample/bam/$sample.clean.sorted.bam
echo
echo "samtools index"
echo
samtools index $outdir/$sample/bam/$sample.clean.sorted.bam
echo
echo "check data ..."
echo "... raw ..."
samtools flagstat $outdir/$sample/bam/$sample.nodup.bam
echo "... filtered"
samtools flagstat $outdir/$sample/bam/$sample.clean.sorted.bam
