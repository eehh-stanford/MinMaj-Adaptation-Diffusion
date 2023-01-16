#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=5G
#SBATCH --time=02:00:00
#SBATCH --output=SustCBA_Supplement.out
#SBATCH --partition=serc,normal


module --force purge
module load devel
module load julia/1.7.2

julia scripts/run_trials.jl $1 --nreplicates=100 --group_1_frac=$2 --a_fitness=$3 --group_w_innovation=$4 --nagents=$5
