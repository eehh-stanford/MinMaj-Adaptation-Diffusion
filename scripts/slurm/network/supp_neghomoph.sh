#!/bin/bash

datadir=$1

# yo() {

#   argie=$1
#   echo $argie 
# }

# yo "heyyo whatup"

#*** Use this for "production" runs ***#
run_k() {
  mean_degree=$1

  sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $datadir 0.05 1.2 1 1000 $mean_degree "-0.9:0.05:0.9"

  sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $datadir 0.05 1.2 2 1000 $mean_degree "-0.9:0.05:0.9"
  
  sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $datadir 0.05 1.2 Both 1000 $mean_degree "-0.9:0.05:0.9"
  
}

#*** Use this for development/testing runs ***#
# run_k() {
#   mean_degree=$1

#   sbatch --array=1-2%5 scripts/slurm/network/run_helper_neghom.sh $datadir 0.05 1.2 1 1000 $mean_degree "-0.9:0.05:0.9"

#   sbatch --array=1-2%5 scripts/slurm/network/run_helper_neghom.sh $datadir 0.05 1.2 2 1000 $mean_degree "-0.9:0.05:0.9"
  
#   sbatch --array=1-2%5 scripts/slurm/network/run_helper_neghom.sh $datadir 0.05 1.2 Both 1000 $mean_degree "-0.9:0.05:0.9"
  
# }

mean_degree=10
run_k $mean_degree
mean_degree=30
run_k $mean_degree
mean_degree=50
run_k $mean_degree


run_N() {
  N=$1
  sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $datadir 0.05 1.2 1 $N 20 "-0.9:0.05:0.9"

  sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $datadir 0.05 1.2 2 $N 20 "-0.9:0.05:0.9"
  
  sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $datadir 0.05 1.2 Both $N 20 "-0.9:0.05:0.9"

}
N=50
run_N $N
N=100
run_N $N
N=2000
run_N $N

run_minfrac() {
  minfrac=$1
  sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $datadir $minfrac 1.2 1 1000 20 "-0.9:0.05:0.9"

  sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $datadir $minfrac 1.2 2 1000 20 "-0.9:0.05:0.9"
  
  sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $datadir $minfrac 1.2 Both 1000 20 "-0.9:0.05:0.9"

}

minfrac=0.2
run_minfrac $minfrac
minfrac=0.4
run_minfrac $minfrac
