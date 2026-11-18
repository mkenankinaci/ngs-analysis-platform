
FROM rocker/shiny:4.4.3

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libsodium-dev \
    libuv1-dev \
    zlib1g-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages(c( \
    'shiny', \
    'shinyFiles', \
    'jsonlite', \
    'shinydashboard', \
    'vcfR', \
    'data.table', \
    'dplyr', \
    'stringr', \
    'DT', \
    'shinyWidgets', \
    'httr', \
    'shinyjs', \
    'promises', \
    'future', \
    'tidyverse', \
    'httr' \
  ), repos='https://cloud.r-project.org')"

WORKDIR /srv/shiny-server/app

# COPY global.R ui.R server.R libs.R ./

EXPOSE 3838

CMD ["Rscript", "-e", "shiny::runApp('/srv/shiny-server/app', host='0.0.0.0', port=3838)"]

