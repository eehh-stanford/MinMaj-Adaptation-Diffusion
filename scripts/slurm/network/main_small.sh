#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=5G
#SBATCH --time=00:10:00
#SBATCH --output=MinMaj_small.out
#SBATCH --partition=serc,normal


module --force purge
module load devel
module load julia/1.9


julia scripts/run_trials.jl $1 --nreplicates=10 --min_group_frac=$2 --a_fitness=$3 --group_w_innovation=$4 --nagents=$5 --use_network=true --mean_degree=$6
