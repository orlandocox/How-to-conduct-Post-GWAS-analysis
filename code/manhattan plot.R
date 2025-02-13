# manhattan plot creation

#install and library package
library(tidyverse)
library(ggplot2)
library(dplyr)
library(ggrepel)



manhattan_data_LP <- read.table(header = FALSE, "/Users/hoop/Desktop/hoops_stuff/VCF_data/manhattan_stuff/FVC_GT_LP_MH_TB.txt")

names(manhattan_data_LP)[names(manhattan_data_LP) == "V1"] <- "CHR"
names(manhattan_data_LP)[names(manhattan_data_LP) == "V2"] <- "BP"
names(manhattan_data_LP)[names(manhattan_data_LP) == "V3"] <- "SNP"
names(manhattan_data_LP)[names(manhattan_data_LP) == "V4"] <- "ref"
names(manhattan_data_LP)[names(manhattan_data_LP) == "V5"] <- "alt"
names(manhattan_data_LP)[names(manhattan_data_LP) == "V6"] <- "QUAL"
names(manhattan_data_LP)[names(manhattan_data_LP) == "V7"] <- "FILTER"
names(manhattan_data_LP)[names(manhattan_data_LP) == "V8"] <- "INFO"
names(manhattan_data_LP)[names(manhattan_data_LP) == "V11"] <- "ES"
names(manhattan_data_LP)[names(manhattan_data_LP) == "V12"] <- "SE"
names(manhattan_data_LP)[names(manhattan_data_LP) == "V13"] <- "lp_gwas"
names(manhattan_data_LP)[names(manhattan_data_LP) == "V14"] <- "af"
names(manhattan_data_LP)[names(manhattan_data_LP) == "V15"] <- "N"
names(manhattan_data_LP)[names(manhattan_data_LP) == "V16"] <- "id.2"
names(manhattan_data_LP)[names(manhattan_data_LP) == "V17"] <- "gt" 

manhattan_data_LP$P <- 10^(-manhattan_data_LP$lp_gwas)

FVC_GT_LP_AF_ES_COLOC_H0_H4_H4_PA_ANNOVAR <- read.csv(header = TRUE, "/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC_GT_LP_AF_ES_COLOC_H0_H4_H4_PA_ANNOVAR.csv")

# Merge the gene names into your main SNP dataset based on the SNP rsID
manhattan_data_LP <- manhattan_data_LP %>%
  left_join(FVC_GT_LP_AF_ES_COLOC_H0_H4_H4_PA_ANNOVAR %>%
              select(snp, Gene_refGene_x = Gene.refGene.x), 
            by = c("SNP" = "snp"))

# Assuming all necessary libraries are loaded and you've corrected variable names
# Ensure you've calculated BPcum correctly here before this step


# Assuming manhattan_data_LP is already loaded and CHR and BP columns are correctly set
manhattan_data_LP <- manhattan_data_LP %>%
  # Calculate the max BP for each chromosome, which will give the length of each chromosome
  group_by(CHR) %>%
  mutate(chr_len = max(BP)) %>%
  ungroup() %>%
  # Calculate the cumulative sum of the chromosome lengths to use as an offset for each chromosome
  # This ensures each chromosome starts right after the previous one ends in the plot
  mutate(chr_start = match(CHR, unique(CHR))) %>%
  mutate(tot = cumsum(as.numeric(chr_len[match(CHR, unique(CHR))]))) %>%
  # Adjust the BP position to be cumulative across chromosomes
  mutate(BPcum = BP + tot - chr_len) %>%
  select(-chr_len, -tot, -chr_start) # Clean up by removing temporary columns

# Now your manhattan_data_LP has a BPcum column for plotting


# Convert logarithm of p-values to actual p-values (assuming this is the right transformation based on your context)
manhattan_data_LP$P <- 10^(-manhattan_data_LP$lp_gwas)

# Calculate the max BP for each chromosome and cumulative sums for BP position adjustment
manhattan_data_LP <- manhattan_data_LP %>%
  group_by(CHR) %>%
  mutate(chr_len = max(BP)) %>%
  ungroup() %>%
  mutate(chr_start = match(CHR, unique(CHR))) %>%
  mutate(tot = cumsum(as.numeric(chr_len[match(CHR, unique(CHR))]))) %>%
  mutate(BPcum = BP + tot - chr_len) %>%
  group_by(CHR) %>%
  mutate(chr_mid = mean(BPcum)) %>%  # Calculate midpoints for chromosome labels
  ungroup() %>%
  select(-chr_len, -tot, -chr_start) # Clean up by removing temporary columns

# Ensure chromosome_midpoints are calculated correctly
chromosome_midpoints <- manhattan_data_LP %>%
  group_by(CHR) %>%
  summarize(mid_bp = mean(BPcum)) %>%
  ungroup()

# Check if the data is not empty and print it for verification
print(chromosome_midpoints)

# Prepare the plot with the correctly set secondary axis
p <- ggplot(filtered_manhattan_data_LP, aes(x = BPcum, y = -log10(P))) +
  geom_point(aes(colour = CHR), alpha = 0.6, size = 1.5) +
  scale_colour_manual(values = rep(alternate_colors, length.out = length(unique(filtered_manhattan_data_LP$CHR)))) +
  scale_x_continuous(
    name = "BPcum Position, secondary axis = Chromosome Position",  # Describe both axes here
    limits = range(filtered_manhattan_data_LP$BPcum),
    sec.axis = sec_axis(~., breaks = chromosome_midpoints$mid_bp, labels = chromosome_midpoints$CHR)
  ) +
  theme_minimal() +
  labs(y = "-log10(p-value)", title = "Manhattan Plot with Colocalisation Gene Names Highlighted") +
  geom_hline(yintercept = -log10(5e-8), colour = "#e1a692", linetype = "dashed") +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 90, hjust = 1),
    axis.text.x.top = element_text(angle = 0, hjust = 0.5, vjust = 0.5)
  )

# Annotations and final touches
p <- p + geom_point(data = snpsOfInterestData, aes(x = BPcum, y = -log10(P)), color = "#e14b31", size = 2, shape = 4)
p <- p + geom_text_repel(data = snpsOfInterestData,
                         aes(x = BPcum, y = -log10(P), label = Gene_refGene_x), 
                         size = 2.5, 
                         position = position_nudge(y = 0.2),
                         colour = "black")

# Print the plot
print(p)
