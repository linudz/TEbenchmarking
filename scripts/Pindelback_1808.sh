#!/bin/bash -x
#SBATCH --job-name=BM_Jitterbug_Pindel
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=32G
#SBATCH --cpus-per-task=6
#SBATCH -o BM-PindelBack.out
#SBATCH -e BM-PindelBack.err
#SBATCH --get-user-env=PWD



########### SETTINGS ##############

NAMEOFRUN='mh63@nipponbare'     # The name of the run takes the format "sample@reference"


GENOME_PATH=''          # The reference genome
JB_PATH='/home/fbarteri/scripts/JB_local/jitterbug.py'
HARVEST_ANNOTATION_PATH='' # The annotation of the sample - LTR Harvest result
MITES_ANNOTATION_PATH=''    # The annotation of the sample - MITE hunter result

PICONFIG_PATH='/home/fbarteri/piconfig_process.py'

###################################


# STEP 1: PREPARING ANYTHING
# Importations, sourcing, variables, symbolic links and output folders
######################################################################


# 1.1 SOURCING ENVORONMENTS AND LOADING MODULES TO RUN PYTHON

source /opt/Modules/3.2.9/init/Modules4bash.sh		# LOAD THE MODULES FOR BASH
source /home/fbarteri/fabioenv/bin/activate		# VIRTUAL ENVIRONMENT FOR PYTHON
module load python/2.7.3				# LOAD MODULE PYTHON
module load python-libs-2.7				# LOAD THE PYTHON LIBRARIES
module load pindel/0.2.4t				# LOAD MODULE PINDEL

# 1.2 LOADING VARIABLES

V=$NAMEOFRUN	 						# NAME OF THE RUN (reads@reference)

# 1.3 SYMBOLIC LINKS TO PREPARE THE WORKING FOLDER

ln -s $JB_PATH # JITTERBUG EXECUTABLE (PYTHON SCRIPT)


# 1.4 CREATING OUTPUT FOLDERS

mkdir jb_repet_$V					# JITTERBUG @ REPET RESULTS FOLDER
mkdir jb_harvest_$V					# JITTERBUG @ HARVEST RESULTS FOLDER
mkdir pindel_$V						# PINDEL RESULTS FOLDER
mkdir highlights					# RELEVANT RESULTS

/bin/date


# STEP 2: JITTERBUG RUN
# Jitterbug is ran with both the REPET and HARVEST annotations
# Parameters: min_quality: -q 15; number_of_threads: -c 4; 
##############################################################


# 2.1 JB on LTR-RT Annotation

echo '##STARTING JB ON MITES'

./jitterbug.py --psorted $V.r1-r2.sw.psorted.bam -t $HARVEST_ANNOTATION_PATH -l REPETJB_$V -n Pfamily -q 15 -o LTRJB_$V

echo '##JB ON MITES IS OVER'

# 2.2 JB on MITES Annotation

echo '##STARTING JB ON MITES'

./jitterbug.py --psorted $V.r1-r2.sw.psorted.bam -t $MITES_ANNOTATION_PATH  -l REPETJB_$V -n Target -q 15 -o MITESJB_$V

echo '##JB ON MITES IS OVER'


# STEP 3: PINDEL RUN
# Pindel runs with the bam configuration file from JB *read_stats.txt file (output is processed as it follows).
############################################################################################


head -1 REPETJB_$V.read_stats.txt | awk '{print "BAMFILE "$2" HEADER"}' > pin_provo.tab
python $PICONFIG_PATH pin_provo.tab $V.r1-r2.sw.psorted.bam $V > pinconfig.tab

pindel -f $GENOME_PATH -i pinconfig.tab -c ALL -t 4 -x 5 -r false -t false -A 35 -o PINDEL_$V


/bin/date
exit 0;
