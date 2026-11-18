source("./libs.R")
# source("./tsvAuto.R")

future::plan(future::multisession)

options(shiny.maxRequestSize = 500 * 1024^3)  # 50 GB

# addResourcePath("fastp_rapor", "../n8n-project/local-files/reports/fastp/")
# addResourcePath("fastqc_rapor", "../n8n-project/local-files/reports/fastqc/")
# addResourcePath("vep_rapor", "../n8n-project/local-files/vcf/")

addResourcePath("fastp_rapor", "/files/reports/fastp/")
addResourcePath("fastqc_rapor", "/files/reports/fastqc/")
addResourcePath("vep_rapor", "/files/vcf/")