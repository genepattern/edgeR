# edgeR

## Overview

Perform Differential expression using Quasi-Likelihood Pipeline, run glmQLFit() and glmQLFTest().

**Version:** latest  
**Language:** r

## Description

edgeR is a GenePattern module that performs differential gene expression analysis using the edgeR Bioconductor package's quasi-likelihood (QL) pipeline. This module implements a robust statistical framework for identifying differentially expressed genes in RNA-seq count data by modeling overdispersion through quasi-likelihood methods. The QL approach provides better error rate control than likelihood ratio tests, especially for experiments with small sample sizes.

The module runs the complete edgeR QL pipeline including:
- Data normalization and filtering
- Dispersion estimation with trend modeling
- Quasi-likelihood fitting (glmQLFit)
- Statistical testing (glmQLFTest)
- Multiple testing correction

## Parameters

### Required Parameters

**count.matrix.file** (FILE)
- **Purpose**: Input count matrix file containing raw RNA-seq read counts
- **Format**: Tab-delimited (.txt, .tsv), comma-separated (.csv), or GCT format
- **Structure**: Genes as rows, samples as columns with integer count values
- **Requirements**: 
  - Must contain raw, unnormalized integer counts
  - Sample names in header must match those in sample groups file
  - Gene identifiers should be in first column or row names

**sample.groups.file** (FILE)  
- **Purpose**: Define experimental groups for comparison
- **Format**: Two-column tab-delimited text file
- **Structure**: 
  - Column 1: Sample IDs (exactly matching count matrix column names)
  - Column 2: Group assignments (factor levels for comparison)
- **Example**:
  ```
  Sample	Group
  Sample1	Control
  Sample2	Control  
  Sample3	Treatment
  Sample4	Treatment
  ```

**comparison.groups** (TEXT)
- **Purpose**: Specify which groups to compare for differential expression
- **Format**: Comma-separated pair of group names
- **Example**: "Treatment,Control" (compares Treatment vs Control)
- **Note**: First group is numerator, second is denominator for fold change calculation

### Optional Parameters

**output.prefix** (TEXT)
- **Purpose**: Customize output file naming
- **Default**: "edgeR"
- **Usage**: All output files will use this prefix (e.g., "MyExp_results.txt")

**min.count** (INTEGER)
- **Purpose**: Minimum count threshold for gene filtering
- **Default**: 1
- **Rationale**: Removes very lowly expressed genes that provide little statistical power
- **Range**: ≥ 0 (typically 1-10)

**min.samples** (INTEGER)  
- **Purpose**: Minimum samples requiring expression above min.count threshold
- **Default**: 2
- **Rationale**: Genes must be expressed in multiple samples to be considered
- **Usage**: Gene retained if ≥ min.samples have counts ≥ min.count

**norm.method** (CHOICE: TMM, RLE, upperquartile, none)
- **Purpose**: Normalization method for library size adjustment
- **Default**: TMM (Trimmed Mean of M-values)
- **Options**:
  - TMM: Recommended for most RNA-seq experiments
  - RLE: Relative Log Expression (similar to DESeq2)
  - upperquartile: Use upper quartile for normalization
  - none: Skip normalization (not recommended)

**robust.estimation** (CHOICE: true, false)
- **Purpose**: Use robust methods for dispersion estimation
- **Default**: false
- **Usage**: Set to true if dataset may contain outlier genes that could skew dispersion estimates
- **Impact**: More conservative but stable dispersion estimates

**abundance.trend** (CHOICE: true, false)
- **Purpose**: Model abundance-dependent trend in QL dispersion
- **Default**: true  
- **Rationale**: Accounts for the relationship between gene expression level and variance
- **Recommendation**: Generally keep as true unless specifically advised otherwise

**poisson.bound** (CHOICE: true, false)
- **Purpose**: Apply Poisson bound to QL p-values
- **Default**: true
- **Function**: Prevents over-dispersion from making p-values unrealistically small
- **Recommendation**: Keep true for proper error rate control

**fdr.threshold** (FLOAT)
- **Purpose**: False Discovery Rate threshold for significance
- **Default**: 0.05
- **Range**: 0.0 to 1.0
- **Usage**: Genes with FDR ≤ this value are considered significantly differentially expressed

**fold.change.threshold** (FLOAT)
- **Purpose**: Minimum absolute log2 fold change for biological significance
- **Default**: 1.0 (equivalent to 2-fold change)
- **Range**: ≥ 0.0
- **Usage**: Combined with FDR threshold to define significant genes

**top.genes** (INTEGER)
- **Purpose**: Number of top DE genes to highlight in outputs and plots
- **Default**: 50
- **Range**: > 0
- **Usage**: Affects summary tables and plot annotations

**create.plots** (CHOICE: true, false)
- **Purpose**: Generate diagnostic and visualization plots
- **Default**: true
- **Plots Generated**:
  - MA plot (log2FC vs average expression)
  - Volcano plot (log2FC vs -log10(p-value))
  - Dispersion plot (biological coefficient of variation)
  - PCA plot (sample relationships)

## Usage Examples

