#!/bin/bash
# run subspace training

# prepare SGE variables
export SGE_LOG_PATH=/data/vision/polina/scratch/adalca/patchSynthesis/sge/
export SGE_O_PATH=${SGE_LOG_PATH}
export SGE_O_HOME=${SGE_LOG_PATH}
mkdir -p $SGE_LOG_PATH
echo $SGE_O_HOME

# MCR file. This has to match the MCC version used in mcc.sh
mcr=/data/vision/polina/shared_software/MCR/v82/

# project paths
PROJECT_PATH="/data/vision/polina/users/adalca/patchSynthesis/subspace/";
CLUST_PATH="${PROJECT_PATH}/clust/"
SYNTHESIS_DATA_PATH="/data/vision/polina/scratch/adalca/patchSynthesis/data/"
ADNI_SUBVOLS_PATH="${SYNTHESIS_DATA_PATH}/adni/subvols/"
ADNI_GMMS_PATH="${SYNTHESIS_DATA_PATH}/adni/gmms/"

# training shell file
mccSh="${PROJECT_PATH}/MCC/MCC_sgeTrainCluster/run_sgeTrainCluster.sh"

# training parameters
K=(2 3 5 10 15 25)
idxvec=("1" "[3, 2]") # iso, ds
modelvec=("model0" "model3") # iso, ds
nSamples="30000"
nGrid=`ls ${ADNI_SUBVOLS_PATH}/*.mat | wc -l`
nRunTypes="${#idxvec[@]}"

# run different models
for r in `seq 0 ${nRunTypes}`;
do
  model=${modelvec[$r]}

  for K in ${K[@]}
  do
    for i in `seq 1 $nGrid`
    do
      # prepare input & output mat files
      subvolfile="${ADNI_SUBVOLS_PATH}/subvol_${i}.mat"
      gmmfile="${ADNI_GMMS_PATH}/gmm_${i}_${model}_K${K}.mat"

      # run training.
      cmd="${CLUST_PATH}/qsub-run ${mccSh} $mcr $subvolfile $K ${modelvec[$r]} $gmmfile ${idxvec[$r]} $nSamples"
      echo $cmd
      $cmd

      echo "done training r:${r} k:${K} i:${i}"
      # sleep 1
    done
  done
done
