import numpy as np
import pandas as pd
import os
import sys
import time
import pickle
import argparse
import yaml
from utils.consts import *
from utils.get_rand_seed import *
# To increase R's protection stack size
# to the maximum value so that it can
# work with larger matrices (such as the
# fold-removed ODC data subsets), set
# initialization options for rpy2
# and initialize R *before* importing
# diffexpr. This forces diffexpr to use
# the existing version of R, with the
# larger protection stack size (tested by
# initializing R via rpy2 with the
# additional '--verbose' option)
import rpy2.rinterface as rinterface
rinterface.embedded.set_initoptions(
        (
            '--max-ppsize=500000',
            '--interactive',
            'c_stack_limit=-1'
            )
        )
rinterface.initr()
from diffexpr.py_deseq import py_DESeq2
from rpy2.robjects.packages import importr
from rpy2.robjects import Formula, pandas2ri
from rpy2.robjects.conversion import localconverter
import rpy2.robjects.numpy2ri as numpy2ri
deseq2 = importr('DESeq2')

print('Packages imported.')

# This script incorporates a random state for repeatability.
# Here, because the calls to DESeq2 functions do not
# have explicit methods for setting the random seed or state,
# we just use our random state to set the seed for this script's
# execution by having it call an integer.

# This script runs differential gene expression analysis
# using diffexpr, a package that ports the R package
# DESeq2 to python
# https://github.com/wckdouglas/diffexpr

# Note: because this package involves R and because installation
# instructions suggested Python 3.6, we have set up a separate
# conda environment in which to run only this script.
# This conda environment is called diffexpr and only has basic
# dependencies other than the following installed:
# pandas tzlocal rpy2 biopython ReportLab pytest-cov
# bioconductor-deseq2 codecove


# Script setup

# 00. Create argparse objects for reading of input arguments
parser = argparse.ArgumentParser(description='K-fold cross-validated differential expression' + \
        ' analysis using diffexpr.')
parser.add_argument(f'--config-yaml-path',type=str,required=True)
parser.add_argument(f'--group-to-process',type=str,required=True)
parser.add_argument(f'--fold-to-process',type=str,required=True)
parser.add_argument(f'--rand-seed',type=str,required=True)
args = parser.parse_args()

# 01. Get analysis parameters from configuration file
cfg = None
with open(args.config_yaml_path) as f:
    cfg = yaml.safe_load(f)
# 01a. Dataset information
# 01a.i. Data root directory
qc_root_dir = cfg.get('root_dir')
# 01a.ii. Differential expression analysis input data directory
dea_data_dir = qc_root_dir + f'/' + cfg.get('input_dea_data_dir')
# 01a.iii. Diffexpr-formatted file directory
dea_diffexpr_dir = dea_data_dir + f'/' + cfg.get('dea_deseq_formatted_data_dir')
# 01a.iv. Diffexpr-ready formatted input file directory
dea_ready_dir = dea_diffexpr_dir + f'/' + cfg.get('dea_ready_deseq_formatted_data_dir')
# 01a.v. Diffexpr results file output directory
dea_output_parent_dir = qc_root_dir + f'/' + cfg.get('output_dea_data_dir')
dea_results_dir = dea_output_parent_dir + f'/' + cfg.get('dea_deseq_formatted_data_dir') + f'/' + cfg.get('dea_results_dir')
print(f'Current output directory:\n{dea_results_dir}')
if not os.path.isdir(dea_results_dir):
    os.system(f'mkdir -p {dea_results_dir}')
# 01a.vi. DEA metadata file name tag
dea_metadata_fn_tag = cfg.get('dea_ready_deseq_formatted_data_fn_tag')

# 01b. DESeq2 DEA run parameters
# 01b.i. Test type
TEST_TYPE = cfg.get('dea_test_type')
# 01b.ii. Whether to use a t-distribution
# for gene dispersion fits (DESeq2 'use_T')
USE_T_DESEQ2_SN_REC = cfg.get('use_t_deseq2')
# 01b.iii. Minimum mu used by DESeq2 during
# fitting (DESeq2 'min_mu')
# if None, DESeq2 default will be used
MIN_MU_DESEQ2_SN_REC = cfg.get('min_mu_deseq2')
if type(MIN_MU_DESEQ2_SN_REC)==str:
    if MIN_MU_DESEQ2_SN_REC.lower()=='none':
        MIN_MU_DESEQ2_SN_REC = None
# 01b.iv. Whether to use pre-computed
# size factors with DESeq2
use_external_size_factors = None
use_external_size_factors = cfg.get('use_external_size_factors')
if use_external_size_factors != True:
    use_external_size_factors = False
