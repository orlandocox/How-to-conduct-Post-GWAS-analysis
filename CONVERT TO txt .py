import gzip

# Input VCF.gz file and output text file
input_vcf_gz = '/Users/hoop/Desktop/hoops_stuff/VCF_data/manhattan_stuff/FVC_GT_LP_MH.vcf.gz'
output_txt = '/Users/hoop/Desktop/hoops_stuff/VCF_data/manhattan_stuff/FVC_GT_LP_MH.txt'

# Open the compressed VCF file
with gzip.open(input_vcf_gz, 'rt') as vcf_file:
    # Open the output text file for writing
    with open(output_txt, 'w') as txt_file:
        # Copy the content from the VCF file to the text file
        for line in vcf_file:
            txt_file.write(line)

print("Conversion complete.")
