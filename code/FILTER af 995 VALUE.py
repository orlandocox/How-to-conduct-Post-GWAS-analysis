import gzip
import numpy as np

# Paths to the original and filtered VCF.GZ files
vcf_path = '/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC_GT_LP.vcf.gz'
filtered_vcf_path = '/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC_GT_LP_Az.vcf.gz'

# LP threshold based on the p-value
af_value_threshold = 0.995
af_threshold = af_value_threshold

filtered_variants_count = 0

with gzip.open(vcf_path, 'rt') as original_f, gzip.open(filtered_vcf_path, 'wt') as filtered_f:
    for line in original_f:
        line = line.strip()
        if not line:  # Skip empty lines
            continue
        if line.startswith('#'):
            # Write header lines directly to the new file
            filtered_f.write(line + '\n')
        else:
            parts = line.split('\t')
            if len(parts) < 8:  # Ensure the line has at least 8 fields
                continue  # Skip lines that do not conform to VCF format
            format_parts = parts[8].split(':')
            try:
                af_index = format_parts.index('AF')
                sample_data = parts[9:]
                for sample in sample_data:
                    sample_values = sample.split(':')
                    af_value = float(sample_values[af_index])
                    if af_value < af_threshold:
                        filtered_f.write(line + '\n')  # Write valid variant lines
                        filtered_variants_count += 1
                        break  # Found a sample that passes the filter, no need to check others
            except (ValueError, IndexError):
                continue  # Skip lines with parsing errors or missing af index

print(f"Filtered variants count: {filtered_variants_count}")

# Debug: Print the first 10 lines of the new file to verify
with gzip.open(filtered_vcf_path, 'rt') as f:
    print("First 20 lines of the filtered file:")
    for _ in range(20):
        print(f.readline().strip())
