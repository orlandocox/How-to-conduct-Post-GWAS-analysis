library(httr)

# Load the CSV file into a DataFrame
g_profiler <- read.csv("/Users/hoop/Desktop/hoops_stuff/VCF_data/gProfiler_hsapiens_04-04-2024_17-29-57.csv")

# Extract the 'converted_alias' column as your list of gene IDs
gene_ids <- g_profiler$converted_alias

# Corrected GraphQL query
query_string <- '
  query target($ensemblId: String!){
    target(ensemblId: $ensemblId) {
      id
      approvedSymbol
      associatedDiseases {
        count
        rows {
          disease {
            id
            name
          }
          score
          datasourceScores {
            componentId: id
            score
          }
        }
      }
    }
  }
'

# Base URL of the GraphQL API endpoint
base_url <- "https://api.platform.opentargets.org/api/v4/graphql"

# Initialize an empty list to store results
results_list <- list()

# Loop through each gene ID and make the POST request
for (gene_id in gene_ids) {
  # Update variables for each gene ID
  variables <- list("ensemblId" = gene_id)
  
  # Construct POST request body with the updated variables for the current gene ID
  post_body <- list(query = query_string, variables = variables)
  
  # Perform the POST request
  r <- POST(url=base_url, body=post_body, encode='json')
  
  # Check for successful response before adding to results
  if (status_code(r) == 200) {
    # Store the result using gene ID as key for easy reference
    results_list[[gene_id]] <- content(r)$data
  } else {
    message("Request failed for gene_id: ", gene_id, "; Status code: ", status_code(r))
  }
}

# Print or process the results stored in results_list
print(results_list)














library(dplyr)
library(tidyr)

# Initialize an empty data frame to collect the results
results_df <- data.frame(gene_id = character(),
                         approved_symbol = character(),
                         disease_id = character(),
                         disease_name = character(),
                         score = numeric(),
                         stringsAsFactors = FALSE)

# Loop through each item in results_list to process and flatten the data
for (gene_id in names(results_list)) {
  gene_data <- results_list[[gene_id]]$target
  
  if (!is.null(gene_data$associatedDiseases$rows) && length(gene_data$associatedDiseases$rows) > 0) {
    # Extract disease data and flatten
    disease_data <- do.call(rbind, lapply(gene_data$associatedDiseases$rows, function(x) {
      tibble(disease_id = x$disease$id,
             disease_name = x$disease$name,
             score = x$score)
    }))
    
    # Add gene information
    disease_data <- disease_data %>%
      mutate(gene_id = gene_id,
             approved_symbol = gene_data$approvedSymbol)
    
    # Bind to the results dataframe
    results_df <- bind_rows(results_df, disease_data)
  }
}

# Ensure all rows have the same structure
results_df <- results_df %>%
  select(gene_id, approved_symbol, disease_id, disease_name, score) # Reorder if necessary

# Print or further process results_df
print(results_df)



# Optionally, you might want to reorder the columns
results_df <- results_df[, c("gene_id", "approved_symbol", "disease_id", "disease_name", "score")]

# Write the data frame to a CSV file
write.csv(results_df, "/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC_GT_LP_AF_ES_COLOC_H0_H4_H4_ANNOVAR_PA_OT.csv", row.names = FALSE)

# Output a message
cat("Results saved to /Users/hoop/Desktop/hoops_stuff/VCF_data/OpenTargets_Gene_Disease_Associations.csv\n")
