#!/usr/bin/env python3

import argparse
import os
import pandas as pd

def main():
    parser = argparse.ArgumentParser(description="Subset a recombination rate map by chromosome and annotation range.")
    parser.add_argument('--CHR', required=True, help='Chromosome identifier')
    parser.add_argument('--FullRateMapName', required=True, help='Filename for the full rate map')
    parser.add_argument('--AnnotationName', required=True, help='Filename for the subsetted annotation map')
    parser.add_argument('--RateMapName', required=True, help='Filename for the output rate map')
    parser.add_argument('--replicate_dir', required=True, help='Directory to save the output files')
    parser.add_argument('--InDir', required=True, help='Input directory containing the map files')
    args = parser.parse_args()

    # -------------------------------------------------------------------------
    # 1) Read the Full Rate Map (space-separated) and subset by --CHR
    # -------------------------------------------------------------------------
    full_rate_map_path = os.path.join(args.InDir, args.FullRateMapName)
    FullRateMapDF = pd.read_csv(
        full_rate_map_path,
        delim_whitespace=True,  # Because the file is space-separated
        header=0  # Assumes the file has a header row
    )

    # -------------------------------------------------------------------------
    # 2) Read the Annotation file (tab-separated) and find first_start, first_end
    # -------------------------------------------------------------------------
    annotation_path = args.AnnotationName
    AnnotationDF = pd.read_csv(
        annotation_path,
        sep='\t',
        header=0  # Assumes the file has a header row: chrom, start, end, size, type
    )

    # Extract "first_start" and "first_end" from the annotation
    first_start = AnnotationDF['start'].iloc[0]
    first_end   = AnnotationDF['end'].iloc[-1]

    # -------------------------------------------------------------------------
    # 3) Find RecStart and RecEnd in FullRateMapDF
    #    RecStart = 1 minus the index of the first row where position > first_start
    #    RecEnd   = the index of the first row where position > first_end
    # -------------------------------------------------------------------------
    # Find index of the first row where position > first_start
    RecStart_index = FullRateMapDF[FullRateMapDF['position'] > first_start].index
    if len(RecStart_index) == 0:
        # If no row exceeds first_start, set RecStart to 0 by default
        RecStart = 0
    else:
        RecStart = RecStart_index[0] - 1
        if RecStart < 0:
            RecStart = 0  # Ensure we don’t go negative

    # Find index of the first row where position > first_end
    RecEnd_index = FullRateMapDF[FullRateMapDF['position'] > first_end].index
    if len(RecEnd_index) == 0:
        # If no row exceeds first_end, set RecEnd to the last row
        RecEnd = FullRateMapDF.index[-1]
    else:
        RecEnd = RecEnd_index[0]

    # -------------------------------------------------------------------------
    # 4) Subset the rows RecStart:RecEnd (inclusive) and write out
    # -------------------------------------------------------------------------
    # In pandas .iloc slicing, the stop index is exclusive, so add 1 to include RecEnd
    subsetDF = FullRateMapDF.iloc[RecStart:RecEnd + 1].copy()

    # Ensure output directory exists
    os.makedirs(args.replicate_dir, exist_ok=True)

    # Write the subsetted rate map (tab-separated) with the same header
    out_rate_map_path = os.path.join(args.replicate_dir, args.RateMapName)
    subsetDF.to_csv(out_rate_map_path, sep=' ', index=False)

    print(f"Subsetted recombination map written to: {out_rate_map_path}")

if __name__ == "__main__":
    main()
