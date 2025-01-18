# colocalisation
library(dplyr)
library(ggplot2)
#In your FVC sum summary statistics you need to create a new MAF variable. 

#Before you do this
#convert AF to MAF (minor allele frequency)

#Assign the value of AF to the new variable maf if effect_allele_frequency_alt is less than or equal to 0.5.
#If AF is greater than 0.5, then MAF is 1 - AF.
# Assuming `gwas_data` has been loaded and contains a column `AF` for allele frequency
# Create a new MAF column based on the conditions described
gwas_data <- read.table("/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC_GT_LP_AF_ES.txt")
gwas_data$MAF <- ifelse(gwas_data$V12 <= 0.5, gwas_data$V12, 1 - gwas_data$V12)
# Assuming you have a data frame 'df' with a column 'LP' for the -log10 p-values
gwas_data$pvalue <- 10^(-gwas_data$V11)

names(gwas_data)[names(gwas_data) == "V1"] <- "chromosome"
names(gwas_data)[names(gwas_data) == "V2"] <- "position"
names(gwas_data)[names(gwas_data) == "V3"] <- "rsid"
names(gwas_data)[names(gwas_data) == "V4"] <- "ref"
names(gwas_data)[names(gwas_data) == "V5"] <- "alt"
names(gwas_data)[names(gwas_data) == "V6"] <- "QUAL"
names(gwas_data)[names(gwas_data) == "V7"] <- "FILTER"
names(gwas_data)[names(gwas_data) == "V8"] <- "INFO"
names(gwas_data)[names(gwas_data) == "V9"] <- "beta"
names(gwas_data)[names(gwas_data) == "V10"] <- "se"
names(gwas_data)[names(gwas_data) == "V11"] <- "lp_gwas"
names(gwas_data)[names(gwas_data) == "V12"] <- "af"
names(gwas_data)[names(gwas_data) == "V13"] <- "N"
names(gwas_data)[names(gwas_data) == "V14"] <- "id.2"
names(gwas_data)[names(gwas_data) == "V15"] <- "gt" 
 

############### split by region

# Assuming gwas_data is your data frame containing GWAS summary statistics

# Define a physical distance threshold for defining regions (e.g., 1Mb)
distance_threshold <- 100000  # 1Mb in base pairs

# Sort the data frame by chromosome and position
gwas_data <- gwas_data[order(gwas_data$chromosome, gwas_data$position), ]

# Initialize an empty vector to store the region numbers
region_numbers <- integer(nrow(gwas_data))
current_region <- 1
last_position <- 0

# Loop through the rows of the data frame
for (i in 1:nrow(gwas_data)) {
  # Check if the current SNP is within the distance threshold from the last SNP
  if (gwas_data$chromosome[i] == gwas_data$chromosome[i-1] && 
      abs(gwas_data$position[i] - last_position) <= distance_threshold) {
    # If yes, assign the current region number
    region_numbers[i] <- current_region
  } else {
    # If not, start a new region
    current_region <- current_region + 1
    region_numbers[i] <- current_region
  }
  # Update the last position
  last_position <- gwas_data$position[i]
}

# Add the region numbers to the data frame
gwas_data$region <- region_numbers


# Count the frequency of SNPs in each region
snp_counts <- gwas_data %>%
  group_by(region) %>%  # Replace RegionColumn with the actual column name for regions
  summarise(SNPCount = n())   # Counts the number of rows (SNPs) in each group (region)

# View the result
print(snp_counts)




# Create a bar plot of SNP counts for each region
snp_frequency_plot <- ggplot(snp_counts, aes(x = region, y = SNPCount)) + 
  geom_bar(stat = "identity", fill = "steelblue") +
  theme_minimal() +
  labs(x = "Region", y = "Number of SNPs", title = "Frequency of SNPs in Each Region") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels to avoid overlap

print(snp_frequency_plot)

# also be vary of the fact it give -log10pvalues, I have converted to pvalue in the formated file, but if you are unsure how to handle this in the VCF let me know, the code I used to mofidy the vcf file is in your folder

#################################################################
## coloc sample code, you may have to change the header labels. 

# Load the coloc package

library(coloc)

# Load your GWAS summary statistics
## GWAS header: you may need to reform the file so you can read it in easily or change the lables below ##snp,p,beta,se,MAF ## 
#DONT NEED ## gwas_data <- read.csv("VCFfileConvertedFromVCF.csv")

# Identifying duplicate SNPs
#DONT NEED ## duplicated_snps <- gwas_data[duplicated(gwas_data$ID) | duplicated(gwas_data$ID, fromLast = TRUE),]
#DONT NEED ## print(duplicated_snps)

