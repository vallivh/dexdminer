# Overview

DexDminer is an easy-to-use, flexible Text Mining Toolkit and Dashboard. The GUI is based on Shiny and can be easily modified to incorporate new requirements.

# Usage

You can clone this repository to run the app from RStudio or load the Docker image at [vallivh/dexdminer](https://cloud.docker.com/repository/docker/vallivh/dexdminer) using the docker-compose file in the root. The compose file will ensure that all dependencies and packages are installed, it sets up Shiny Server and RStudio Server as well as a MongoDB and makes a preconfigured spaCy environment available to the relevant containers. It uses Docker images from [`rocker/rstudio`](https://hub.docker.com/r/rocker/rstudio), [`rocker/shiny`](https://hub.docker.com/r/rocker/shiny), [`mongo`](https://hub.docker.com/_/mongo) and [`vallivh/spacyr`](https://hub.docker.com/repository/docker/vallivh/spacyr).
