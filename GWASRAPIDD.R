# download package
# Install GWASrapidd if you haven't already
if (!requireNamespace("gwasrapidd", quietly = TRUE)) {
  install.packages("gwasrapidd")
}

# Load the GWASrapidd library
library(gwasrapidd)

PA_gwas_data <- read.csv("/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC_GT_LP_AF_ES_COLOC_H0_H4_H4_ANNOVAR.csv")

################# get variants (get information about the variants identified in gwas ) # works
variant_ids <- PA_gwas_data$snp

# Initialize a list to store the results
variants_list <- list()

# Correcting the variable name
for (variant in variant_ids) {  # Use 'variant_ids' as defined earlier
  variants <- tryCatch({
    get_variants(variant_id = variant)
  }, error = function(e) {
    NA  # Return NA or an appropriate value in case of an error
  })
  
  # Store the results in the list
  variants_list[[variant]] <- variants
}

################ download all

library(dplyr)

# Step 1: Extract the 'variants' slot and combine them
variants_combined <- lapply(variants_list, function(x) x@variants) %>% 
  bind_rows(.id = "variant_id")

genomic_contexts_combined <- lapply(variants_list, function(x) x@genomic_contexts) %>% 
  bind_rows(.id = "variant_id")

ensembl_ids_combined <- lapply(variants_list, function(x) x@ensembl_ids) %>% 
  bind_rows(.id = "variant_id")

entrez_ids_combined <- lapply(variants_list, function(x) x@entrez_ids) %>% 
  bind_rows(.id = "variant_id")

# Step 2: Write the combined data frame to a CSV file
write.csv(variants_combined, "/Users/hoop/Desktop/hoops_stuff/VCF_data/prior_association/variants_list/FVC_GT_LP_AF_ES_COLOC_H0_H4_H4_ANNOVAR_RAPIDD_VARIANTS_COMBINED", row.names = FALSE)
write.csv(genomic_contexts_combined, "/Users/hoop/Desktop/hoops_stuff/VCF_data/prior_association/variants_list/FVC_GT_LP_AF_ES_COLOC_H0_H4_H4_ANNOVAR_RAPIDD_GENOMIC_CONTEXTS_COMBINED", row.names = FALSE)
write.csv(ensembl_ids_combined, "/Users/hoop/Desktop/hoops_stuff/VCF_data/prior_association/variants_list/FVC_GT_LP_AF_ES_COLOC_H0_H4_H4_ANNOVAR_RAPIDD_ENSEMBL_IDS_COMBINED", row.names = FALSE)
write.csv(entrez_ids_combined, "/Users/hoop/Desktop/hoops_stuff/VCF_data/prior_association/variants_list/FVC_GT_LP_AF_ES_COLOC_H0_H4_H4_ANNOVAR_RAPIDD_ENTREZ_IDS_COMBINED", row.names = FALSE)


############## get studies, associated with 'vital capacity'
# get studies associated with a trait
my_studies <- get_studies(efo_trait = 'vital capacity')
# get associations to a trait
my_associations <- get_associations((study_id = my_studies@studies$study_id))


# check how many studies were found
gwasrapidd::n(my_studies) # not ideal way
# check how many associations were found
gwasrapidd::n(my_associations) # not ideal way

# Get association ids for which pvalue is less than 1e-8.
dplyr::filter(my_associations@associations, pvalue < 1e-8) %>% # Filter by p-value
  tidyr::drop_na(pvalue) %>%
  dplyr::pull(association_id) -> association_ids # Extract column association_id

# Extract associations by association id
my_associations2 <- my_associations[association_ids]
gwasrapidd::n(my_associations2)

my_associations2@risk_alleles[c('variant_id', 'risk_allele', 'risk_frequency')]


library(dplyr)

############### download all 

# Extract and write the 'associations' slot to a CSV file
associations_df <- my_associations2@associations
write.csv(associations_df, "/Users/hoop/Desktop/hoops_stuff/VCF_data/prior_association/associations2/my_associations2_associations.csv", row.names = FALSE)

# Extract and write the 'loci' slot to a CSV file
loci_df <- my_associations2@loci
write.csv(loci_df, "/Users/hoop/Desktop/hoops_stuff/VCF_data/prior_association/associations2/my_associations2_loci.csv", row.names = FALSE)

# Extract and write the 'risk_alleles' slot to a CSV file
risk_alleles_df <- my_associations2@risk_alleles
write.csv(risk_alleles_df, "/Users/hoop/Desktop/hoops_stuff/VCF_data/prior_association/associations2/my_associations2_risk_alleles.csv", row.names = FALSE)

# Extract and write the 'genes' slot to a CSV file
genes_df <- my_associations2@genes
write.csv(genes_df, "/Users/hoop/Desktop/hoops_stuff/VCF_data/prior_association/associations2/my_associations2_genes.csv", row.names = FALSE)

