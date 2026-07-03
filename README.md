---
editor_options: 
  markdown: 
    wrap: 72
---

# Tiger

Collection of scripts for genotyping RILs from low coverage sequencing.

Adaptation of tiger and Rtiger scripts, must read :

<https://doi.org/10.1534/g3.114.016501>

<https://doi.org/10.1093/plphys/kiad191>

(made to run on PDC HPC KTH)

# Note

Specificity of my study:

\- The RIL population was made from a cross between Capsella grandiflora
and Capsella rubella.

\- The rubella individual is different from the reference individual
that was used to build the reference genome.

# Scripts:

Must be run in order.

The scripts 00 01 and 02 are made to filter out variants between the
reference rubella and the rubella used in the study (Keep "monomorphic"
sites only)

The scripts 11 to 17 perform the mapping of all RILs with two output: -
All RILs combined as a single sequencing, to indentify the Markers - Per
RIL vcf, for genotyping + some quality visualization ( Expected genotype
frequencies)

Script 20 output the Marker lists needed for Tiger

Script 21 filter individuals no suitable for further steps

Scripts 30 and 40 are inherited from TIGER and RTIGER

Script 50 recover a COs filtering step from Tiger


