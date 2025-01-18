library(httr)
library(jsonlite)

# Assuming open_targets is your loaded CSV with approved symbols
open_targets <- read.csv("/Users/hoop/Desktop/hoops_stuff/VCF_data/OpenTargets_Gene_Disease_Associations.csv")
gene_ids <- unique(open_targets$approved_symbol)

# Base URL of the DGIdb GraphQL API endpoint
base_url <- "https://dgidb.org/api/graphql"

# Initialize an empty list to store results
results_list <- list()

# Loop through each gene ID to query gene-drug interactions
for (gene_id in gene_ids) {
  # Dynamically construct the query string with the current gene ID
  query_string <- sprintf('
    {
      genes(names: ["%s"]) {
        nodes {
          interactions {
            drug {
              name
              conceptId
            }
            interactionScore
            interactionTypes {
              type
              directionality
            }
            interactionAttributes {
              name
              value
            }
            publications {
              pmid
            }
            sources {
              sourceDbName
            }
          }
        }
      }
    }', gene_id)
  
  # Construct the POST request body with the query string
  post_body <- list(query = query_string)
  
  # Make the POST request
  r <- POST(url = base_url, body = post_body, encode = "json")
  
  # Check for a successful response before adding to results
  if (status_code(r) == 200) {
    # Parse the JSON response and add to the results list, using the gene_id as the key
    results_list[[gene_id]] <- fromJSON(rawToChar(r$content))
  } else {
    message("Request failed for gene_id: ", gene_id, "; Status code: ", status_code(r))
  }
}

# After querying, process results_list as needed









extract_interactions <- function(list, parent_name = NA) {
  # This function will store each gene's name and its interactions (if any)
  extracted_data <- data.frame(GeneName = character(), Interactions = character(), stringsAsFactors = FALSE)
  
  # Check if the current list element is the target data
  if ("interactions" %in% names(list)) {
    # If 'interactions' is present, add its content to the dataframe
    new_row <- data.frame(GeneName = parent_name, Interactions = toString(list$interactions), stringsAsFactors = FALSE)
    extracted_data <- rbind(extracted_data, new_row)
  } else {
    # If 'interactions' is not found, continue searching in the nested lists
    for (name in names(list)) {
      if (is.list(list[[name]])) {
        extracted_data <- rbind(extracted_data, extract_interactions(list[[name]], name))
      }
    }
  }
  
  return(extracted_data)
}


# Assuming 'results_list' is your nested list
results_data <- extract_interactions(results_list)

# Check the first few rows to ensure it looks as expected
head(results_data)
