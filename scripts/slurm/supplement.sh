#!/bin/bash


# Submit minority fraction sensitivity (first positional argument).
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.2 1.2 1 1000
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.2 1.2 2 1000
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.2 1.2 Both 1000

sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.35 1.2 1 1000
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.35 1.2 2 1000
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.35 1.2 Both 1000

sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.5 1.2 1 1000
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.5 1.2 2 1000
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.5 1.2 Both 1000


# Submit a_fitness sensitivity (second positional argument).
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.05 1 1000
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.05 2 1000
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.05 Both 1000

sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.4 1 1000
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.4 2 1000
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.4 Both 1000

sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 2.0 1 1000
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 2.0 2 1000
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 2.0 Both 1000


# Submit nagents sensitivity (second positional argument).
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 1 50
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 2 50
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 Both 50

sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 1 100
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 2 100
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 Both 100

sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 1 200
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 2 200
sbatch --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 Both 200
