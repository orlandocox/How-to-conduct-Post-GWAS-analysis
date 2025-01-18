import gzip

def modify_and_compress_vcf(input_file, output_file):
    print(f"Input file: {input_file}")
    print(f"Output file: {output_file}")

    with gzip.open(input_file, 'rt') as infile, gzip.open(output_file, 'wt') as outfile:
        for line in infile:
            # Print header lines starting with '#'
            if line.startswith('#'):
                print(line.strip())
                outfile.write(line)
            else:
                columns = line.strip().split('\t')
                # Check if there are at least 10 columns
                if len(columns) >= 10:
                    columns[8] += ':GT'  # Add ':GT' to column 9
                    columns[9] += ':1|1'  # Add ':1|1' to column 10
                    outfile.write('\t'.join(columns) + '\n')
                else:
                    print(f'Skipping line with fewer than 10 columns: {line.strip()}')
                    outfile.write(line)

# Call the function with your input and output file paths
modify_and_compress_vcf('/Users/hoop/Desktop/hoops_stuff/VCF_data/FVC.vcf.gz', '/Users/hoop/Desktop/hoops_stuff//VCF_data/FVC_GT.vcf.gz')
