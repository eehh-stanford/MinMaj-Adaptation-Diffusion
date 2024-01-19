#!/bin/bash


# Submit minority fraction sensitivity (first positional argument).
sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.2 1.2 1 1000 6
sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.2 1.2 2 1000 6
sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.2 1.2 Both 1000 6

sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.35 1.2 1 1000 6
sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.35 1.2 2 1000 6
sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.35 1.2 Both 1000 6


# Submit mean degree sensitivity.
sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.05 1.05 1 1000 3
sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.05 1.05 2 1000 3
sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.05 1.05 Both 1000 3

sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.05 1.2 1 1000 9
sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.05 1.2 2 1000 9
sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.05 1.2 Both 1000 9


# Submit nagents sensitivity (second positional argument).
sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.05 1.2 1 50 6
sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.05 1.2 2 50 6
sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.05 1.2 Both 50 6

sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.05 1.2 1 100 6
sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.05 1.2 2 100 6
sbatch --array=1-10%20 scripts/slurm/network/run_helper.sh $1 0.05 1.2 Both 100 6
