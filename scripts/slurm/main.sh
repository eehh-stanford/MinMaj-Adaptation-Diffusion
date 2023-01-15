#!/bin/bash

# Submit main results jobs, one line for each innovation starting condition,
# specified in the third positional argument to run_helper.sh: 
# minority group (1), majority group (2), or both groups (Both).
sbatch --array=1-10 scripts/slurm/run_helper.sh 0.05 1.2 1 1000
sbatch --array=1-10 scripts/slurm/run_helper.sh 0.05 1.2 2 1000
sbatch --array=1-10 scripts/slurm/run_helper.sh 0.05 1.2 Both 1000
