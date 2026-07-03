#!/bin/bash

#SBATCH -A naiss2025-22-1585
#SBATCH -p shared
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH -t 02:00:00
#SBATCH -J MQC
#SBATCH --mail-user kevin.sartori@slu.se
#SBATCH --mail-type=ALL

# Useful directories
refdir=[DIR to reference files .fa .gff etc]
bamdir=[DIR to bam files]/01.RawData
outdir=[DIR for outputs]/RILs
scriptdir=[DIR to scripts]


ls $outdir/*/bam/*.nodup.bam > listpath.txt
ls $outdir/*/bam/*.nodup.bam | awk 'BEGIN {FS="/"} {print $11}' > listsample.txt
paste listsample.txt listpath.txt > sampledirs.txt

echo "loading modules"
echo
ml PDC/24.11
ml qualimap/2.3
echo
mkdir qualimap
qualimap multi-bamqc -c -d sampledirs.txt -gff $refdir/Crubella_183.s.gff -outdir qualimap -outformat HTML -r 
