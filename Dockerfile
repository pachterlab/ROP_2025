FROM rocker/tidyverse:4.5.1

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # Core R package build dependencies
        build-essential \
        libcurl4-openssl-dev \
        libxml2-dev \
        libpng-dev \
        libjpeg-dev \
        zlib1g-dev \
        # Fonts and text shaping for systemfonts/gridtext/ggfittext
        libfreetype6-dev \
        libharfbuzz-dev \
        libfribidi-dev \
        libfontconfig1-dev \
        # GLPK for igraph
        libglpk-dev \
        # Python support for reticulate
        python3 python3-dev python3-venv python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Download miniconda
RUN if [ "$(uname -m)" = "x86_64" ]; then \
        wget https://repo.anaconda.com/miniconda/Miniconda3-py311_25.5.1-1-Linux-x86_64.sh -O /home/miniconda.sh; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
        wget https://repo.anaconda.com/miniconda/Miniconda3-py311_25.5.1-1-Linux-aarch64.sh -O /home/miniconda.sh; \
    fi

# Install and configure Miniconda
RUN chmod +x /home/miniconda.sh && \
    /bin/bash /home/miniconda.sh -b -p /home/miniconda && \
    rm -rf /home/miniconda.sh && \
    /home/miniconda/bin/conda clean -a -y && \
    echo 'export PATH="/home/miniconda/bin:${PATH}"' >> /root/.bashrc && \
    echo "source /home/miniconda/bin/activate" >> /root/.bashrc && \
    echo 'export PATH="/home/miniconda/bin:${PATH}"' >> /home/rstudio/.bashrc && \
    echo "source /home/miniconda/bin/activate" >> /home/rstudio/.bashrc && \
    /home/miniconda/bin/conda config --add channels r && \
    /home/miniconda/bin/conda config --add channels bioconda && \
    /home/miniconda/bin/conda config --add channels conda-forge && \
    /home/miniconda/bin/conda config --add channels defaults && \
    /home/miniconda/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    /home/miniconda/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Ensure conda is on PATH for all subsequent Docker layers
ENV PATH="/home/miniconda/bin:${PATH}"

# Accept Anaconda TOS to allow package downloads
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Install wompwomp and set up Python environment
RUN R -e "if (!require('remotes', quietly = TRUE)) install.packages('remotes'); \
            remotes::install_github('pachterlab/wompwomp@88c804c569df64ed5c5939ab9acba62f4d54b458', upgrade='never'); \
            remotes::install_github('pachterlab/biowomp@e7ab60c6cd356063cf0203f5acb666de7a68ada0', dependencies=TRUE, upgrade='never'); \
            wompwomp::setup_python_env(yes=TRUE)"

# --- Clone biowomp and set working directory ---
RUN git clone https://github.com/pachterlab/ROP_2025.git /home/rstudio/ROP_2025 && \
    chown -R rstudio:rstudio /home/rstudio/ROP_2025

WORKDIR /home/rstudio/ROP_2025