# Extract and write the 'ensembl_ids' slot to a CSV file
ensembl_ids_df <- my_associations2@ensembl_ids
write.csv(ensembl_ids_df, "/Users/hoop/Desktop/hoops_stuff/VCF_data/prior_association/associations2/my_associations2_ensembl_ids.csv", row.names = FALSE)

# Extract and write the 'entrez_ids' slot to a CSV file
entrez_ids_df <- my_associations2@entrez_ids
write.csv(entrez_ids_df, "/Users/hoop/Desktop/hoops_stuff/VCF_data/prior_association/associations2/my_associations2_entrez_ids.csv", row.names = FALSE)



####################### combine data ### dont need
library(dplyr)

##PA_gwas_data <- read.csv("/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC_GT_LP_AF_ES_COLOC_H0_H4_H4_annovar.csv")

# Assuming 'snp' is the column name in gwas_data
# and 'snp' is the column name in ncbi_data
##combined_data <- inner_join(PA_gwas_data, my_associations2@risk_alleles, by = c("snp" = "variant_id"))




##################### get associations (get associated genes of the variants) #### find out traits in end

# Initialize a list to store the results
snp_associations <- list()

# Loop through each variant ID
for (variant in variant_ids) {
  # Attempt to get associations for the variant, handling errors gracefully
  result <- tryCatch({
    get_associations(variant_id = variant, warnings = FALSE)
  }, error = function(e) {
    NA  # Return NA in case of an error
  })
  
  # Store the individual result in the list under the variant ID
  snp_associations[[variant]] <- result
}

# Initialize an empty list to store association_ids for all variants
all_association_ids <- list()

# Loop through each variant in FVC_associations
for(variant in names(snp_associations)) {
  # Extract association_ids for the current variant
  association_ids <- snp_associations[[variant]]@associations[["association_id"]]
  
  # Store the extracted association_ids in the list
  all_association_ids[[variant]] <- association_ids
}


# Initialize an empty list to store traits for all associations
GWAS_associated_traits <- list()

# Loop through each variant in all_association_ids
for(variant in names(all_association_ids)) {
  # Retrieve the list of association IDs for the current variant
  association_ids <- all_association_ids[[variant]]
  
  # Initialize a list to store traits for the current variant
  variant_traits <- list()
  
  # Loop through each association ID for the current variant
  for(association_id in association_ids) {
    # Use tryCatch to handle any errors gracefully, such as if get_traits does not return any result for an association_id
    traits <- tryCatch({
      get_traits(association_id = association_id)
    }, error = function(e) {
      NA  # Return NA or an appropriate value in case of an error
    })
    
    # Store the traits in the list for the current variant
    variant_traits[[association_id]] <- traits
  }
  
  # Store the traits for the current variant in the GWAS_associated_traits list
  GWAS_associated_traits[[variant]] <- variant_traits
}



########### download
library(dplyr)
library(tibble)

# Assuming 'GWAS_associated_traits' is your list of traits associated with SNPs
snp_trait_df <- do.call(rbind, lapply(names(GWAS_associated_traits), function(snp) {
  # For each SNP, iterate over its associated traits and create a dataframe
  traits <- lapply(GWAS_associated_traits[[snp]], function(traits_obj) {
    if (!is.null(traits_obj@traits)) {
      data.frame(snp = snp, trait = traits_obj@traits$trait, stringsAsFactors = FALSE)
    } else {
      NULL
    }
  })
  
  # Combine the traits dataframes for this SNP into a single dataframe
  do.call(rbind, traits)
})) %>%
  as_tibble() # Convert the result to a tibble for easier handling

# Write the combined SNP and trait dataframe to a CSV file
write.csv(snp_trait_df, "/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC_GT_LP_AF_ES_COLOC_H0_H4_H4_PA.csv", row.names = FALSE)


################### combine associations and coloc results
library(dplyr)
library(tidyr)

# Assuming 'snp_trait_df' and 'PA_gwas_data' are your dataframes

# Group by 'snp' and concatenate the 'trait' values into a single string
snp_traits_combined <- snp_trait_df %>%
  group_by(snp) %>%
  summarise(traits_combined = paste(trait, collapse = ";"))

# Perform a left join to keep all SNPs from 'PA_gwas_data', even if there's no match in 'snp_traits_combined'
merged_PA_data <- merge(PA_gwas_data, snp_traits_combined, by = "snp", all.x = TRUE)

# Replace NA values in 'traits_combined' column with "."
merged_PA_data <- replace_na(merged_PA_data, list(traits_combined = "."))

# Identify character columns
char_columns <- sapply(merged_PA_data, is.character)

# Replace commas with semicolons in all character columns
merged_PA_data[char_columns] <- lapply(merged_PA_data[char_columns], function(x) gsub(",", ";", x))

# View the resulting dataframe
print(merged_PA_data)

# Write the combined dataframe to a CSV file
write.csv(merged_PA_data, "/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC_GT_LP_AF_ES_COLOC_H0_H4_H4_PA_ANNOVAR.csv", row.names = FALSE, quote = FALSE)

view()