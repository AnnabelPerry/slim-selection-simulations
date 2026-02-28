#!/bin/bash
#SBATCH -c 1
#SBATCH --array=1-%REPLICATES%
#SBATCH -t 12:00:00
#SBATCH -p short
#SBATCH --mem=3G
#SBATCH -o simulate_%A.out
#SBATCH -e simulate_%A.err
#SBATCH --mail-type=FAIL,END            # Email notifications for job finishing, regardless of status
#SBATCH --mail-user=Your_email_address

# Change this to your version of GCC
module load gcc/14.2.0

ParameterFile=""
ParameterDir=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -pf|--ParameterFile)
      ParameterFile="$2"
      shift 2
      ;;
    -pd|--ParameterDir)
      ParameterDir="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo -e "\nRunning simulate.slim with these Parameters:"
# Crack parameters from the file
cd ${ParameterDir}
while IFS= read -r line; do
    # Extract parameter name and value
    parameter=$(echo "$line" | cut -d':' -f1)
    value=$(echo "$line" | cut -d':' -f2)
    
    # Remove leading and trailing spaces from the value
    value=$(echo "$value" | sed -e 's/^[ \t]*//')
    
    # Check whether the parameter is empty
    if [ -n "$parameter" ]; then
        # If the parameter is NOT empty, store the value in a variable named 
        # after the parameter
        declare "$parameter=$value"
        # Echo parameter and value
        echo -e "\t $parameter:\t${value}"
    fi
done < "${ParameterFile}"

# Check whether parameter filename has a suffix and. if so, remove so that you
# can use the prefix to name associated files
if [[ "$ParameterFile" == *.txt* ]]; then
    ParameterPrefix="${ParameterFile%%.txt}"
else
    ParameterPrefix="$ParameterFile"
fi
# SLURM Array ID (corresponds to replicate number)
i=$SLURM_ARRAY_TASK_ID

# Generate random seed and naming number
seed=$((RANDOM * 32768 + RANDOM))
NamingNumber=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1)
CHR=$(( RANDOM % 22 + 1 ))

# Create output directory for this replicate
replicate_dir="${OutDir}/NamingNumber${NamingNumber}"
mkdir ${replicate_dir}
# Copy the contents of the parameter file with a descriptive title
ReplicateParameter="${replicate_dir}/NamingNumber${NamingNumber}_ParameterFile.txt"
# Create a key by concatenating the variables
key="${BackgroundSelection}${PositiveSelection}${StabilizingSelection}${DeNovo}"

# Evaluate the conditions using case
case "$key" in
    TTFT)
        echo "MODEL2.2_EXPERIMENTAL Background selection and directional selection on de novo mutation, but no stabilizing selection" > "${ReplicateParameter}"
        ;;
    TFFT)
        echo "MODEL2.2_NEGATIVECONTROL Background selection, but not directional selection or stabilizing selection" > "${ReplicateParameter}"
        ;;
    TTT*)
        echo "MODEL3_EXPERIMENTAL Background selection, stabilizing selection, and directional selection" > "${ReplicateParameter}"
        ;;
    TFT*)
        echo "MODEL3_NEGATIVECONTROL Background selection and stabilizing selection, but not directional selection" > "${ReplicateParameter}"
        ;;
    TTFF)
        echo "MODEL2.1_EXPERIMENTAL Background selection and directional selection on standing mutation, but not stabilizing selection" > "${ReplicateParameter}"
        ;;
    TFFF)
        echo "MODEL2.1_NEGATIVECONTROL Background selection only, neither directional nor stabilizing selection" > "${ReplicateParameter}"
        ;;
    FFT*)
        echo "MODEL1_NEGATIVECONTROL Stabilizing selection only, neither directional nor background selection" > "${ReplicateParameter}"
        ;;
    FTT*)
        echo "MODEL1_EXPERIMENTAL Stabilizing and directional selection, no background selection" > "${ReplicateParameter}"
        ;;
    *)
        echo "No matching condition found." > "${ReplicateParameter}"
        ;;
esac
cat ${ParameterDir}/${ParameterFile} >> ${ReplicateParameter}
# Create annotation map and recombination map

source activate SelectionSimulations
AnnotationName="${replicate_dir}/Annotation_NamingNumber${NamingNumber}.tab"
FullRateMapName="Chr${CHR}Recombination.txt"
RateMapName="Recombination_NamingNumber${NamingNumber}.tab"
python ${ScriptDir}/random_chunk.py \
    -chrom ${CHR} \
    -windowsize ${Window} \
    -out ${AnnotationName} 
python ${ScriptDir}/RecombinationSubsetter.py \
    --CHR "$CHR" \
    --FullRateMapName "$FullRateMapName" \
    --AnnotationName "$AnnotationName" \
    --RateMapName "$RateMapName" \
    --replicate_dir "$replicate_dir" \
    --InDir "$InDir"
conda deactivate
# Log file for parameters which differentiate replicates from eachother
log_file="${OutDir}/${ParameterPrefix}.log"
if [ ! -f "$log_file" ]; then
    echo "Replicate,seed,NamingNumber,CHR,startBP,endBP" > "$log_file"
fi
echo "$i,$seed,$NamingNumber,$CHR,$startBP,$endBP" >> "$log_file"

# Run SLiM simulation
start_time=$(date +%s)
${SLiMDir}/./slim \
        -d seed=${seed} \
        -d StabilizingSelection=${StabilizingSelection} \
        -d PositiveSelection=${PositiveSelection} \
	    -d BackgroundSelection=${BackgroundSelection} \
	    -d DeNovo=${DeNovo} \
        -d PositiveCoeff=${PositiveCoeff} \
	    -d MinDAF=${MinDAF} \
        -d OutputCachedFitness=${OutputCachedFitness} \
        -d NamingNumber="'${NamingNumber}'" \
        -d MUtotal=${MUtotal} \
        -d BurnIn=${BurnIn} \
        -d heritability=${heritability} \
        -d OptimumTraitValue1=${OptimumTraitValue1} \
        -d OptimumTraitValue2=${OptimumTraitValue2} \
        -d ShiftGen=${ShiftGen} \
        -d StandardDeviationOfFitnessFunction=${StandardDeviationOfFitnessFunction} \
        -d Period=${Period} \
        -d Gamma="${Gamma}" \
        -d exponential_mean="${exponential_mean}" \
        -d CHR=${CHR} \
        -d AllTimeTraitMeans=${AllTimeTraitMeans} \
        -d TimeTransectSampleSize=${TimeTransectSampleSize} \
        -d ContemporarySampleSize=${ContemporarySampleSize} \
        -d RR_UNITS=${RR_UNITS} \
        -d AnnotationName="'${AnnotationName}'" \
        -d RateMapName="'${replicate_dir}/${RateMapName}'" \
        -d PopulationSizesName="'${InDir}/${PopulationSizesName}'" \
        -d OutDir="'${replicate_dir}'" \
    ${ScriptDir}/simulate.slim
end_time=$(date +%s)
sim_execution_time=$((end_time - start_time))
echo -e "\n\n====================================\nRuntime for ${ParameterFile}:\n${sim_execution_time}\n====================================\n"
