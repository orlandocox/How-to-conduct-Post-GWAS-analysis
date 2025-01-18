import pandas as pd

# Step 1: Read the tab-delimited .txt file
txt_df = pd.read_csv('/Users/hoop/Desktop/hoops_stuff/VCF_data/ukb-a-336_GT_corrected_LP_ES_AF_filtered.txt', delimiter='\t')
# Assuming 'ID' is the column with rsID values in the .txt file
ids_to_filter = txt_df['ID'].unique()  # Get unique IDs to filter by

# Step 2: Read the .csv file
csv_df = pd.read_csv('/Users/hoop/Desktop/hoops_stuff/VCF_data/QTD000271.all.csv')
# Assuming 'rsid' is the column in the .csv file

# Step 3: Filter the .csv DataFrame
filtered_csv_df = csv_df[csv_df['rsid'].isin(ids_to_filter)]

# Step 4: Save the filtered DataFrame to a new .csv file
filtered_csv_df.to_csv('/Users/hoop/Desktop/hoops_stuff/VCF_data/filtered_csv_file.csv', index=False)