# Saving duplicated SNPs to a file
#DONT NEED ## write.csv(duplicated_snps, "duplicated_snps.csv", row.names = FALSE)

# Load the eQTL data from a public database
## EQTL header, you may need to reform the file so you can read it in easily or change the lables below ## snp,p,beta,se,MAF

eqtl_data <- read.csv("/Users/hoop/Desktop/hoops_stuff/VCF_data/ColocR_file.csv")
print(dim(eqtl_data)) #how much there is

# Assuming gwas_data$pvalue contains the p-values

# Calculate the -log10(p-value) and store it in the LP column
eqtl_data$lp_eqtl <- -log10(eqtl_data$pvalue)
print(dim(eqtl_data)) #how much there is


# Remove rows with NA values in the GWAS dataset
gwas_data <- na.omit(gwas_data) #dont need?
print(colnames(gwas_data)) # dont need
# Remove rows with NA values in the eQTL dataset
eqtl_data <- na.omit(eqtl_data) # dont need
print("dim(eqtl_data)") # dont understand
print(dim(eqtl_data)) #how much there is

# check eQTL data for duplicates 
eqtl_data <- eqtl_data[!duplicated(eqtl_data$rsid), ]
print(dim(eqtl_data)) #how much there is

# Check data types for gwas_data
print("dim(gwas_data)") # dont understand
print(dim(gwas_data)) # how much there is

# Check data types for eqtl_data
print(str(eqtl_data)) # see whats inside
 
# Ensure that the SNP identifiers match in both datasets
# This step may involve SNP ID conversions or using genomic position to align both datasets ## check if meant to use rsid
gwas_data <- gwas_data[gwas_data$rsid %in% eqtl_data$rsid,]
eqtl_data <- eqtl_data[eqtl_data$rsid %in% gwas_data$rsid,]

print(colnames(gwas_data)) # checks column names
print(colnames(eqtl_data)) # checks column names

gwas_data$varbeta <- gwas_data$se^2 # converts SE and turns into new column called varbeta
eqtl_data$varbeta <- eqtl_data$se^2 # converts SE and turns into new column called varbeta
print(head(gwas_data)) # checks to see if it worked
print(head(eqtl_data))

## debugging

# Check data types for gwas_data
print(str(gwas_data)) # looks at data

# Check data types for eqtl_data
print(str(eqtl_data)) # looks at data

# Summary of gwas_data
print(summary(gwas_data)) # looks at data

# Summary of eqtl_data
print(summary(eqtl_data)) # looks at data






# Find the corresponding positions in gwas_data for the rsids in eqtl_data
matching_positions <- gwas_data$position[match(eqtl_data$rsid, gwas_data$rsid)]

# Replace the position column in eqtl_data with the matching positions
eqtl_data$position <- matching_positions






Dataset2 <- list(
  snp = eqtl_data$rsid,
  position = eqtl_data$position,
  p = eqtl_data$pvalue,
  beta = eqtl_data$beta,
  se = eqtl_data$se,
  MAF = eqtl_data$maf,
  varbeta = eqtl_data$varbeta,
  N = 510, # replace samplesize from #https://github.com/eQTL-Catalogue/eQTL-Catalogue-resources/blob/master/tabix/tabix_ftp_paths.tsv
  type = "quant"
)


# Initialize an empty list to store detailed results for all regions
all_detailed_results <- list()

# Define the range for looping through regions
region_range <- 2:current_region

