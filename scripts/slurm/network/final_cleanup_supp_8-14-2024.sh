#!/bin/bash

datadir=$1

# yo() {

#   argie=$1
#   echo $argie 
# }

# yo "heyyo whatup"

#*** Use this for "production" runs ***#
# run_k() {
#   mean_degree=$1

#   sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $datadir 0.05 1.2 1 1000 $mean_degree "-0.9:0.05:0.9"

#   sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $datadir 0.05 1.2 2 1000 $mean_degree "-0.9:0.05:0.9"
  
#   sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $datadir 0.05 1.2 Both 1000 $mean_degree "-0.9:0.05:0.9"
  
# }

#*** Use this for development/testing runs ***#
# run_k() {
#   mean_degree=$1

#   sbatch --array=1-2%5 scripts/slurm/network/run_helper_neghom.sh $datadir 0.05 1.2 1 1000 $mean_degree "-0.9:0.05:0.9"

#   sbatch --array=1-2%5 scripts/slurm/network/run_helper_neghom.sh $datadir 0.05 1.2 2 1000 $mean_degree "-0.9:0.05:0.9"
  
#   sbatch --array=1-2%5 scripts/slurm/network/run_helper_neghom.sh $datadir 0.05 1.2 Both 1000 $mean_degree "-0.9:0.05:0.9"
  
# }

# mean_degree=10
# run_k $mean_degree
# mean_degree=30
# run_k $mean_degree
# mean_degree=50
# run_k $mean_degree


# run_N() {
#   N=$1
#   sbatch --array=1-5%5 scripts/slurm/network/run_helper_neghom_5h.sh $datadir 0.05 1.2 1 $N 20 "-0.9:0.05:0.9"

#   sbatch --array=1-5%5 scripts/slurm/network/run_helper_neghom_5h.sh $datadir 0.05 1.2 2 $N 20 "-0.9:0.05:0.9"
  
#   sbatch --array=1-5%5 scripts/slurm/network/run_helper_neghom_5h.sh $datadir 0.05 1.2 Both $N 20 "-0.9:0.05:0.9"

# }
# ONLY MISSING TWO, NOT SURE WHICH START CONDITION, SO DO 5 OF EACH
# N=2000
# run_N $N


# # NOW WE NEED TO ALSO SET k TO BE LOWER TO MAKE NETWORKS FOR SMALLER N. Going 
# # to try kbar = 5 for N=50 and kbar = 10 for N=100. Neither N=50 or N=100 
# # finished for kbar = 20. 

run_m_N_kbar() {
  m=$1
  N=$2
  kbar=$3
  sbatch --array=1-20%5 scripts/slurm/network/run_helper_neghom.sh $datadir $m 1.2 1 $N $kbar "-0.9:0.05:0.9"

  sbatch --array=1-20%5 scripts/slurm/network/run_helper_neghom.sh $datadir $m 1.2 2 $N $kbar "-0.9:0.05:0.9"
  
  sbatch --array=1-20%5 scripts/slurm/network/run_helper_neghom.sh $datadir $m 1.2 Both $N $kbar "-0.9:0.05:0.9"

}

run_m_N_kbar_Nreps() {
  m=$1
  N=$2
  kbar=$3
  Nreps=$4
  sbatch --array=1-$Nreps%5 scripts/slurm/network/run_helper_neghom.sh $datadir $m 1.2 1 $N $kbar "-0.9:0.05:0.9"

  sbatch --array=1-$Nreps%5 scripts/slurm/network/run_helper_neghom.sh $datadir $m 1.2 2 $N $kbar "-0.9:0.05:0.9"
  
  sbatch --array=1-$Nreps%5 scripts/slurm/network/run_helper_neghom.sh $datadir $m 1.2 Both $N $kbar "-0.9:0.05:0.9"

}

# Filling in final two N=2000 runs. 

# And we were missing one sensitivity over kbar=50
# m=0.05
# N=1000
# kbar=50
# Nreps=1
# run_m_N_kbar_Nreps $m $N $kbar $Nreps


longrun_m_N_kbar_Nreps() {
  m=$1
  N=$2
  kbar=$3
  Nreps=$4
  sbatch --array=1-$Nreps%5 scripts/slurm/network/run_helper_neghom.sh $datadir $m 1.2 1 $N $kbar "-0.9:0.05:0.9"

  sbatch --array=1-$Nreps%5 scripts/slurm/network/run_helper_neghom.sh $datadir $m 1.2 2 $N $kbar "-0.9:0.05:0.9"
  
  sbatch --array=1-$Nreps%5 scripts/slurm/network/run_helper_neghom.sh $datadir $m 1.2 Both $N $kbar "-0.9:0.05:0.9"

}

m=0.05
N=2000
kbar=20
Nreps=3
longrun_m_N_kbar_Nreps $m $N $kbar $Nreps


# 0.2 * 50 = 10 in minority, so 5 teachers are available for all in minority.
# m=0.25
# N=50
# kbar=5  
# run_m_N_kbar $m $N $kbar

# (still have) m = 0.2 * 100 = 20 in minority, and so 10 teachers 
# available for kbar=10.
# m=0.2
# N=100
# kbar=10  
# run_m_N_kbar $m $N $kbar

## THESE FINISHED FIRST TRY, NO NEED TO RERUN
# run_minfrac() {
#   minfrac=$1
#   sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $datadir $minfrac 1.2 1 1000 20 "-0.9:0.05:0.9"

#   sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $datadir $minfrac 1.2 2 1000 20 "-0.9:0.05:0.9"
  
#   sbatch --array=1-50%5 scripts/slurm/network/run_helper_neghom.sh $datadir $minfrac 1.2 Both 1000 20 "-0.9:0.05:0.9"

# }

# minfrac=0.2
# run_minfrac $minfrac
# minfrac=0.4
# run_minfrac $minfrac
