####### filter and annovar merging

# Read filtered GWAS data
filtered_data_for_merge <- read.table("/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC_GT_LP_AF_ES.txt")

# Read the data without specifying row names
annovar_data_for_merge <- read.csv("/Users/hoop/Desktop/hoops_stuff/VCF_data/ANNOVAR_DATA.csv")

# Merge anovar and gwas data by SNP
merged_anovar_and_gwas_data <- merge(filtered_data_for_merge, annovar_data_for_merge, by.x = "V14", by.y = "Otherinfo6", all = FALSE)

write.csv(merged_anovar_and_gwas_data, "/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC_GT_LP_AF_ES_ANNOVAR.csv", row.names = FALSE)
