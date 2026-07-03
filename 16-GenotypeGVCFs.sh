#!/bin/bash

#SBATCH -A naiss2026-3-117
#SBATCH -p shared
#SBATCH --ntasks=1
#SBATCH --mem=20GB
#SBATCH --cpus-per-task=1
#SBATCH -t 03:00:00
#SBATCH -J Comb_gvcf_RILs
#SBATCH --mail-user kevin.sartori@slu.se
#SBATCH --mail-type=ALL
ulimit -c unlimited

chrm=$1
ref=$2
outdir=/cfs/klemming/projects/snic/snic2020-16-182/species/Capsellas/bam/RILs
vcf=$outdir/RILs_samples_combined.$chrm.t.vcf

# how to run:
# for chrm in {1..8}; do sbatch 16-GenotypeGVCFs.sh scaffold_$chrm #refdir/Crubella_183.s.fa; done

echo "loading modules"
echo
ml gatk/4.5.0.0
echo

echo 'GATK GenotypeGVCFs'
echo
gatk --java-options -Xmx7g GenotypeGVCFs -R $ref -V $vcf -O ${vcf%.t.vcf}.geno.vcf
echo

echo 'GATK SelectVariants'
echo
gatk --java-options -Xmx12g SelectVariants -R $ref -V ${vcf%.t.vcf}.geno.vcf \
--select-type-to-include SNP \
--restrict-alleles-to BIALLELIC \
-O ${vcf%.t.vcf}.snp.vcf
echo

echo 'GATK VariantFiltration'
echo
gatk --java-options -Xmx12g VariantFiltration -R $ref -V ${vcf%.t.vcf}.snp.vcf \
--filter-name "N_Geno" \
--filter-expression "AN <68" \
--filter-name "QDfilter" \
--filter-expression "QD < 2.0" \
--filter-name "MQfilter" \
--filter-expression "MQ < 40.0" \
--filter-name "DPfilter" \
--filter-expression "DP < 10" \
--filter-name "SORfilter" \
--filter-expression "SOR > 3.0" \
--filter-name "QUALfilter" \
--filter-expression "QUAL < 20.0" \
--filter-name "MQRSfilter" \
--filter-expression "MQRankSum < -12.5" \
--filter-name "RPRSfilter" \
--filter-expression "ReadPosRankSum < -8.0" \
--filter-name "FSfilter" \
--filter-expression "FS > 60.0" \
-O ${vcf%.t.vcf}.snp.filt.vcf
