# Akbari_et_al_2026_Nature_SLiMSimulations
SLiM simulations described in sections "Test of selection on single variants", 
"Forward-in-time simulations of selection in the context of European history", 
and Supplementary Section 2 of Akbari et al. 2026, Nature

/scripts
	Contains scripts for running simulations. Note that all necessary parts of
	the simulation are run as part of the bash script simulate.sh. All other
	scripts in this sub-directory are run as part of simulate.sh.
	
	simulate.sh
        Runs simulation ( simulate.slim ) with gene-annotation map and
        Eyre Walker selection coefficient-trait effect mapping, on a randomly-
        selected genomic segment.
        Below is an example commandline run (assuming the GitHub repository is
		in your Downloads directory)
        `````````````````````     Begin Code Block        `````````````````````` 
        
        BaseDir="~/Downloads"
        ParameterDir="${BaseDir}/Akbari_et_al_2026_Nature_SLiMSimulations/parameter_files"
        ParameterFile="Model1Experimental_ParameterFile.txt"
		ScriptDir="${BaseDir}/Akbari_et_al_2026_Nature_SLiMSimulations/scripts"
        
        sbatch --array=1-100 ${ScriptDir}/simulate.sh \
                            --ParameterFile ${ParameterFile} \
                            --ParameterDir ${ParameterDir}
                       
        ``````````````````````     End Code Block        ``````````````````````` 
        --ParameterDir
            Directory of ${ParameterFile}
            
        --ParameterFile
            File with all parameter names listed under the "Inputs" section of
            `simulate.slim` (except ${seed} and ${NamingNumber}, which are
            randomly generated during execution of this bash script). The upper 
            bound of the --array flag is the count of simulations with the 
            parameters in this file which you would like to run in parallel ( a 
            new ${seed} and ${NamingNumber} will be generated for each replicate)
            The order of parameters does not matter. A log file called 
            ${ParameterFile}.log will be generated in ${ParameterDir} with the
            NamingNumber and seed for each replicate
    
	simulate.slim
        SLiM simulation code. An example run is below, but note this simulation
        is run as part of simulate.sh
        `````````````````````     Begin Code Block        `````````````````````` 
        InDir="/n/groups/reich/anp9168/SelectionProject/InputFiles"
        
        seed=1
        StabilizingSelection=T
        PositiveSelection=F
        BackgroundSelection=F
        DeNovo=F
	    MinDAF=0.05
	    PositiveCoeff=0.01
	    NamingNumber=7
        MUtotal="7.0e-05"
        BurnIn=5
        heritability="0.2"
        OptimumTraitValue1="0.0"
        OptimumTraitValue2="1.0"
        ShiftGen=$((BurnIn + 1500 - 258))
        StandardDeviationOfFitnessFunction=1
        Period=10
        AllTimeTraitMeans="F"
        OutputCachedFitness="F"
        Gamma="c((0.97-1), 0.206)"
        exponential_mean="-5e-4"
        CHR=22
        TimeTransectSampleSize=2
        ContemporarySampleSize=10
        RR_UNITS="'cM/Mb'"
        BMapName="${InDir}/TroubleshootingBGS.bed"
        RateMapName="${InDir}/TroubleshootingRecombination.txt"
        PopulationSizesName="${InDir}/Troubleshooting_PopulationSizes.csv"
        OutDir="/n/groups/reich/anp9168/SelectionProject/GWASEnrichmentSimulation/Troubleshooting"
        ScriptDir="/n/groups/reich/anp9168/SelectionProject/GWASEnrichmentSimulation/Scripts"
        SLiMDir="/n/groups/reich/anp9168/software/SLiM/build"
        
        ${SLiMDir}/./slim \
            -d seed=${seed} \
            -d PositiveSelection=${PositiveSelection} \
            -d StabilizingSelection=${StabilizingSelection} \
            -d BackgroundSelection=${BackgroundSelection} \
            -d DeNovo=${DeNovo} \
            -d MinDAF=${MinDAF} \
            -d PositiveCoeff=${PositiveCoeff} \
	        -d OutputCachedFitness=${OutputCachedFitness} \
            -d NamingNumber="${NamingNumber}" \
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
            -d RateMapName="'${RateMapName}'" \
            -d PopulationSizesName="'${PopulationSizesName}'" \
            -d OutDir="'${OutDir}'" \
            ${ScriptDir}/simulate.slim

        ``````````````````````     End Code Block        ``````````````````````` 
        Inputs:
        --seed
            Specify the random number generator seed
        
        --PositiveSelection
            Logical. If T and StabilizingSelection is T, OptimumTraitValue1 will shift 
	    to OptimumTraitValue2 at ShiftGen, while if BackgroundSelection is T but
	    StabilizingSelection is F then directional selection will be variant-level.
	    If F, niehter a shift in optimum nor a single positive mutation will be 
	    implemented.
            
        --StabilizingSelection
            Logical. If T, OptimumTraitValue1 will indicate optimum fitness value
        
	    --BackgroundSelection
	        Logical. If T, m2 and m3 mutations will be assigned deleterious selection
	        coefficients
	        
	    --DeNovo    
	        Logical. Only used if BackgroundSelection==T, StabilizingSelection==F, and
	        PositiveSelection==T. If T, then a new m4 mutation with coefficient 
	        $PositiveCoeff will be introduced to a nonneutral (coding or 
	        noncoding) region at $ShiftGen and will be re-sampled if it fails to
	        reach $MinDAF. If F, then a single m1 in a nonneutral (coding or 
	        noncoding) region with allele frequency above $MinDAF will be 
	        switched to type m4 and thus assigned selection coefficient 
	        $PositiveCoeff at $ShiftGen
	        
	    --PositiveCoeff
	        Numeric. Only used if BackgroundSelection==T, StabilizingSelection==F, and
	        PositiveSelection==T. Selection coefficient to be assigned to a single
	        mutation ( of category m4 ) at ShiftGen

        --MinDAF
            Numeric. Only used if BackgroundSelection==T, StabilizingSelection==F, 
            and PositiveSelection==T. If DeNovo==F, MinDAF is the minimum allele 
            frequency required for an m1 mutation to be chosen to be assigned 
            PositiveCoeff at ShiftGen. If DeNovo==T, MinDAF is the minimum allele
            frequency the de novo positively-selected mutation must reach before
            its progress is no longer monitored.

        --AllTimeTraitMeans
            Logical. If true, indicates the means and standrd deviations of 
            genetic scores and traits for each subpopulation should be outputted 
            at every single timepoint to the file 
            ${OutDir}/AllTimeTraitMeans_NamingNumber${NamingNumber}.csv. 
            
        --BurnIn
            Specifies the count of generations for which the single ancestral 
            population will exist PRIOR to splitting into two subpopulations. 
        
        --OutputCachedFitness
            Logical indicating whether to output per-individual cachedFitness values
            
        --heritability
            Proportion of variance in phenotypes which should be attributable to 
            genetic differences between individuals
            
	    --OptimumTraitValue1
    	    Mean of the phenotype-to-fitness mapping function.
    	    The simulation starts out with no variation in trait values. That is, 
    	    every individual's trait value is 0. To prevent rapid equilibration 
    	    to a non-0 phenotypic optimum (which may generate spurious signals 
    	    of positive selection), the default optimum trait value should be 0
    	    
    	--OptimumTraitValue2
    	    Optimal trait value after the shift. Note that if PositiveSelection
    	    is set to false, this parameter does nothing
    	    
    	--ShiftGen
    	    Generation at which point positive selection is enacted, either as 
	    a shift in the optimum value of phenotype ( if StabilizingSelection==T )
	    or as the introduction of a positively-selected mutation ( if
	    StabilizingSelection == F )
    	    Note that if PositiveSelection is set to false, this parameter does 
    	    nothing
    	    
    	--StandardDeviationOfFitnessFunction
    	    The standard deviation of the trait-to-fitness mapping normal 
    	    distribution. Every generation, each individual's phenotype value 
    	    will be mapped to its quantile on a normal distribution whose mean 
    	    is the Optimum Trait Value (0), and whose sd is StandardDeviationOfFitnessFunction.
    	    The greater this value, the more distant a phenotype can be from 
    	    the optimum without as great a reduction in phenotype. The lower 
    	    this value, the less distant a phenotype can be from the optimum 
    	    before the fitness of the individual is greatly penalized.
    	    
        --Period
    		VCFs will be outputted periodically starting at 258 generations before 
    		present. This parameter specifies the number of generations 
    		between each VCF output
        
        --PopulationSizesName
            Comma-separated file with two columns and 10 rows, plus the header
            "Populaiton,Sizes". Each row describes a SLiM population's size.
        
        --Gamma
    		The expected value AND shape parameter, in that order, for the gamma 
    		distribution from which selection coefficients for the HIGHLY 
    		deleterious mutation type will be drawn. 
    		
    	--exponential_mean	
    	    Expected value for exponential distribution from which selection
    	    coefficients for the LESS deleterious mtuation type are drawn.
    	    
        --RateMapName
    		The path to the file to be read in as the recombination rate map. Note
    		that this must be surrounded by BOTH double AND single quotes. Note:
    	    at the start of the simulation, the base pairs will be re-indexed 
    	    such that the genome starts at 1bp UPstream of the first gene OR 1bp
    	    UPstream of the first recombination endpoint (whichever comes first)
    	    Also, the base pairs in the "position" column will be re-indexed to
    	    indicate the END of the recombination rate map ( these start as ind-
    	    icating the START of the rate map).
    	    
    	--AnnotationName
    	    Map of genetic annotations, which should be "noncoding", "coding",
    	    or "neutral". "neutral" experience non-trait-influencing, non-fitness-
    	    influencing (neutral) mutations. "noncoding" experience both neutral
    	    mutations and also mutations whose selection coefficients are drawn
    	    from exponential distribution with mean exponential_mean. "coding" 
    	    experience both neutralmutations and also mutations whose selection 
    	    coefficients are drawn from gamma distribution with parameters Gamma.
    	    All trait impacts are calculated by applying Eyre-Walker Model to
    	    selection coefficients.
    	    
        --RR_UNITS
    		The units of recombination rate in the recombination rate map file. 
    		Currently, the code only accepts centiMorgans per MegaBase, "cM/Mb". 
    		Note that this must be surrounded by BOTH double AND single quotes.
    		
        --CHR
    		The chromosome you would like to simulate.
    		
        --MUtotal
    		Summed mutation rate across all three mutation categories. Category-
    		specific mutation rates will be computed using MUtotal, polygenicity,
    		and ExpectedB. Must be in quotes and scientific notation.
    	
        --TimeTransectSampleSize
    		The count of individuals to be outputted during the periodic VCF outputs
    	
        --ContemporarySampleSize
    		The count of individuals to be outputted at end of simulation
    	        
    	--SLiMDir
    	    Directory in which the SLiM executable is stored. This should just be
    	    the directory to the folder titled 'SLiM' - the code will automatically
    	    route to the 'SLiM/build/slim' subdirectory in which the exectuable 
    	    should be found
    	
    	--InDir
    	    Directory from which input files should be obtained
    	
    	--OutDir
    	    Directory into which output files should be directed
    	
        --ScriptDir
            Location of random_chunk.py, subset_recombination_map.py, and simualte.slim
            	
        Outputs:
            RecombinationRates_NamingNumber${NamingNumber}.txt
                Two-column space-separated file with header where first column
                is recombination rate for region whose base pair endpoint is 
                specified in second column, where recombination rate units have
                been adjusted from cM/Mb to probabiility of recombination per
                base pair per generation and positions have been adjusted to
                force the starting position of the original recombination rate
                map to be 0 ( for compatibility with SLiM ).
                
            Annotation_NamingNumber${NamingNumber}.csv
        	    Map of genetic annotations, which should be "noncoding", "coding",
        	    or "neutral". "neutral" experience non-trait-influencing, non-fitness-
        	    influencing (neutral) mutations. "noncoding" experience both neutral
        	    mutations and also mutations whose selection coefficients are drawn
        	    from exponential distribution with mean exponential_mean. "coding" 
        	    experience both neutralmutations and also mutations whose selection 
        	    coefficients are drawn from gamma distribution with parameters Gamma.
        	    All trait impacts are calculated by applying Eyre-Walker Model to
        	    selection coefficients. Sub-sampled to match genomic segment 
        	    represented by RecombinationRates_NamingNumber${NamingNumber}.txt
        	    
	   AdjustedAnnotation_NamingNumber${NamingNumber}.txt
	    	   Space-separated file of annotations but where the base pairs are
		   adjusted to match their specifications in SLiM

	   ${replicate_dir}/NamingNumber${NamingNumber}_ParameterFile.txt
	   	   Copy of parameter file with a header descriptive of the specific
		   simulation

            For each sub-population existing at a time-transect timepoint, the 
            following file is outputted:
                p${population}_Timepoint${Timepoint}_NamingNumber${NamingNumber}.vcf
                    Genotypes. Note the "IIDs" at this stage are in the format
                    "i${SLiMindex}". IMPORTANT The "S=" in the info column refers
                    to the SNP's TRAIT-EFFECT BETA. The SNP's selection coefficient
                    is in the Mutations file
                    
		Mutations_Timepoint${Timepoint}_NamingNumber${NamingNumber}.tab
		    Tab-separated file with four ROWS and as many columns as there
		    are m2 and m3 mutations (and also m4 mutations, if running a 
		    simulation with StabilizingSelection==F but PositiveSelection==T and
		    BackgroundSelection==T) at the timepoint. Describes the MID,
		    selection coefficient, trait-effect beta, and mutation type
		    for all m2 and m3 mutations at a given timepoint

	random_chunk.py
        Note this script is run as part of simulate.sh. This script MUST be run
        prior to subset_recombination_map.py. Generates a tab-separated text file 
        with realistic genomic elements. The script will ensure that the ratio 
        of exons deviates by less than 50% from the chromosomal average, and 
        the spanning window size deviates by less than 10% from the specified 
        window size.

        `````````````````````     Begin Code Block        `````````````````````` 
        python random_chunk.py -chrom 1 -windowsize 10e6 -out output_path.tsv 
        ``````````````````````     End Code Block        ```````````````````````  
        -chrom
            Optional. If not specified, a random chromosome is selected.
        -windowsize
            Required. Should be an integer or float.
        -out
            Required. Specifies the output file path.
	
    subset_recombination_map.py
        Note this script is run as part of simulate.sh. Subsets recombination rate 
		map to the genomic window represented by an annotation map which was ALREADY 
		subetted random_chunk.py.
        
        `````````````````````     Begin Code Block        `````````````````````` 
        BaseDir="/n/groups/reich/anp9168/SelectionProject"
        
        CHR=21
        FullRateMapName="Chr${CHR}Recombination.txt"
        RateMapName="10Kbp_Chr${CHR}Recombination.txt"
        AnnotationName="10Kbp_Chr21_Annotation.txt"
        InDir="${BaseDir}/InputFiles"
        replicate_dir="${BaseDir}/GWASEnrichmentSimulation/Troubleshooting"
        
        cd ${BaseDir}/GWASEnrichmentSimulation/Scripts
        
        # Run the script
        source activate SelectionSimulations
        python subset_recombination_map.py \
            --CHR "$CHR" \
            --FullRateMapName "$FullRateMapName" \
            --AnnotationName "$AnnotationName" \
            --RateMapName "$RateMapName" \
            --replicate_dir "$replicate_dir" \
            --InDir "$InDir"
        conda deactivate
        ``````````````````````     End Code Block        ``````````````````````` 
        --CHR
            Chromosome number
            
        --FullRateMapName
            Name of full recombination rate map. Assumed to be space-separated
            with the header: chr position COMBINED_rate(cM/Mb) Genetic_Map(cM)
            
        --AnnotationName
            FULL PATH to output of random_chunk.py
            
        --RateMapName
            Name of rate map to be outputted, which will be subsetted to same
            window as represented in AnnotationName
            
        --replicate_dir
            Directory where ${RateMapName} will be sent
            
        --InDir
    	    Directory of ${FullRateMapName}