# Loop through each region
for (region in region_range) {#change range to number of regions identified
  cat("Processing region:", region, "\n")
  
  # Filter the GWAS dataset to include only SNPs in the current region
  gwas_region <- gwas_data[gwas_data$region == region, ]
  
  cat("Number of SNPs in current region:", nrow(gwas_region), "\n")
  
  # Check if the dataset is empty
  if (nrow(gwas_region) == 0) {
    cat("Skipping region", region, "as there are no SNPs in this region.\n")
    next  # Skip to the next iteration
  }
  
  # Construct Dataset1 using the filtered GWAS dataset
  Dataset1 <- list(
    snp = gwas_region$rsid,
    position = gwas_region$position,
    p = gwas_region$pvalue,
    beta = gwas_region$beta,
    se = gwas_region$se,
    MAF = gwas_region$MAF,
    varbeta = gwas_region$varbeta,
    type = "quant", # for case-control studies, use "cc" for case control traits
    N = gwas_region$N # replace with your sample size
  )
  
  cat("Summary of Dataset1:", "\n")
  print(summary(Dataset1))
  
  # Run the colocalization analysis
  results <- coloc::coloc.abf(
    dataset1 = Dataset1,
    dataset2 = Dataset2
  )
  
  # Extract detailed results for each SNP and Correctly extracting PP.H0.abf, PP.H1.abf, and other relevant fields
  detailed_results <- results$results
  detailed_results$PP.H0.abf <- results$summary["PP.H0.abf"]
  detailed_results$PP.H1.abf <- results$summary["PP.H1.abf"]
  detailed_results$PP.H2.abf <- results$summary["PP.H2.abf"]
  detailed_results$PP.H3.abf <- results$summary["PP.H3.abf"]
  detailed_results$PP.H4.abf <- results$summary["PP.H4.abf"]
  #each representing one of the priors used in the analysis (p1 for trait 1, p2 for trait 2, and p12 for the shared prior)
  detailed_results$p1 <- results$priors["p1"]
  detailed_results$p2 <- results$priors["p2"]
  detailed_results$p12 <- results$priors["p12"]
  
  # Store the detailed results for the current region in the list
  all_detailed_results[[paste0("Region_", region)]] <- detailed_results
}


# Combine all detailed results into a single data frame
combined_detailed_results <- do.call(rbind, all_detailed_results)

#plot datasets, need to add positions to datasets, potentially copy set gwas pos to eqtl pos as they are different
plot_dataset(Dataset2) 
plot_dataset(Dataset1) #doesnt work, because there all seperated

# Save the combined results to a file
write.csv(combined_detailed_results, "/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC_GT_LP_AF_ES_COLOC.csv", row.names = FALSE)



########################filter 




# Assuming combined_detailed_results contains the coloc results for all SNPs
# Set thresholds for colocalization probabilities
threshold_PP_H0_abf <- 0.01  # Example threshold for SNP-specific PP.H4
threshold_PP_H1_abf <- 0.01  # Example threshold for PP.H4.abf
threshold_PP_H2_abf <- 0.01  # Example threshold for PP.H0.abf
threshold_PP_H3_abf <- 0.01  # Example threshold for PP.H0.abf
threshold_PP_H4_abf <-  0.9 # Example threshold for PP.H0.abf
threshold_SNP_PP_H4 <- 0.1  # Example threshold for PP.H0.abf

# Initial number of SNPs
initial_count <- nrow(combined_detailed_results)

# Count how many SNPs are filtered out by each criterion individually
snps_filtered_H0 <- initial_count - nrow(combined_detailed_results[combined_detailed_results$PP.H0.abf < threshold_PP_H0_abf, ])
snps_filtered_H1 <- initial_count - nrow(combined_detailed_results[combined_detailed_results$PP.H1.abf < threshold_PP_H1_abf, ])
snps_filtered_H2 <- initial_count - nrow(combined_detailed_results[combined_detailed_results$PP.H2.abf < threshold_PP_H2_abf, ])
snps_filtered_H3 <- initial_count - nrow(combined_detailed_results[combined_detailed_results$PP.H3.abf < threshold_PP_H3_abf, ])
snps_filtered_H4 <- initial_count - nrow(combined_detailed_results[combined_detailed_results$PP.H4.abf > threshold_PP_H4_abf, ])
snps_filtered_SNP_PP_H4 <- initial_count - nrow(combined_detailed_results[combined_detailed_results$SNP.PP.H4 > threshold_SNP_PP_H4f, ])

# Print out the number of SNPs filtered out at each step
cat("SNPs filtered out by PP.H0.abf:", snps_filtered_H0, "\n")
cat("SNPs filtered out by PP.H1.abf:", snps_filtered_H1, "\n")
cat("SNPs filtered out by PP.H2.abf:", snps_filtered_H2, "\n")
cat("SNPs filtered out by PP.H3.abf:", snps_filtered_H3, "\n")
cat("SNPs filtered out by PP.H4.abf:", snps_filtered_H4, "\n")
cat("SNPs filtered out by SNP.PP.H4:", snps_filtered_SNP_PP_H4, "\n")


# Filter SNPs based on colocalization probabilities
coloc_filtered <- combined_detailed_results[
  combined_detailed_results$PP.H0.abf < threshold_PP_H0_abf &
    combined_detailed_results$PP.H1.abf < threshold_PP_H1_abf &
    combined_detailed_results$PP.H2.abf < threshold_PP_H2_abf &
    combined_detailed_results$PP.H3.abf < threshold_PP_H3_abf &
    combined_detailed_results$PP.H4.abf > threshold_PP_H4_abf &
    combined_detailed_results$SNP.PP.H4 > threshold_SNP_PP_H4,
]


