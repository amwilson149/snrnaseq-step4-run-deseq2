#!/bin/bash

set -ev

# 01. Set up environment
exec_dir=$( pwd )
cd "${exec_dir}"
sud_dea_dir="${exec_dir}/scripts"

# 02. Set up config files
# 02a. Specify config file path
cfg="${exec_dir}/configs/config_run_DESeq2_example_SUD_DEA.yaml"
echo "${cfg}"
# 02b. Add root directory to config file if not specified
if ! $( grep -q 'root_dir' ${cfg} ); then
	echo "Initializing config file with current directory as root directory"
	echo "root_dir: '${exec_dir}'" >> ${cfg}
else
	echo "Config file already contains root directory; proceeding"
fi

# 03. Specify cell type(s) being processed (separately) with DESeq2 (comma-separated list)
group="dopaminergic_neuron"

# 04. Run DEA
# 04a. Specify random seed file locations
rs_dir="${exec_dir}/data/random_state_files/dea_random_seed_files"
rs_fn_tag="sud"
# 04b. Specify number of folds for k-fold cross-validation
nfolds="2"
for fold in $(seq 1 ${nfolds}); do
	rsfn="${rs_dir}/dea_rand_seed__${rs_fn_tag}__${group}__${fold}.txt"
	rscurr=$( cat "${rsfn}" )
	echo -e "Running SUD DEA for fold ${fold} with random seed ${rscurr}"
	python "${sud_dea_dir}/04_run_deseq2_kfcv.py" --config-yaml-path ${cfg} --group-to-process ${group} --fold-to-process ${fold} --rand-seed ${rscurr}
done


