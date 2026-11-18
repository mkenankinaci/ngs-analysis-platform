source("./libs.R")
source("./tsvOku.R")

default_cols <- c(
  "ChromKey", "POS", "gt_DP", "gt_GQ", "gt_GT", "gt_GT_alleles",
  "QUAL", "SYMBOL", "Feature_type", "BIOTYPE", "VARIANT_CLASS",
  "SIFT", "PolyPhen", "MAX_AF", "CLIN_SIG", "HGNC_Link",
  "dbSNP_Link", "Ensembl_Link", "HGMD_Link"
)

tsv_dir <- "/files/vcf"

available_files <- list.files(
  tsv_dir,
  # pattern = "\\.tsv$|\\.tsv\\.gz$",
  pattern = "\\.vcf.gz.tsv$",
  full.names = FALSE
)

available_samples <- available_files |>
  sub("\\.annotated\\.vcf\\.gz\\.tsv$", "", x = _) |>
  sub("\\.vcf\\.gz\\.tsv$", "", x = _) |>
  sub("\\.tsv$", "", x = _)