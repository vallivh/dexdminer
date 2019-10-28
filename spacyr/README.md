# Overview
This image creates a Docker container that
generates a conda environment which can be used
with the R package `spacyr`.

It is based on the `continuumio/miniconda3` image and
activates an environment called `spacy_condaenv` with
Python 3.6 and spaCy as well as the latest
Englisch and German language models installed.

# Usage
You can use the container to run `spacyr` in
RStudio (Server) or Shiny Server. Mount a volume or
local directory to `/opt/conda` at runtime or in your
`docker-compose.yml` and in your R script set
```
spacy_initialize(python_executable = "/opt/conda/envs/spacy_condaenv/bin/python")
```
(or to your local directory if you are developing
outside of Docker).

You can find an exemplary docker-compose file at
[vallivh/info-app](https://github.com/vallivh/info-app/blob/master/docker-compose.yml).
