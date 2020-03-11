#!/bin/bash

export CUDA_VISIBLE_DEVICES=1

set -e

#===== begin config =======

nj=$(nproc)
stage=0

anoni_pool="libritts_train_other_500"

printf -v results '%(%Y-%m-%d-%H-%M-%S)T' -1
results=exp/results-$results

. utils/parse_options.sh || exit 1;

. path.sh
. cmd.sh

# Chain model for BN extraction
ppg_model=exp/models/1_asr_am/exp
ppg_dir=${ppg_model}/nnet3_cleaned

# Chain model for ASR evaluation
asr_eval_model=exp/models/asr_eval

# x-vector extraction
xvec_nnet_dir=exp/models/2_xvect_extr/exp/xvector_nnet_1a
anon_xvec_out_dir=${xvec_nnet_dir}/anon

# ASV_eval config
asv_eval_model=exp/models/asv_eval/xvect_01709_1
plda_dir=${asv_eval_model}/xvect_train_clean_360

# Anonymization configs
pseudo_xvec_rand_level=spk                # spk (all utterances will have same xvector) or utt (each utterance will have randomly selected xvector)
cross_gender="false"                      # false, same gender xvectors will be selected; true, other gender xvectors
distance="plda"                           # cosine or plda
proximity="farthest"                      # nearest or farthest speaker to be selected for anonymization

anon_data_suffix=_anon

#=========== end config ===========

data_netcdf=$(realpath exp/am_nsf_data)   # directory where features for voice anonymization will be stored
mkdir -p $data_netcdf || exit 1;

for dset in libri_test_f2; do
  local/anon/anonymize_data_dir.sh \
    --nj $nj --anoni-pool $anoni_pool \
    --data-netcdf $data_netcdf \
    --ppg-model $ppg_model --ppg-dir $xvector_nnet_1a \
    --xvec-nnet-dir $xvec_nnet_dir \
    --anon-xvec-out-dir $anon_xvec_out_dir --plda-dir $plda_dir \
    --pseudo-xvec-rand-level $pseudo_xvec_rand_level --distance $distance \
    --proximity $proximity --cross-gender $cross_gender \
    --anon-data-suffix $anon_data_suffix $dset || exit 1;
done

echo Done
