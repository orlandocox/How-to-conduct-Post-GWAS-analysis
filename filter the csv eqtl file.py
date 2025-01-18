import pandas as pd

# Path to your CSV file
file_path = '/Users/hoop/Desktop/hoops_stuff/VCF_data/QTD000271.all.csv'
# Path for the filtered file to be saved
filtered_file_path = '/Users/hoop/Desktop/hoops_stuff/VCF_data/QTD000271_filtered.all.csv'

# Read the CSV file
df = pd.read_csv(file_path)

# Filter the DataFrame where 'pvalue' is less than or equal to 0.05
filtered_df = df[df['pvalue'] <= 0.05]

# Save the filtered DataFrame to a new CSV file
filtered_df.to_csv(filtered_file_path, index=False)

print(f"Filtered data saved to {filtered_file_path}")
