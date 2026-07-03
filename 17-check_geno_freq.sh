#!/bin/bash

#SBATCH -A naiss2026-3-117
#SBATCH -p shared
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20GB
#SBATCH -t 01:00:00
#SBATCH -J Geno_freq
#SBATCH --mail-user kevin.sartori@slu.se
#SBATCH --mail-type=ALL
ulimit -c unlimited

chrm=$1
outdir=[DIR for outputs]/RILs
vcf=$outdir/RILs_samples_combined.$chrm.snp.filt.vcf

ml bcftools/1.20  samtools/1.20

# how to run:
# for chrm in {1..8}; do sbatch 17-check_geno_freq.sh scaffold_$chrm; done

echo $chrm

# 1 - Corrected markers list:
#----------------------------
 
# Apply filter and count SNPs
echo "Applying GATK filters..."
grep "#" $vcf > ${vcf%.snp.filt.vcf}.filtered.vcf
grep "PASS" $vcf >> ${vcf%.snp.filt.vcf}.filtered.vcf
echo "Nb SNPs before:"
grep -v "#" $vcf | wc -l
echo "Nb SNPs after:"
grep -v "#" ${vcf%.snp.filt.vcf}.filtered.vcf | wc -l
echo

# Include only Cr invariant sites 
Cr_parent=$outdir/../DKCr_16_1377/bam/DKCr_16_1377.mono.vf.norep.vcf
echo "make bed file with invariants filtered for chromosome"
grep -v "#" $Cr_parent | grep $chrm | awk 'BEGIN {OFS="\t"}{print $1,$2}' > $outdir/../DKCr_16_1377/bam/Cr_invariants.$chrm.txt
echo

# bgzip and index
# echo "index vcf"
#bgzip ${vcf%.snp.filt.vcf}.filtered.vcf
#bcftools index -f ${vcf%.snp.filt.vcf}.filtered.vcf.gz
# filter
echo "filter vcf, keep invariants only, remove repeated loci etc"
bcftools filter -R $outdir/../DKCr_16_1377/bam/Cr_invariants.$chrm.txt ${vcf%.snp.filt.vcf}.filtered.vcf.gz -Oz -o ${vcf%.snp.filt.vcf}.mono.vcf.gz
echo

echo "Nb SNPs mono:"
zcat ${vcf%.snp.filt.vcf}.mono.vcf.gz | grep -v "#" | wc -l
echo

# Filter allele frequency and plot frequency check figures
# also produces the corrected marker list !
#------------------------------------------
echo "Filter allele freq and plot, make corrected marker list"
ml PDCOLD/23.12 R/4.4.0
R --slave --vanilla --args ${vcf%.snp.filt.vcf}.mono.vcf.gz $chrm < GenoFreq.R
echo

# 2 - Complete markers list (useless for pipeline version 4)
#--------------------------

#vcf=$outdir/RILs_samples_combined.$chrm.snp.vcf
#grep -v "#" $vcf |  awk 'BEGIN {OFS="_"}{print $1,$2}' > $outdir/RILs_samples_combined.$chrm.t.txt
#echo "Unfiltered vcf SNP number:"
#wc -l $outdir/RILs_samples_combined.$chrm.t.txt
#echo
#awk 'BEGIN {OFS="_"}{print $1,$2}' $outdir/../DKCr_16_1377/bam/Cr_invariants.$chrm.txt > $outdir/Cr_invariants.$chrm.txt
#echo "Cr invariants number:"
#wc -l $outdir/Cr_invariants.$chrm.txt
#echo
#grep -w -f $outdir/Cr_invariants.$chrm.txt $outdir/RILs_samples_combined.$chrm.t.txt > $outdir/markers.complete.$chrm.txt
#echo "marker complete number:"
#wc -l $outdir/markers.complete.$chrm.txt
#echo








