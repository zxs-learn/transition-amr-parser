set -o errexit 
set -o pipefail
if [ -z $1 ];then 

    # Standard mini-test with wiki25, sampling
    config=configs/wiki25-structured-bart-base-neur-al.sh

else

    # custom config mini-test
    config=$1
fi
. set_environment.sh
set -o nounset

# load config
. $config 

# Clean-up
[ -d "$ALIGNED_FOLDER" ] && rm -R "$ALIGNED_FOLDER"
mkdir -p "$ALIGNED_FOLDER"

# Train aligner
bash run/train_aligner.sh $config 

# Align data.
mkdir -p $ALIGNED_FOLDER/version_20210709c_exp_0_seed_0_write_amr2
python -u ibm_neural_aligner/main.py \
    --no-jamr \
    --cuda --allow-cpu \
    --vocab-text $ALIGN_VOCAB_TEXT \
    --vocab-amr $ALIGN_VOCAB_AMR \
    --write-single \
    --single-input ${AMR_TRAIN_FILE_WIKI}.no_wiki \
    --single-output $ALIGNED_FOLDER/version_20210709c_exp_0_seed_0_write_amr2/alignment.trn.out.pred \
    --cache-dir $ALIGNED_FOLDER \
    --verbose \
    --load $ALIGN_MODEL  \
    --load-flags $ALIGN_MODEL_FLAGS \
    --batch-size 8 \
    --max-length 0

# results should be written to
if [ -f "$ALIGNED_FOLDER/version_20210709c_exp_0_seed_0_write_amr2/alignment.trn.out.pred" ];then
    printf "\n[\033[92mOK\033[0m] $0\n\n"
else
    printf "\n[\033[91mFAILED\033[0m] $0\n\n"
fi