write.csv(coloc_filtered, "/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC_GT_LP_AF_ES_COLOC_H0_H4_H4.csv", row.names = FALSE)



########## compare with annovar file

# Read the data without specifying row names
annovar_data <- read.csv("/Users/hoop/Desktop/hoops_stuff/VCF_data/ANNOVAR_DATA.csv")

# Assuming coloc_filtered and annovar_data contain the datasets

# Merge the datasets based on the "snp" and "Otherinfo6" columns
merged_data <- merge(coloc_filtered, annovar_data, by.x = "snp", by.y = "dbSNP", all = FALSE)

merged_data <- merge(merged_data, annovar_data, by.x = "snp", by.y = "dbSNP", all = FALSE)

# The `all = FALSE` argument ensures that only rows with matching values in both datasets are retained.


write.csv(merged_data, "/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC_GT_LP_AF_ES_COLOC_H0_H4_H4_ANNOVAR.csv", row.names = FALSE)



################## make a graph of LP against SNP.PP.H4 #################### doesnt work and not sure how useful it is
# Assuming your thresholds
threshold_lp_gwas <- 40
threshold_SNP_PP_H4 <- 0.75

# remove data with NA in it
merged_data <- na.omit(merged_data)

# Create a column to indicate if lp_gwas is below the threshold
merged_data$below_threshold_lp_gwas <- merged_data$LP.x < threshold_lp_gwas

# Create a column to indicate if SNP.PP.H4 is above the threshold
merged_data$above_threshold_SNP_PP_H4 <- merged_data$SNP.PP.H4 > threshold_SNP_PP_H4

# Create a new column indicating whether the data has passed both thresholds
merged_data$passed_both_thresholds <- merged_data$below_threshold_lp_gwas & merged_data$above_threshold_SNP_PP_H4

library(ggplot2)

# Plot
ggplot(merged_data) +
  geom_point(aes(x = SNP.PP.H4, y = LP.x, color = passed_both_thresholds), alpha = 0.5) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
  labs(x = "SNP.PP.H4", y = "-log10(p) gwas", title = "Colocalization Plot") +
  scale_color_manual(values = c("black", "blue")) +
  scale_y_reverse()


##################### merge and save #######################

merged_data_merged <- merge(merged_data, annovar_data, by.x = "snp", by.y = "Otherinfo6", all = FALSE)


write.csv(merged_data_merged, "/Users/hoop/Desktop/hoops_stuff/VCF_data/VCF_GT_LP_AF_ES_COLOC_SNPPPH4_PPH4abf_PPH0abf_annovar_merged_merged.csv", row.names = FALSE)

################ redo-datasets so they are all in a corectly formated file for future coloc analysis

# Initialize an empty list to store detailed results for all regions
all_detailed_results_2 <- list()

# Define the range for looping through regions
region_range <- 2:current_region

# Loop through each region
for (region in region_range) {#change range to number of regions identified
  cat("Processing region:", region, "\n")
  
  # Filter the GWAS dataset to include only SNPs in the current region
  gwas_region <- gwas_data[gwas_data$region == region, ]
  
  cat("Number of SNPs in current region:", nrow(gwas_region), "\n")
  
  # Check if the dataset is empty
  if (nrow(gwas_region) == 0) {
    cat("Skipping region", region, "as there are no SNPs in this region.\n")
    next  # Skip to the next iteration
  }
  
  # Construct Dataset1 using the filtered GWAS dataset
  Dataset1 <- list(
    snp = gwas_region$rsid,
    position = gwas_region$position,
    p = gwas_region$pvalue,
    beta = gwas_region$beta,
    se = gwas_region$se,
    MAF = gwas_region$MAF,
    varbeta = gwas_region$varbeta,
    type = "quant", # for case-control studies, use "cc" for case control traits
    N = 307638 # replace with your sample size
  )
  
  cat("Summary of Dataset1:", "\n")
  print(summary(Dataset1))
  
  # Run the colocalization analysis
  results <- coloc::coloc.abf(
    dataset1 = Dataset1,
    dataset2 = Dataset2
  )
  
  # Store the results for the current region in the list
  all_detailed_results_2[[paste0("Region_", region)]] <- results
}

# Save the list of detailed results
saveRDS(all_detailed_results_2, file = "all_detailed_results_2.rds")

############################# plot sensitivity

# Choose region 1 from all_detailed_results
region_2_results <- all_detailed_results[["Region_19"]]

# Perform sensitivity analysis on region 1 results
sensitivity(region_2_results, rule = "H4 > 0.75")
