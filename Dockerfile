FROM rocker/shiny:3.6.1

# install system packages
RUN apt-get update && apt-get install -y gnupg2 \
     libssl-dev \
     libsasl2-dev \
     libgsl0-dev \
     libxml2-dev \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists/ \
     && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# install app base packages
RUN R -e "install.packages(c('shiny', \
                              'shinydashboard', \
                              'mongolite', \
                              'ndjson', \
                              'anytime', \
                              'lubridate', \
                              'rapportools', \
                              'quanteda', \
                              'DT'), \
          repos='https://cran.r-project.org')"

# install other app packages (still subject to change)
RUN R -e "install.packages(c('openxlsx', \
                              'plotly', \
                              'shinyalert', \
                              'topicmodels', \
                              'rhandsontable', \
                              'spacyr'), \
          repos='https://cran.r-project.org')"

# copy server config and app code to shiny server
COPY ./shinyserver/shiny-server.conf /srv/shiny-server/shiny-server.conf
COPY ./shinyserver/shiny-server.sh /usr/bin/shiny-server.sh
COPY . /srv/shiny-server/dexdminer

# expose shiny server port
EXPOSE 3838

#USER shiny

RUN ["chmod", "+x", "/usr/bin/shiny-server.sh"]
