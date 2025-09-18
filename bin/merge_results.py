#! /usr/bin/env python
import os
import argparse
import pandas as pd

#this file merges the results from StrainScan outputs
#concatenating all input files and adding a column with the sample ID
#sample is extracted from the filename assuming the format sampleID.txt
def merge_results(input_files, output_file):
    merged_df = pd.DataFrame()
    for file in input_files:
        sample_id = os.path.basename(file).split('.')[0]
        df = pd.read_csv(file, sep='\t')
        df['sample_id'] = sample_id
        merged_df = pd.concat([merged_df, df])
    merged_df.to_csv(output_file, sep='\t', index=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Merge StrainScan results")
    parser.add_argument('-i', '--input', nargs='+', required=True, help="Input StrainScan result files")
    parser.add_argument('-o', '--output', required=True, help="Output merged file")
    args = parser.parse_args()
    merge_results(args.input, "strainscan_merged.tsv")