# 01b.v. Group/cell type on which to perform DEA
group = args.group_to_process
# 01b.vi. k-fold data subset to process
fold = args.fold_to_process
# 01b.vii. Any additional covariates to ignore
# in DESeq2-ready data subsets (this is a testing
# functionality)
covs_to_ignore = cfg.get('dea_addtl_covariates_to_ignore_curr_comparison')
if (type(covs_to_ignore) == str):
    if (covs_to_ignore.lower() == 'none'):
        covs_to_ignore = []
    else:
        covs_to_ignore = covs_to_ignore.split(',')
# 01b.viii. DEA test condition
test_condition = cfg.get('dea_test_condition')
# 01b.ix. List of test condition level comparisons
# to perform
conditions_to_compare_poss = cfg.get('dea_cond_comparison_list')

# 01c. Random state information
# 01c.i. Random seed
rand_seed_global = np.int32(args.rand_seed)

# 02. Make the DEA results output directory and subdirectory
# for the specified group if needed
dea_results_group_dir = dea_results_dir + f'/' + group
if not os.path.isdir(dea_results_group_dir):
    os.system(f'mkdir -p {dea_results_group_dir}')

# 03. Set the global numpy random number generator to
# random seed generated by our random number generator
np.random.seed(rand_seed_global)

# 04. Get files for current group and fold
dea_ready_data_full_dir = dea_ready_dir + f'/' + group
files_full_dir = os.listdir(
        dea_ready_data_full_dir
        )
# 04a. Get list of powered comparisons
# 04a.i. Get the powered test condition levels
powered_condition_fn_tag = f'powered_conditions{dea_metadata_fn_tag}'
print(f'Powered condition file name tag:\n\t{powered_condition_fn_tag}')
print(f'Directory being searched for powered condition file:\n\t{dea_ready_data_full_dir}')
comparisons_fn = [
        _ for _ in os.listdir(dea_ready_data_full_dir)
        if powered_condition_fn_tag in _
        ][0]
comp_full_fn = dea_ready_data_full_dir + f'/' + comparisons_fn
conditions_powered = []
with open(comp_full_fn,'r') as f:
    lines = f.readlines()
    for line in lines:
        cond_curr = line.split(
                '['
                )[-1].split(
                        ']'
                        )[0].split(',')[0].strip()
        conditions_powered.append(cond_curr)
# 04a.ii. Get the comparisons that are powered
conditions_to_compare = [
        _ for _ in conditions_to_compare_poss
        if (
            (_[1] in conditions_powered)
            &
            (_[2] in conditions_powered)
            )
        ]

# 04b. Get design formula
design_formula_fn_tag = f'design_formula{dea_metadata_fn_tag}'
design_formula_fn = [
        _ for _ in os.listdir(dea_ready_data_full_dir)
        if design_formula_fn_tag in _
        ][0]
design_formula_full_fn = dea_ready_data_full_dir + f'/' + design_formula_fn
formula = ''
with open(design_formula_full_fn,'r') as f:
    formula = f.readlines()[0].strip()
# 04b.i. Get the formula terms
formula_terms = [
        _.strip()
        for _ in
        formula.split('~')[-1].split('+')
        ]
formula_terms = [
        _ for _ in formula_terms
        if _ not in covs_to_ignore
        ]
formula = f'~ ' + ' + '.join(formula_terms)
print(f'Design formula: {formula}\n')
# 04b.i. Set up a reduced design formula variable
# to use if a likelihood ratio test (LRT) is specified
reduced_design_formula = None
if TEST_TYPE=='LRT':
    reduced_design_formula_terms = [
            _ for _ in formula_terms
            if _!=test_condition
            ]
    reduced_design_formula = f'~ ' + ' + '.join(reduced_design_formula_terms)
    del reduced_design_formula_terms

# 04c. Pull metadata and count files for the
# specified group and k-fold data subset
group_fold_str = f'{group}{dea_metadata_fn_tag}__{fold}'
# 04c.i. Metadata file
metadata_fn = [
        _ for _ in os.listdir(dea_ready_data_full_dir)
        if (
            ('metadata' in _)
            &
            (group_fold_str in _)
            )
        ][0]
metadata_full_fn = dea_ready_data_full_dir + f'/' + metadata_fn
metadata_df = pd.read_csv(
        metadata_full_fn,
        )
# 04c.i.A. Make sure that BOTH the index and the first column
# contain the patient barcodes, to be consistent with
# diffexpr requirements
metadata_df.set_index(
        'barcode',
        drop=False,
        inplace=True
        )
# 04c.i.B. Keep only the columns of the metadata DataFrame
# that are part of the design formula
md_cols_to_keep = ['barcode'] + formula_terms
metadata_df = metadata_df[
        md_cols_to_keep
        ]

# 04c.ii. Counts file
counts_fn = [
        _ for _ in os.listdir(dea_ready_data_full_dir)
        if (
            ('counts' in _)
            &
            (group_fold_str in _)
            )
        ][0]
counts_full_fn = dea_ready_data_full_dir + f'/' + counts_fn
counts_df = pd.read_csv(
        counts_full_fn,
        index_col=0
        )

