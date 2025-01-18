# How to conduct Preprocessing

## Filter data by P-Value
The first step was to remove any associations that were below the desired p-value threshold. The industry standard is (p-value (0.5x10-8).), which most papers publications will follow
## Filter by allele frequency
removed to reduce the chance of false positives, allele frequency filtration values set at (AF<0.995, AF>0.005).
## Filter by Z scores
removal of SNPs above a publicly accepted z score (Holland et al., 2016)
## Add GT Values
this step was required in my pre-processing as the source data obtained from the IEU openGWAS was missing GT values that were required to run adding false GT values for file compatibility with the ANNOVAR system.
