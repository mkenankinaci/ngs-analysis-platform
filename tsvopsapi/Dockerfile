FROM rocker/r-ver:4.4.3

# Sistem bağımlılıkları
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    make \
    libsodium-dev \
    libuv1-dev \
    zlib1g-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# R paketlerini yükle ve yükleme hatalarını kontrol et
RUN Rscript -e "install.packages(c('plumber', 'vcfR', 'data.table'), repos='https://cloud.r-project.org'); stopifnot(requireNamespace('plumber', quietly=TRUE), requireNamespace('vcfR', quietly=TRUE), requireNamespace('data.table', quietly=TRUE))"

# Uygulama dosyaları
COPY tsvAutoApi.R /app/tsvAutoApi.R
COPY libs.R /app/libs.R

EXPOSE 8000

CMD ["Rscript", "-e", "pr <- plumber::plumb('/app/tsvAutoApi.R'); pr$run(host='0.0.0.0', port=8000)"]
