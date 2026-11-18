
FROM rocker/shiny:4.4.2

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Istanbul

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libpng-dev \
    libjpeg-dev \
    libtiff5-dev \
    && rm -rf /var/lib/apt/lists/*

RUN install2.r --error --skipinstalled tidyverse

# R paketlerini image oluşturulurken kur
RUN Rscript -e "install.packages(c( \
    'shiny', \
    'shinyWidgets', \
    'data.table', \
    'DT', \
    'shinydashboard', \
    'tidyverse' \
  ), repos='https://cloud.r-project.org', dependencies=TRUE)"

WORKDIR /srv/shiny-server/app

# Projenin beş R dosyasını kopyala
# COPY global.R ui.R server.R libs.R tsvOku.R ./

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/app', host='0.0.0.0', port=3838)"]

