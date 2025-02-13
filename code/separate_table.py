import pandas as pd

# Replace 'your_file.txt' with the path to your tab-delimited file
file_path = '/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC_GT.txt'

# Read the tab-delimited file
df = pd.read_csv(file_path, sep='\t')

print(df.head())  # Check the initial DataFrame

# Assuming 'your_column' is the name of the column you want to split
# This will create a new DataFrame with each part of the split in a separate column
split_df = df['UKB-a-336'].str.split(':', expand=True)

# You can rename the columns of split_df as needed, for example:
split_df.columns = ['ES', 'SE', 'LP', 'AF', 'SS', 'ID', 'GT']

# Concatenate the new columns to the original DataFrame (optional)
# This adds the split columns to your original DataFrame
df = pd.concat([df, split_df], axis=1)

# Alternatively, you might want to replace the original column with the split columns
# For this, you can drop the original column and then concatenate
# df.drop('your_column', axis=1, inplace=True)

# Save the modified DataFrame back to a new tab-delimited file if needed
df.to_csv('/Users/hoop/Desktop/hoops_stuff/VCF_data/manhattan_data2', sep='\t', index=False)

print(split_df.head())  # Check the DataFrame after splitting