### Basic Differential Expression Analysis

**Scenario**: Compare treated vs control samples
```
Input Files:
- count_matrix.txt (gene counts across samples)
- sample_info.txt (sample-to-group mapping)

Parameters:
- comparison.groups: "Treated,Control"  
- fdr.threshold: 0.05
- fold.change.threshold: 1.0
```

### Stringent Analysis with Custom Filtering

**Scenario**: High-stringency analysis with custom thresholds
```
Parameters:
- min.count: 5
- min.samples: 3
- fdr.threshold: 0.01
- fold.change.threshold: 1.5
- robust.estimation: true
```

### Large-Scale Study

**Scenario**: Analysis of large cohort with many samples
```
Parameters:  
- norm.method: TMM
- robust.estimation: true
- top.genes: 100
- create.plots: true
```

## Output Files

### Primary Results
- **{prefix}_results.txt**: Complete differential expression results for all tested genes
- **{prefix}_significant.txt**: Filtered results containing only significantly DE genes
- **{prefix}_summary.txt**: Analysis summary with key statistics

### Diagnostic Plots (if create.plots=true)
- **{prefix}_MA_plot.pdf**: MA plot showing log2FC vs average expression
- **{prefix}_volcano_plot.pdf**: Volcano plot showing log2FC vs significance  
- **{prefix}_dispersion_plot.pdf**: Dispersion estimates across expression levels
- **{prefix}_PCA_plot.pdf**: Principal component analysis of samples

### Results File Columns
- **Gene**: Gene identifier
- **logFC**: Log2 fold change (positive = upregulated in first group)
- **logCPM**: Log2 counts per million (average expression)
- **F**: F-statistic from QL test
- **PValue**: Uncorrected p-value
- **FDR**: False discovery rate (Benjamini-Hochberg adjusted p-value)

## Computational Requirements

- **Memory**: Minimum 4GB RAM (8GB+ recommended for large datasets)
- **Runtime**: Typically 5-30 minutes depending on dataset size
- **Disk Space**: ~100MB for outputs plus input file sizes

## Troubleshooting

### Input Data Issues

**"Sample names don't match between files"**
- Verify sample IDs in count matrix headers exactly match those in sample groups file
- Check for spaces, special characters, or case sensitivity differences

**"No genes pass filtering criteria"**
- Reduce min.count or min.samples parameters
- Check if count data contains very low counts across most genes
- Verify count matrix contains raw integer counts, not normalized values

**"Insufficient samples for analysis"**
- Ensure each comparison group has at least 2 samples
- Check sample groups file for correct group assignments

### Analysis Issues

**"Dispersion estimation fails"**
- Try setting robust.estimation=true
- Check for extreme outlier samples or genes
- Verify adequate biological replication within groups

**"No significantly DE genes found"**  
- Increase FDR threshold (e.g., 0.1 instead of 0.05)
- Reduce fold change threshold
- Check if experimental groups are well-separated
- Consider increasing sample sizes if possible

**"Memory errors during analysis"**
- Reduce dataset size by pre-filtering lowly expressed genes
- Increase available system memory
- Consider analyzing subsets of samples separately

### Output Issues

**"Plot generation fails"**
- Set create.plots=false to skip plotting
- Check available disk space for output files
- Ensure R graphics packages are properly installed

## Statistical Considerations

### When to Use edgeR QL Pipeline
- **Recommended for**: Small to moderate sample sizes (n=3-20 per group)
- **Best for**: Experiments where precise error rate control is critical
- **Advantages**: Conservative approach, good performance with limited replication

### Comparison with Other Methods
- **vs DESeq2**: edgeR QL often more conservative, similar performance overall
- **vs limma-voom**: QL pipeline specifically designed for count data
- **vs classic edgeR**: QL methods provide better error rate control

### Design Considerations
- **Replication**: Minimum 3 biological replicates per group recommended
- **Batch Effects**: Consider adding batch variables to sample groups file
- **Paired Samples**: For paired designs, include pairing information in groups file

## References

1. Robinson MD, McCarthy DJ, Smyth GK (2010). "edgeR: a Bioconductor package for differential expression analysis of digital gene expression data." Bioinformatics 26, 139-140.

2. McCarthy DJ, Chen Y, Smyth GK (2012). "Differential expression analysis of multifactor RNA-Seq experiments with respect to biological variation." Nucleic Acids Research 40, 4288-4297.

3. Lun ATL, Chen Y, Smyth GK (2016). "It's DE-licious: A Recipe for Differential Expression Analyses of RNA-seq Experiments Using Quasi-Likelihood Methods in edgeR." Methods in Molecular Biology 1418, 391-416.

4. Chen Y, Lun ATL, Smyth GK (2016). "From reads to genes to pathways: differential expression analysis of RNA-Seq experiments using Rsubread and the edgeR quasi-likelihood pipeline." F1000Research 5, 1438.


## Version History

- **latest** - Current implementation with quasi-likelihood pipeline
- Support for multiple normalization methods
- Enhanced plot generation and diagnostic outputs
- Improved parameter validation and error handling
