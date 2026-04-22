# Dockerfile for edgeR GenePattern Module
# edgeR is a Bioconductor package for differential gene expression analysis
FROM rocker/r-ver:4.3.0

# Metadata labels
LABEL maintainer="GenePattern"
LABEL module.name="edgeR"
LABEL module.version="latest"
LABEL module.language="r"
LABEL description="edgeR Bioconductor package for differential expression analysis of RNA-seq data"

# Set working directory
WORKDIR /module

# Install system dependencies and R packages in combined layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        curl \
        ca-certificates \
        build-essential \
        gfortran \
        libxml2-dev \
        libcurl4-openssl-dev \
        libssl-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # Install BiocManager and common R packages
    R -e "install.packages(c('BiocManager', 'optparse', 'futile.logger', 'data.table'), repos='https://cloud.r-project.org/', dependencies=TRUE)" && \
    # Install edgeR from Bioconductor
    R -e "BiocManager::install('edgeR', dependencies=TRUE)" && \
    # Install additional common packages for RNA-seq analysis
    R -e "BiocManager::install(c('limma', 'locfit'), dependencies=TRUE)" && \
    # Clean up R package cache
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Copy module files (only copy files that exist in build context)
COPY edger_wrapper.R /module/
COPY manifest /module/

# Set execute permissions on wrapper script
RUN chmod +x /module/edger_wrapper.R

# Environment variables for module execution
ENV MODULE_NAME=edgeR
ENV R_LIBS_USER=/usr/local/lib/R/site-library

# Default command - allows for interactive use and script execution
CMD ["/bin/bash"]