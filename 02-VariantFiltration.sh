#!/bin/bash

#SBATCH -A naiss2025-22-1585
#SBATCH -p shared
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH -t 01:00:00
#SBATCH -J VarFilt_RILs
#SBATCH --mail-user kevin.sartori@slu.se
#SBATCH --mail-type=ALL

VCF=[DIR]/DKCr_16_1377.mono.vcf
REF=[DIR]/Crubella_183.fa

# how to run:
# sbatch 02-VariantFiltration.sh

echo "loading modules"
echo
ml bcftools/1.20
echo
echo 'Bcftools Variant Filtration'
echo

bcftools filter -i 'FORMAT/DP>4 & FORMAT/DP<51 & FORMAT/GQ>5' $VCF -Ov -o ${VCF%.vcf}.vf.vcf

echo
echo "Histo DP"
bcftools query -f '[%DP]\n' ${VCF%.vcf}.vf.vcf | sort | uniq -c  > WG_DP.txt


