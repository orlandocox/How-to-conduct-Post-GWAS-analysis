############################################################################################# SET UP

#installing DisGeNET2R
install.packages("devtools")

#loading in devtools
library(devtools)

#installing disgenet2r
install_bitbucket("ibi_group/disgenet2r")

#load in disgent2r
library(disgenet2r)

#disgent2r key 
disgenet_api_key <- get_disgenet_api_key(
  email = "orlandocox1@hotmail.com", 
  password = "Hoopster729Pumbas2507&" )

#disgenet2r key for all functions
Sys.setenv(DISGENET_API_KEY= disgenet_api_key)

# path to .txt variants file
variants_data <- readLines("/Users/hoop/Desktop/hoops_stuff/VCF_data/ukb-a-336_GT_corrected_LP_ES_AF_filtered_rsID_only.txt")

#see head of variants123
head(variants_data)

############################################################################################# DEVIDE AND RUN VARIANTS

# Function to divide data into batches
split_into_batches <- function(data, batch_size) {
  split(data, ceiling(seq_along(data)/batch_size))
}

# Splitting your variants into batches of a specific size
batch_size <- 300  # Adjust batch size as needed
variants_batches <- split_into_batches(variants_data, batch_size)

# Initialize an empty list to store results from each batch
all_results <- list()

# Loop through each batch and run the query
for (i in seq_along(variants_batches)) {
  batch_result <- variant2disease(
    variant = variants_batches[[i]],
    database = "ALL"
  )
  all_results[[i]] <- batch_result
  Sys.sleep(0)  # Pause to avoid rate limits, adjust as necessary
}

############################################################################################# COMBINE DATA

# Initialize an empty list to store the data frames extracted from each 'qresult' slot
extracted_data <- list()

# Loop through each DataGeNET.DGN object to extract the 'qresult' slot
for(i in 1:length(all_results)) {
  # Extract the 'qresult' slot, which presumably contains the query results
  current_data <- all_results[[i]]@qresult
  
  # Assuming 'current_data' is a data frame or can be treated as such; add it to the list
  extracted_data[[i]] <- current_data
}

# Combine all extracted data frames into one
combined_data <- do.call(rbind, extracted_data)

############################################################################################# GRAPHS


# Network graph [['insert dataset']]
plot (all_results[[1]],
      class = "Network",
      prop = 10,
      showGenes = T)

# Heatmap graph [['insert dataset']] NOT FUNCTIONAL
plot (all_results[[2]],
      class = "Heatmap",
      prop = 10)

# disease class graph [['insert dataset']] NOT FUNCTIONAL
plot (all_results[[7]],
      class = "DiseaseClass",)

############################################################################################# GRAPH IN GGPLOT2

# install packages
install.packages(c("igraph", "ggraph", "ggplot2"))

# load packages
library(igraph)
library(ggraph)
library(ggplot2)

############################################################################################# MAKE GRAPH

# Correcting the command to create a new data frame or subset from an existing one
data_subset_ggplot2 <- data.frame(
  variant_id = combined_data$variantid, 
  gene_symbol = combined_data$gene_symbol, 
  disease_name = combined_data$disease_name
)

# clean data by removing NA
data_subset_clean <- na.omit(data_subset_ggplot2)

############################################################################################# SPECIFIC DISEASE

# Filter the cleaned data to only include rows with 'disease_name' == 'Disease Name'
specific_disease_data <- data_subset_clean[data_subset_clean$disease_name == 'Vital capacity', ] #adjust specific disease measured

# Create the edge list from the filtered data
edges_specific_disease <- rbind(
  data.frame(from = specific_disease_data$variant_id, to = specific_disease_data$gene_symbol),
  data.frame(from = specific_disease_data$gene_symbol, to = specific_disease_data$disease_name)
)

# Create the igraph graph object from the edge list of the filtered data
graph_specific_disease <- graph_from_data_frame(edges_specific_disease, directed = FALSE)

# Example of adding a "type" attribute to each node
V(graph_specific_disease)$type <- ifelse(V(graph_specific_disease)$name %in% specific_disease_data$variant_id, 'variant_id',
                                         ifelse(V(graph_specific_disease)$name %in% specific_disease_data$gene_symbol, 'gene_symbol', 'disease_name'))

# make specific disease graph
ggraph(graph_specific_disease, layout = 'fr') +
  geom_edge_link() +
  geom_node_point() +
  geom_node_text(aes(label = name), repel = TRUE, check_overlap = TRUE) +
  theme_graph()

