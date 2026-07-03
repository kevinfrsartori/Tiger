#!/bin/bash

#SBATCH -A naiss2025-22-1585
#SBATCH -p shared
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH -t 02:00:00
#SBATCH -J Mono
#SBATCH --mail-user kevin.sartori@slu.se
#SBATCH --mail-type=ALL

# Useful directories
refdir=
outdir=
scriptdir=
vcfdir=
sample=

# 1 - Mapping of C.rubella parent
# C. rubella parent: r29 DKCr_16_1377.RG.bam
# Bam files available from previous mapping on ref Crubella_183.fa
# crbam=PATH/DKCr_16_1377.RG.bam

# 2 - HaplotypeCaller
# Output available from previous project here:  $vcfdir/DKCr_16_1377.g.vcf
# Just run HaplotypeCaller on individual DKCr_16_1377

# Note : Do not run GenotypeGVCFs
# We keep monomorphic sites

# 3 - Select variant
# 3.1 - Keep monomorphic sites only
grep "#" $vcfdir/DKCr_16_1377.g.vcf > $vcfdir/DKCr_16_1377.mono.vcf
grep "0/0" $vcfdir/DKCr_16_1377.g.vcf | grep -v "AD" >> $vcfdir/DKCr_16_1377.mono.vcf
# 3.2 - make coverage histogram
ml bcftools/1.20
bcftools query -f '[%DP]\n' $vcfdir/DKCr_16_1377.mono.vcf | sort | uniq -c  > WG_DP.txt

# 3.3 - check WG_DP file and filter per DP accordingly
# Decision was made to filter above 4 and below 51
# See 02-VariantFiltration.sh
