#!/bin/bash

outdir=/cfs/klemming/projects/snic/snic2020-16-182/species/Capsellas/bam/RILs

# recover coverage info from qualimap and make table

grep "<tr onmouseover" ../2.3-Tiger/qualimap/multisampleBamQcReport.html -A 2 \
| sed '/^<tr/d' | sed '/^--/d' |  sed '/^<td class/d' \
| awk 'NR % 2 == 0' | awk '{gsub(/<td>/,"")}1' | awk '{gsub("</td>","")}1' \
| sed '/^<b>/d' > samplecov.txt

grep "<tr onmouseover" ../2.3-Tiger/qualimap/multisampleBamQcReport.html -A 2 \
| sed '/^<tr/d' | sed '/^--/d' |  sed '/^<td class/d' \
| awk 'NR % 2 == 1' | awk '{gsub(/<td>/,"")}1' | awk '{gsub("</td>","")}1' \
| sed '/^<b>/d' > samplenames.txt

paste  samplenames.txt samplecov.txt > namecov.txt

sort -u -k 2 namecov.txt > namecov.sorted.txt 

# keep only if coverage > 0.5
awk '{if ($2 > 0.5) print}' namecov.sorted.txt > samplelist.txt

