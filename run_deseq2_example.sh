#!/bin/bash
#BSUB -P acc_motor # project name
#BSUB -q premium # queue name ('premium' is standard on Minerva)
#BSUB -n 10 # number of tasks in a parallel job (also submits as a parallel job)
#BSUB -R span[hosts=1] # resource requirements
#BSUB -R rusage[mem=20000] # resource requirements
#BSUB -W 10:00 # job runtime limit (HH:MM)
#BSUB -J /sc/arion/projects/motor/WILSOA28/demuxlet_analysis/snrnaseq__04_run_deseq2/log_files/run_04_deseq2__0
#BSUB -o /sc/arion/projects/motor/WILSOA28/demuxlet_analysis/snrnaseq__04_run_deseq2/log_files/run_04_deseq2__0.o
#BSUB -e /sc/arion/projects/motor/WILSOA28/demuxlet_analysis/snrnaseq__04_run_deseq2/log_files/run_04_deseq2__0.e
#BSUB -L /bin/bash

set -ev

# 01. Set up environment
# 01a. Activate conda environment
ml anaconda3/2020.11
ml -python
source /hpc/packages/minerva-centos7/anaconda3/2020.11/etc/profile.d/conda.sh
conda activate diffexpr

# 01b. Get root directory
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


