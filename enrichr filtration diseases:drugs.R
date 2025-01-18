#load files
clinvar_enrichr <- read.delim("/Users/hoop/Downloads/ClinVar_2019_table.txt", header = TRUE, fill = TRUE)
phengen_enrichr <- read.delim("/Users/hoop/Downloads/PhenGenI_Association_2021_table.txt", header = TRUE, fill = TRUE)
gwas_catalog_enrichr <- read.delim("/Users/hoop/Downloads/GWAS_Catalog_2023_table.txt", header = TRUE, fill = TRUE)
uk_biobank_enrichr <- read.delim("/Users/hoop/Downloads/UK_Biobank_GWAS_v1_table.txt", header = TRUE, fill = TRUE)
disgenet_enrichr <- read.delim("/Users/hoop/Downloads/DisGeNET_table.txt", header = TRUE, fill = TRUE)
dbgap_enrichr <- read.delim("/Users/hoop/Downloads/dbGaP_table.txt", header = TRUE, fill = TRUE)
autorif_enrichr <- read.delim("/Users/hoop/Downloads/Rare_Diseases_AutoRIF_Gene_Lists_table.txt", header = TRUE, fill = TRUE)
gedipnet_enrichr <- read.delim("/Users/hoop/Downloads/GeDiPNet_2023_table.txt", header = TRUE, fill = TRUE)
omim_enrichr <- read.delim("/Users/hoop/Downloads/OMIM_Disease_table.txt", header = TRUE, fill = TRUE)

#filter files
autorif_enrichr_filtered <- subset(autorif_enrichr, P.value < 0.05)
clinvar_enrichr_filtered <- subset(clinvar_enrichr, P.value < 0.05)
dbgap_enrichr_filtered <- subset(dbgap_enrichr, P.value < 0.05)
disgenet_enrichr_filtered <- subset(disgenet_enrichr, P.value < 0.05)
gedipnet_enrichr_filtered <- subset(gedipnet_enrichr, P.value < 0.05)
gwas_catalog_enrichr_filtered <- subset(gwas_catalog_enrichr, P.value < 0.05)
omim_enrichr_filtered <- subset(omim_enrichr, P.value < 0.05)
phengen_enrichr_filtered <- subset(phengen_enrichr, P.value < 0.05)
uk_biobank_enrichr_filtered <- subset(uk_biobank_enrichr, P.value < 0.05)

#filter files 2
autorif_enrichr_filtered_filtered <- subset(autorif_enrichr_filtered, Adjusted.P.value < 0.05)
clinvar_enrichr_filtered_filtered <- subset(clinvar_enrichr_filtered, Adjusted.P.value < 0.05)
dbgap_enrichr_filtered_filtered <- subset(dbgap_enrichr_filtered, Adjusted.P.value < 0.05)
disgenet_enrichr_filtered_filtered <- subset(disgenet_enrichr_filtered, Adjusted.P.value < 0.05)
gedipnet_enrichr_filtered_filtered <- subset(gedipnet_enrichr_filtered, Adjusted.P.value < 0.05)
gwas_catalog_enrichr_filtered_filtered <- subset(gwas_catalog_enrichr_filtered, Adjusted.P.value < 0.05)
omim_enrichr_filtered_filtered <- subset(omim_enrichr_filtered, Adjusted.P.value < 0.05)
phengen_enrichr_filtered_filtered <- subset(phengen_enrichr_filtered, Adjusted.P.value < 0.05)
uk_biobank_enrichr_filtered_filtered <- subset(uk_biobank_enrichr_filtered, Adjusted.P.value < 0.05)

# Safe method to add a source column even if the dataset is empty
addSourceColumn <- function(df, sourceName) {
  if (nrow(df) == 0) { # Check if the dataframe is empty
    df <- data.frame(Source = character()) # Create a dataframe with a Source column only
    df[1, "Source"] <- sourceName # Assign the source name to the first row, creating an empty row
    df <- df[0,] # Remove the empty row, but keep the column structure
  } else {
    df$Source <- sourceName # Add the source column as usual
  }
  return(df)
}

# Apply the function to each filtered dataset
autorif_enrichr_filtered_filtered <- addSourceColumn(autorif_enrichr_filtered_filtered, 'autorif_enrichr')
clinvar_enrichr_filtered_filtered <- addSourceColumn(clinvar_enrichr_filtered_filtered, 'clinvar_enrichr')
dbgap_enrichr_filtered_filtered <- addSourceColumn(dbgap_enrichr_filtered_filtered, 'dbgap_enrichr')
disgenet_enrichr_filtered_filtered <- addSourceColumn(disgenet_enrichr_filtered_filtered, 'disgenet_enrichr')
gedipnet_enrichr_filtered_filtered <- addSourceColumn(gedipnet_enrichr_filtered_filtered, 'gedipnet_enrichr')
gwas_catalog_enrichr_filtered_filtered <- addSourceColumn(gwas_catalog_enrichr_filtered_filtered, 'gwas_catalog_enrichr')
omim_enrichr_filtered_filtered <- addSourceColumn(omim_enrichr_filtered_filtered, 'omim_enrichr')
phengen_enrichr_filtered_filtered <- addSourceColumn(phengen_enrichr_filtered_filtered, 'phengen_enrichr')
uk_biobank_enrichr_filtered_filtered <- addSourceColumn(uk_biobank_enrichr_filtered_filtered, 'uk_biobank_enrichr')

# Now you can merge your datasets as before
all_diseasedrug_enrichr_data <- rbind(autorif_enrichr_filtered_filtered,
                          clinvar_enrichr_filtered_filtered,
                          dbgap_enrichr_filtered_filtered,
                          disgenet_enrichr_filtered_filtered,
                          gedipnet_enrichr_filtered_filtered,
                          gwas_catalog_enrichr_filtered_filtered,
                          magma_enrichr_filtered_filtered,
                          omim_enrichr_filtered_filtered,
                          phengen_enrichr_filtered_filtered,
                          uk_biobank_enrichr_filtered_filtered)
