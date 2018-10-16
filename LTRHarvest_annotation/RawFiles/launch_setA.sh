#!/bin/sh
#SBATCH --job-name=harvest_commersonii
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=4G
#SBATCH --cpus-per-task=6
#SBATCH -o harvest.out
#SBATCH -e harvest.err
#SBATCH --get-user-env=PWD
#SBATCH --partition=fatnodes
#SBATCH --nodelist=wright

/bin/date

annotation=$1
proteins=$2
output=$3

awk '{print $1}' $proteins | grep -wf - $annotation | grep -v long_terimnal_repeat > $output
