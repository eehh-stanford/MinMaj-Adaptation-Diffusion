#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=5G
#SBATCH --time=00:10:00
#SBATCH --output=SustainableCBA_Both_Tests.out
#SBATCH --partition=serc,normal


module --force purge
module load devel
module load julia/1.7.2

# julia scripts/run_trials.jl test_script --nreplicates=100 --group_1_frac=$1 --a_fitness=$2 --group_w_innovation=$3 --nagents=$4
julia scripts/run_trials.jl test_script --nreplicates=10 --group_1_frac=$1 --a_fitness=$2 --group_w_innovation=$3 --nagents=$4
