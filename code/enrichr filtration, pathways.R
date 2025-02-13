reactome_enrichr <- read.delim("/Users/hoop/Downloads/Reactome_2022_table.txt", header = TRUE, fill = TRUE)
wikipathway_enrichr <- read.delim("/Users/hoop/Downloads/WikiPathway_2023_Human_table.txt", header = TRUE, fill = TRUE)
kegg_enrichr <- read.delim("/Users/hoop/Downloads/KEGG_2021_Human_table.txt", header = TRUE, fill = TRUE)

# Assuming the p-value column is named 'p.value', adjust if it's named differently

# Filter Reactome data by p-value
reactome_enrichr_filtered <- subset(reactome_enrichr, P.value < 0.05)

# Filter WikiPathway data by p-value
wikipathway_enrichr_filtered <- subset(wikipathway_enrichr, P.value < 0.05)

# Filter KEGG data by p-value
kegg_enrichr_filtered <- subset(kegg_enrichr, P.value < 0.05)



#filter by combined p-value of 0.05
# Filter Reactome data by p-value
reactome_enrichr_filtered_filtered <- subset(reactome_enrichr, Adjusted.P.value < 0.05)

# Filter WikiPathway data by p-value
wikipathway_enrichr_filtered_filtered <- subset(wikipathway_enrichr, Adjusted.P.value < 0.05)

# Filter KEGG data by p-value
kegg_enrichr_filtered_filtered <- subset(kegg_enrichr, Adjusted.P.value < 0.05)




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
reactome_enrichr_filtered_filtered <- addSourceColumn(reactome_enrichr_filtered_filtered, 'reactome_enrichr')
wikipathway_enrichr_filtered_filtered <- addSourceColumn(wikipathway_enrichr_filtered_filtered, 'wikipathway_enrichr')
kegg_enrichr_filtered_filtered <- addSourceColumn(kegg_enrichr_filtered_filtered, 'kegg_enrichr')

# Now you can merge your datasets as before
all_pathway_enrichr_data <- rbind(reactome_enrichr_filtered_filtered,
                                      wikipathway_enrichr_filtered_filtered,
                                      kegg_enrichr_filtered_filtered)
                                      