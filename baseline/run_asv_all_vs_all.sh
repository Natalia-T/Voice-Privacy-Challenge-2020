#!/bin/bash

set -e

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

for dset in vctk_dev; do
  printf "${RED}**ASV: $dset - original vs original**${NC}\n"
  local/asv_eval.sh --plda_dir $plda_dir --asv_eval_model $asv_eval_model \
    --enrolls $dset --trials $dset --results $results || exit 1;
done

echo Done
