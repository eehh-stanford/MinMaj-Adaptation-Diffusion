#!/bin/bash

# Submit main results jobs, one line for each innovation starting condition,
# specified in the third positional argument to run_helper.sh: 
# minority group (1), majority group (2), or both groups (Both).
#
# The first positional argument passed to this script is the CSV output write directory.
sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $1 0.05 1.2 1 1000 20 "-0.9:0.05:0.9"
sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $1 0.05 1.2 2 1000 20 "-0.9:0.05:0.9"
sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $1 0.05 1.2 Both 1000 20 "-0.9:0.05:0.9"

# XXX remove this after first use to make up for lack of 3000 fully-converged trials.
# sbatch --array=1-10%5 scripts/slurm/network/run_helper.sh $1 0.05 1.2 1 1000 20 
# sbatch --array=1-10%5 scripts/slurm/network/run_helper.sh $1 0.05 1.2 2 1000 20 "-0.9:0.1:0.9"
# sbatch --array=1-10%5 scripts/slurm/network/run_helper.sh $1 0.05 1.2 Both 1000 20 "-0.9:0.1:0.9"
