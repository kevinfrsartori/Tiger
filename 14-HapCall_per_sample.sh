#!/bin/bash

#SBATCH -A naiss2026-3-117
#SBATCH -p shared
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=30GB
#SBATCH -t 06:00:00
#SBATCH -J RILs_GATK_per_sample
#SBATCH --mail-user kevin.sartori@slu.se
#SBATCH --mail-type=ALL
ulimit -c unlimited

sample=$1

# Useful directories
refdir=[DIR to reference files .fa .gff etc]
bamdir=[DIR to bam files]/01.RawData
outdir=[DIR for outputs]/RILs
scriptdir=[DIR to scripts]

# How to run:
#while read s; do sbatch 14-HapCall_per_sample.sh $s ; done < newlistsamples.txt

echo "loading modules"
echo
ml gatk/4.5.0.0 bcftools/1.20

echo "Sync files"
echo
rsync -ta $outdir/$sample/bam/$sample.clean.sorted.bam* $PDC_TMP
rsync -ta $refdir/Crubella_183.s.* $PDC_TMP
cd $PDC_TMP
echo

echo 'GATK Hap Call'
echo
gatk --java-options -Xmx7g HaplotypeCaller -I $sample.clean.sorted.bam -R Crubella_183.s.fa -ERC GVCF -O $sample.g.vcf

echo "Histo DP"
bcftools query -f '[%DP]\n' $sample.g.vcf | sort | uniq -c  > $sample.WG_DP.txt
echo

echo "R mu + 2sd"
ml PDCOLD/23.12 R/4.4.0
R --slave --vanilla --args $sample.WG_DP.txt $sample.DP_stats.txt < $scriptdir/DP_stats.R
echo

echo "bcftools filter"
maxDP=$(tail -n 1 $sample.DP_stats.txt)
bcftools filter -i "FORMAT/DP<$maxDP" $sample.g.vcf -Ov -o $sample.g.dpfilt.vcf
echo

echo "sample: "$sample
echo "g.vcf variant number"
grep -v "#" $sample.g.vcf | wc -l
echo
echo "g.dpfilt.vcf variant number"
grep -v "#" $sample.g.dpfilt.vcf | wc -l
echo

echo "Sync files"
echo
rsync $PDC_TMP/$sample.g.dpfilt.vcf $outdir/$sample/bam/$sample.g.dpfilt.vcf

gatk IndexFeatureFile -I $outdir/$sample/bam/$sample.g.dpfilt.vcf
