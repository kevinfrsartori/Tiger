#!/usr/bin/env Rscript
args = commandArgs(trailingOnly = T)

expDesign <- args[1]
chr_len <- args[2]
outputdir <- args[3]
R=args[4]

# packages
library(RTIGER)
setupJulia()
sourceJulia()

# expDesign object
expDesign <- read.table(args[1],sep="\t",h=T)
print(expDesign)

# Chromosome lengths
chr_len.t <- read.table(args[2],sep="\t",h=F)
chr_len <- chr_len.t$V2
names(chr_len) <- chr_len.t$V1
print(chr_len)


myres = RTIGER(expDesign = expDesign,
               outputdir = args[3],
               seqlengths = chr_len,
               rigidity = R,
               autotune = F,
               save.results = TRUE)
