#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=5G
#SBATCH --time=1:00:00
#SBATCH --output=Network_MinMaj.out
#SBATCH --partition=serc,normal


module --force purge
module load devel
module load julia/1.7.2


julia -t24 scripts/run_trials.jl $1 --nreplicates=100 --min_group_frac=$2 --a_fitness=$3 --group_w_innovation=$4 --nagents=$5 --use_network=true --mean_degree=$6 --homophily=0.0:0.05:0.95
