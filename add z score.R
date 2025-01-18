#filter by z-score
not_z_filtered <- read.table("/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC_GT_LP_AF_ES.txt")


names(not_z_filtered)[names(not_z_filtered) == "V1"] <- "chromosome"
names(not_z_filtered)[names(not_z_filtered) == "V2"] <- "position"
names(not_z_filtered)[names(not_z_filtered) == "V3"] <- "rsid"
names(not_z_filtered)[names(not_z_filtered) == "V4"] <- "ref"
names(not_z_filtered)[names(not_z_filtered) == "V5"] <- "alt"
names(not_z_filtered)[names(not_z_filtered) == "V6"] <- "QUAL"
names(not_z_filtered)[names(not_z_filtered) == "V7"] <- "FILTER"
names(not_z_filtered)[names(not_z_filtered) == "V8"] <- "INFO"
names(not_z_filtered)[names(not_z_filtered) == "V9"] <- "ES"
names(not_z_filtered)[names(not_z_filtered) == "V10"] <- "SE"
names(not_z_filtered)[names(not_z_filtered) == "V11"] <- "lp_gwas"
names(not_z_filtered)[names(not_z_filtered) == "V12"] <- "af"
names(not_z_filtered)[names(not_z_filtered) == "V13"] <- "N"
names(not_z_filtered)[names(not_z_filtered) == "V14"] <- "id.2"
names(not_z_filtered)[names(not_z_filtered) == "V15"] <- "gt" 



# Calculate Z-scores
not_z_filtered$Zscore <- with(not_z_filtered, ES / SE)

write.csv(not_z_filtered, "/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC_GT_LP_AF_ES_Z.csv", row.names = FALSE)


# Assuming you want to filter based on a certain Z-score threshold, let's say |Z-score| > 1.96 for a 95% confidence interval
# This step is optional and depends on your specific criteria for filtering
# z_filtered <- not_z_filtered[abs(not_z_filtered$Zscore) > 1.96, ] # dont need to use