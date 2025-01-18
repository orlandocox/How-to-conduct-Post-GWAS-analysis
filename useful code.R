
# downloading and installing bioc manager
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("VariantAnnotation")

library(VariantAnnotation)

#set working directory
setwd("Users/hoop/Desktop/hoops_stuff/")

getwd()

library(vcfR)

install.packages("vcfR")
library(vcfR)
library(fastman)
library()
setwd("/Users/hoop/Desktop/hoops stuff")
vcf <- read.vcfR("/Users/hoop/Desktop/hoops_stuff/VCF_data/ukb-a-336_GT_corrected_LP_filtered.vcf.gz")
head(getFIX(vcf))
vcf@gt[1:8, 1:2]
head(vcf)
