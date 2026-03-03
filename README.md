# slim-selection-simulations
SLiM simulations described in sections "Test of selection on single variants", 
"Forward-in-time simulations of selection in the context of European history", 
and SUPPLEMENTARY INFORMATION SECTION 2 of Akbari et al. 2026, Nature

See the README.md files within each sub-directory for full descriptions of its contents

IMPORTANT The following file must be downloaded and placed in the `/inputs` 
sub-directory prior to running this code:
https://alkesgroup.broadinstitute.org/Eagle/downloads/tables/genetic_map_hg19_withX.txt.gz

If all files are correctly set up, then the below command:
~/slim-selection-simulations/scripts/./simulate.sh --ParameterFile Test_ParameterFile.txt --ParameterDir ~/slim-selection-simulations/parameter_files
... should yield the expected output files described under simulate.slim in /scripts/README.md
