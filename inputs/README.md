This sub-directory contains data files required for input into simulations

IMPORTANT The following file must be downloaded and placed in the `/inputs` 
sub-directory prior to running this code:
https://alkesgroup.broadinstitute.org/Eagle/downloads/tables/genetic_map_hg19_withX.txt.gz

`non_overlapping_full_span_partition.tsv` Tab-separated file of UCSC Genome Browser (GENCODE_V47lift37 annotations), preprocessed according 
to the methods described in SUPPLEMENTARY INFORMATION SECTION 2 > SIMULATION OF EUROPEAN DEMOGRAPHIC HISTORY > Mutations

`PopulationSizes.csv` File describing the sizes of each sub-population. See the description of the --PopulationSizesName flag in 
~/slim-selection-simulations/scripts for more information.

`Chr*Recombination.txt` Per-chromosome recombination files extracted from genetic_map_hg19_withX.txt.gz
