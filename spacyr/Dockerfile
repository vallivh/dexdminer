FROM continuumio/miniconda3:4.7.12

RUN conda install -y python=3.6 && \
    conda install -y -c conda-forge spacy

RUN conda create -y -n spacy_condaenv python=3.6 spacy

RUN echo "source activate spacy_condaenv" > ~/.bashrc
ENV PATH /opt/conda/envs/spacy_condaenv/bin:$PATH

RUN python -m spacy download en && \
    python -m spacy download de
