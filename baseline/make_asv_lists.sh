#!/bin/bash

set -e

. path.sh
. cmd.sh

for dset in libri_dev; do
  data=data/$dset
  [ -f $data/utt2spk_orig ] && echo "File $data/utt2spk_orig already exist. Restore original data." && exit 1
  [ ! -f $data/utt2spk ] && echo "File $data/utt2spk does not exist" && exit 1
  utils/fix_data_dir.sh $data || exit 1
  utils/validate_data_dir.sh --no-feats $data || exit 1
  mv $data/utt2spk $data/utt2spk_orig
  rm -f $data/enrolls* $data/trials* $data/spk2gender 2> /dev/null
  awk '{print $1, $1}' $data/utt2spk_orig > $data/utt2spk
  cp $data/utt2spk $data/spk2utt
  cut -d' ' -f1 $data/utt2spk > $data/enrolls
  awk -v utt2spk=$data/utt2spk_orig 'BEGIN{
    while((getline line < utt2spk) > 0 ) {
      split(line, parts, " ")
      utt = parts[1]
      spk = parts[2]
      u2s[utt] = spk
    }
    for (utt1 in u2s) {
      spk1=u2s[utt1]
      for (utt2 in u2s) {
        if (utt2 != utt1) {
          spk2=u2s[utt2]
          if (spk2 == spk1) {
            print utt1, utt2, "target"
          } else {
            print utt1, utt2, "nontarget"
          }
        }
      }
    }
  }' | sort > $data/trials || exit 1
  utils/fix_data_dir.sh $data || exit 1
  utils/validate_data_dir.sh --no-feats $data || exit 1
done

echo Done
