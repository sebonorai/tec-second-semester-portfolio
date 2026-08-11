# Bioinformatics — R

Sequence analysis and phylogenetics, written in R and R Markdown.

## Files

### `evidencia01-sars-cov-2.Rmd`
Viral outbreak analysis of SARS-CoV-2. Loads genomic sequences, computes composition statistics, and reports the findings as a rendered notebook.

### `evidencia02-variant-evolution.Rmd`
Deeper analysis of SARS-CoV-2 tracking how variants changed over time — comparing sequences across the timeline to characterise their divergence.

### `act04-phylogenetic-trees.Rmd`
Builds phylogenetic trees in R using `Biostrings`: sequence alignment, distance matrices, and tree construction and visualisation.

### `act03-database-exercises.Rmd`
Querying and manipulating biological sequence databases from R.

### `act02-sequence-manipulation.R`
Utility functions for working with DNA sequences — random sequence generation, length and composition calculations, and the basic transformations the later analyses build on.

## Running

Open in RStudio and knit, or from the console:

```r
rmarkdown::render("evidencia01-sars-cov-2.Rmd")
```

Requires `Biostrings` from Bioconductor:

```r
BiocManager::install("Biostrings")
```
