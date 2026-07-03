#!/bin/bash

#SBATCH -A naiss2025-22-1585
#SBATCH -p shared
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH -t 03:00:00
#SBATCH -J MAP_RILs
#SBATCH --mail-user kevin.sartori@slu.se
#SBATCH --mail-type=ALL
ulimit -c unlimited

sample=$1

# Useful directories
refdir=[DIR to reference files .fa .gff etc]
bamdir=[DIR to bam files]/01.RawData
outdir=[DIR for outputs]/RILs
scriptdir=[DIR to scripts]

# new ref /cfs/klemming/projects/supr/snic2020-16-182/species/C_rubella/REF/DKCr_16_1377.fasta

#ls $bamdir/ > listfile.txt
#remove indiv e4 e92 (bad QC)
#grep -v -w "e4$" listfile.txt | grep -v -w "e92$" > listsamples.txt
#while read s; do sbatch 11-Mapping.sh $s ; done < listsamples.txt


# 1 - Mapping
#------------
mkdir $outdir/$sample

echo "loading modules"
echo
ml systemdefault/1.0.0
module load bioinfo-tools
module load bwa/0.7.18
module load samtools/1.20
module load picard/3.3.0

echo "Sync files"
echo
rsync -ta $bamdir/$sample/trimout/$sample.*_paired.fq.gz $PDC_TMP
rsync -ta $refdir/Crubella_183.s.* $PDC_TMP
cd $PDC_TMP
echo
ls
echo
echo "bwa mem"
echo
bwa mem -t 8 -T 0 -R '@RG\tID:foo\tSM:bar' Crubella_183.s.fa $sample.forward_paired.fq.gz $sample.reverse_paired.fq.gz | samtools view -h -b -o $sample.bam
echo
echo 'fixing read groups'
echo
#INFO from novogene website
#instrument:run_number:flow_cell_ID:Lane_number:Tile:number:Xcoordinate:Ycoordinate read_number:filtered:controlled:indexes
samtools view $sample.bam | head -n 1 | awk '{print $1}' > rg.txt
instrument=$(awk -F':' '{print $1}' rg.txt)
run=$(awk -F':' '{print $2}' rg.txt)
flowcell=$(awk -F':' '{print $3}' rg.txt)
lane=$(awk -F':' '{print $4}' rg.txt)
tile=$(awk -F':' '{print $5}' rg.txt)
ID=$instrument.$sample
LB=lib1
PL=ILLUMINA
SM=$sample
PU=$flowcell.$lane.$sample
java -jar $PICARD AddOrReplaceReadGroups I=$sample.bam O=$sample.rg.bam SORT_ORDER=coordinate ID=$ID LB=$LB PL=$PL SM=$SM PU=$PU CREATE_INDEX=true
echo
echo "samtools sort"
echo
samtools sort $sample.rg.bam -o $sample.sorted.bam
echo
echo "samtools index"
echo
samtools index $sample.sorted.bam
echo
echo "picard MarkDuplicates"
java -jar $PICARD MarkDuplicates --INPUT $sample.sorted.bam --OUTPUT $sample.nodup.bam --METRICS_FILE picard_log.txt --REMOVE_DUPLICATES true
echo
echo "samtools index"
samtools index $sample.nodup.bam
echo
echo "copying"
# copy the results back to the output directory
mkdir $outdir/$sample/bam
rsync $PDC_TMP/$sample.nodup.bam $outdir/$sample/bam/$sample.nodup.bam
rsync $PDC_TMP/$sample.nodup.bam.bai $outdir/$sample/bam/$sample.nodup.bam.bai