# 04d. Get size factors if specified
size_factors_fn = []
size_factors = None
if use_external_size_factors==True:
    print(f'Trying to use precomputed size factors:')
    size_factors_fn = [
            _ for _ in os.listdir(dea_ready_data_full_dir)
            if (
                ('size_factors_' in _)
                &
                (group_fold_str in _)
                )
            ]
    if len(size_factors_fn) > 0:
        print(f'Found size factors file. Processing.')
        size_factors_fn = size_factors_fn[0]
        size_factors_full_fn = dea_ready_data_full_dir + f'/' + size_factors_fn
        size_factors_df = pd.read_csv(
                size_factors_full_fn,
                index_col=0
                )
        print(f'Adding size factors as a metadata column with the special')
        print(f'name \'sizeFactor\', so they are recognized as pre-supplied')
        print(f'size factors after DESeq2 dataset construction.')
        metadata_df['sizeFactor'] = [
                size_factors_df.loc[_,'size_factors']
                for _ in
                metadata_df.index.values.tolist()
                ]
    else:
        print(f'Did not find any size factors. Skipping.')

print(f'Setup complete.\n\n')
    

# 05. Set up infrastructure for performing DEA with DESeq2
# 05a. Function for GLM fitting and test condition level
# comparisons
def fit_and_run_GLM_DESeq2(dds,
        dds_name,
        group,
        condition_comparison_list,
        test,
        fold,
        output_dir,
        reduced_formula=None,
        ):
    # 05b. Make a test-type tag for the output file name
    test_str = test.lower()
    try:
        print(f'Running DESeq procedure using a {test} test...')
        t0 = time.time()
        if test=='Wald':
            if MIN_MU_DESEQ2_SN_REC is not None:
                dds.run_deseq(
                        test=test,
                        useT=USE_T_DESEQ2_SN_REC,
                        minmu=MIN_MU_DESEQ2_SN_REC,
                        quiet=False
                        )
            else:
                dds.run_deseq(
                        test=test,
                        useT=USE_T_DESEQ2_SN_REC,
                        quiet=False
                        )
        elif test=='LRT':
            if MIN_MU_DESEQ2_SN_REC is not None:
                dds.run_deseq(
                        test=test,
                        reduced=reduced_formula,
                        useT=USE_T_DESEQ2_SN_REC,
                        minmu=MIN_MU_DESEQ2_SN_REC,
                        quiet=False
                        )
            else:
                dds.run_deseq(
                        test=test,
                        reduced=reduced_formula,
                        useT=USE_T_DESEQ2_SN_REC,
                        quiet=False
                        )
        t1 = time.time()
        print(f'Time to run DESeq procedure = {t1-t0:0.002} seconds.\n')
    except Exception as except_err:
        print(f'GLM fitting failed with\n\t{except_err}\nSkipping.')
    except RRuntimeError as runtime_err:
        print(f'GLM fitting failed with \n\t{runtime_err}\nSkipping.')
    else:
        # 05c. Compare conditions for the DESeq2 model
        condition_list_str = '\n\t\t'.join(
                ' '.join(_)
                for _ in condition_comparison_list)
        print(f'List of comparisons to test:\n\t\t{condition_list_str}\n')
        print(f'Output directory: {output_dir}')
        for i,c in enumerate(condition_comparison_list):
            # 05d. Get the statistics for the current comparison
            dds.get_deseq_result(contrast = c)
            # 05e. Store the DataFrame with log2 fold changes
            # and Wald p and adjusted p values
            res_curr = dds.deseq_result
            cname = f'{c[0]}_{c[1]}_vs_{c[2]}'
            res_curr_fn = f'{output_dir}/{test_str}_results_{dds_name}__{group}__{cname}__fold_{fold}.csv'
            res_curr.to_csv(res_curr_fn,index=True)
            # 05f. Store the normalized counts for downstream plotting
            norm_counts = dds.normalized_count()
            norm_counts_fn = f'{output_dir}/{test_str}_norm_counts___{dds_name}__{group}__{cname}__fold_{fold}.csv'
            norm_counts.to_csv(norm_counts_fn,index=True)


# 06. Perform DEA for the specified group data
print(f'Performing DEA on group {group}, fold {fold}....\n')

# 06a. Initialize the DESeq object
print('Initializing DESeq object...')
dds = py_DESeq2(
        count_matrix = counts_df,
        design_matrix = metadata_df,
        design_formula = formula,
        gene_column = 'gene_name'
        )

# 06b. Perform fitting of the supplied GLM design
# function and look for DEGs for the comparisons
# of interest
print('Fitting GLM and performing DEA tests...')
fit_and_run_GLM_DESeq2(
        dds = dds,
        dds_name = test_condition,
        group = group,
        condition_comparison_list = conditions_to_compare,
        test = TEST_TYPE,
        fold = fold,
        output_dir = dea_results_group_dir,
        reduced_formula = reduced_design_formula,
        )
    
sys.exit()
