sbatch --job-name=ba --output=test_ba.out scripts/slurm/run_helper.sh $1 0.05 1.2 1 10 0.25
# sbatch --job-name=ba --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 1 10 0.25
# sbatch --job-name=ba --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 2 1000 0.25
# sbatch  --job-name=ba --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 Both 1000 0.25

# sbatch --job-name=ba --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 1 1000 0.5
# sbatch --job-name=ba --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 2 1000 0.5
# sbatch --job-name=ba --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 Both 1000 0.5

# sbatch --job-name=ba --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 1 1000 0.75
# sbatch --job-name=ba --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 2 1000 0.75
# sbatch --job-name=ba --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 Both 1000 0.75

# sbatch --job-name=ba --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 1 1000 0.95
# sbatch --job-name=ba --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 2 1000 0.95
# sbatch --job-name=ba --array=1-10 scripts/slurm/run_helper.sh $1 0.05 1.2 Both 1000 0.95