/parameter_files
	Files to be inputted into simulate.sh in order to run the 3 models described in
	the main text sections "Test of selection on single variants" and 
	"Forward-in-time simulations of selection in the context of European history" 
	as well as Supplementary Section 2. 
	To use any of these parameter files, you will need to adjust the directories
	named in the file to the actual directories for the indicated variable

	Model1Control_ParameterFile.txt
		Parameter file which, when inputted to simulate.sh, runs Model 1
		without directional selection
		
	Model1Experimental_ParameterFile.txt
		Parameter file which, when inputted to simulate.sh, runs Model 1
		with polygenic directional selection

	Model2.1Control_ParameterFile.txt
		Parameter file which, when inputted to simulate.sh, runs Model 2.1
		without directional selection
		
	Model2.1Experimental_ParameterFile.txt
		Parameter file which, when inputted to simulate.sh, runs Model 2.1
		with directional selection on a single standing variant

	Model2.2Control_ParameterFile.txt
		Parameter file which, when inputted to simulate.sh, runs Model 2.2
		without directional selection
		
	Model2.2Experimental_ParameterFile.txt
		Parameter file which, when inputted to simulate.sh, runs Model 2.2
		with directional selection on a single de novo variant

	Model3Control_ParameterFile.txt
		Parameter file which, when inputted to simulate.sh, runs Model 3
		without directional selection
		
	Model3Experimental_ParameterFile.txt
		Parameter file which, when inputted to simulate.sh, runs Model 3
		with polygenic directional selection
