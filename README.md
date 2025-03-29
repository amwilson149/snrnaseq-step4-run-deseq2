# snrnaseq-step4-run-deseq2
Code used to run differential expression analysis (DEA) using DESeq2 ([Love et al. 2014](https://doi.org/10.1186/s13059-014-0550-8), [Van den Berge et al. 2018](https://doi.org/10.1186/s13059-018-1406-4)).

This is the fourth code step in a series that was used to study impacts of substance use disorders (SUDs) and HIV infection on cellular transcription in human ventral midbrain ([Wilson et al. 2025](https://doi.org/10.1101/2025.02.05.636667)).
It is intended to be used on snRNA-seq data that has been (1) fully preprocessed and QCed, (2) cell typed, and (3) prepared for DESeq2.

## Installation
This code has several dependencies, but will otherwise run out-of-the-box. An environment with the required dependencies can be built and activated using conda (the following code was run with Anaconda 2020.11):
```
conda config --add channels conda-forge
conda config --add channels bioconda
conda config --add channels defaults
# build conda environment
conda create -n snrnaseq-deseq2-env python=3.8 bioconductor-biostrings \
    bioconductor-delayedarray bioconductor-summarizedexperiment ecos \
    fonts-conda-ecosystem keyutils numpy=1.19.5 osqp \
    pandas=1.1.5 pyparsing pyyaml r-labeling r-sys rpy2 \
    sed yaml
# activate conda environment
conda activate snrnaseq-deseq2-env
```
               

The scripts in this repository can then be run in the command line or with a run script. As an example, a toy dataset with accompanying run script, configuration file, and results have been provided:  
```
# make script executable
chmod +x run_deseq2_example.sh
run_deseq2_example.sh
```

## Citing this work
If you use this code in your work, please cite [Wilson et al. 2025](https://doi.org/10.1101/2025.02.05.636667):
```
@article {Wilson2025.02.05.636667,
	author = {Wilson, Alyssa M. and Jacobs, Michelle M. and Lambert, Tova Y. and Valada, Aditi and Meloni, Gregory and Gilmore, Evan and Murray, Jacinta and Morgello, Susan and Akbarian, Schahram},
	title = {Transcriptional impacts of substance use disorder and HIV on human ventral midbrain neurons and microglia},
	elocation-id = {2025.02.05.636667},
	year = {2025},
	doi = {10.1101/2025.02.05.636667},
	publisher = {Cold Spring Harbor Laboratory},
	abstract = {For people with HIV (PWH), substance use disorders (SUDs) are a prominent neurological risk factor, and the impacts of both on dopaminergic pathways are a potential point of deleterious convergence. Here, we profile, at single nucleus resolution, the substantia nigra (SN) transcriptomes of 90 postmortem donors in the context of chronic HIV and opioid/cocaine SUD, including 67 prospectively characterized PWH. We report altered microglial expression for hundreds of pro- and anti-inflammatory regulators attributable to HIV, and separately, to SUD. Stepwise, progressive microglial dysregulation, coupled to altered SN dopaminergic and GABAergic signaling, was associated with SUD/HIV dual diagnosis and further with lack of viral suppression in blood. In virologically suppressed donors, SUD comorbidity was associated with microglial transcriptional changes permissive for HIV infection. We report HIV-related downregulation of monoamine reuptake transporters specifically in dopaminergic neurons regardless of SUD status or viral load, and additional transcriptional signatures consistent with selective vulnerability of SN dopamine neurons.Competing Interest StatementThe authors have declared no competing interest.},
	URL = {https://www.biorxiv.org/content/early/2025/02/08/2025.02.05.636667},
	eprint = {https://www.biorxiv.org/content/early/2025/02/08/2025.02.05.636667.full.pdf},
	journal = {bioRxiv}
}

```






