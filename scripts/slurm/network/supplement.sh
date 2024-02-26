#!/bin/bash


# # Submit adaptive fitness sensitivity (first positional argument).

# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.05 1 1000 6
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.05 2 1000 6
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.05 Both 1000 6

# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.4 1 1000 6
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.4 2 1000 6
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.4 Both 1000 6


# # Submit minority fraction sensitivity (first positional argument).

# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.2 1.2 1 1000 6
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.2 1.2 2 1000 6
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.2 1.2 Both 1000 6

# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.35 1.2 1 1000 6
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.35 1.2 2 1000 6
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.35 1.2 Both 1000 6


# # Submit mean degree sensitivity.

# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.2 1 1000 9
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.2 2 1000 9
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.2 Both 1000 9

# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.2 1 1000 4
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.2 2 1000 4
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.2 Both 1000 4


# # Submit nagents sensitivity (second positional argument).

# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.2 1 100 6
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.2 2 100 6
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.2 Both 100 6

# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.2 1 2000 6
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.2 2 2000 6
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.05 1.2 Both 2000 6

# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.2 1.2 1 50 6
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.2 1.2 2 50 6
# sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.2 1.2 Both 50 6

sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.1 1.2 1 50 6
sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.1 1.2 2 50 6
sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.1 1.2 Both 50 6

sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.35 1.2 1 50 6
sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.35 1.2 2 50 6
sbatch --array=1-11%5 scripts/slurm/network/run_helper.sh $1 0.35 1.2 Both 50 6

# XXX Wrote these to test which mean node in-degree will converge reliably.
# sbatch scripts/slurm/network/run_helper.sh $1 0.05 1.2 1 1000 9
# sbatch scripts/slurm/network/run_helper.sh $1 0.05 1.2 2 1000 9
# sbatch scripts/slurm/network/run_helper.sh $1 0.05 1.2 Both 1000 9

# sbatch scripts/slurm/network/run_helper.sh $1 0.05 1.2 1 1000 4
# sbatch scripts/slurm/network/run_helper.sh $1 0.05 1.2 2 1000 4
# sbatch scripts/slurm/network/run_helper.sh $1 0.05 1.2 Both 1000 4
