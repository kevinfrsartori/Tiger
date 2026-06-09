#!/bin/bash

refdir=PATH
ml systemdefault/1.0.0 bioinfo-tools picard/3.3.0 samtools/1.20

# Create dictionary for GATK
java -jar $PICARD CreateSequenceDictionary \
      -R $refdir/Crubella_183.s.fa \
      -O $refdir/Crubella_183.s.dict

samtools faidx $refdir/Crubella_183.s.fa
