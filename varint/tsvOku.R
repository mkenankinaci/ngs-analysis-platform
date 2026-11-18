create_safe_links <-  function(df) {
  make_link <- function(x, base_url) {
    ifelse(
      is.na(x) | x == "",
      "",
      paste0(
        '<a href="', base_url, x,
        '" target="_blank">', x, '</a>'
      )
    )
  }
  # browser()
  df %>%
    mutate(
      
      # 1. HGNC: 'www' eklemek ve URL'yi güvenli hale getirmek yönlendirme hatasını çözer
      # URL formatı: https://genenames.org
      HGNC_Link = make_link(df$SYMBOL, "https://www.genenames.org/data/gene-symbol-report/#!/hgnc_id/"),
      
      # 2. dbSNP: rsID'yi temizleyerek (boşluksuz) doğrudan sayfaya yönlendirir
      # URL formatı: https://nih.gov
      rs_id = str_extract(Existing_variation, "rs[0-9]+"),
      
      dbSNP_Link = ifelse(!is.na(rs_id), make_link(rs_id, "https://www.ncbi.nlm.nih.gov/snp/"), "-"),
      
      # 3. ClinVar: Arama yerine 'term' parametresiyle doğrudan eşleşme sağlar
      # URL formatı: https://nih.gov
      # (HGNC ID ile arama yapmak SYMBOL'den daha isabetlidir)
      # ClinVar_Link = make_link(paste0(df$SYMBOL, df$HGVSc), "https://www.ncbi.nlm.nih.gov/clinvar/variation/"),
      
      # 4. COSMIC: COSV ID ile doğrudan arama
      # cos_id = str_extract(Existing_variation, "COSV[0-9]+"),
      # COSMIC_Link = ifelse(!is.na(cos_id), 
      #                      sprintf('<a href="https://sanger.ac.uk" target="_top">🧬 %s</a>', cos_id, cos_id), 
      #                      "-"),
      
      # 5. Ensembl: ENST ID ile doğrudan transkript sayfası
      # Ensembl_Link = make_link(df$Feature, "https://www.ensembl.org/Homo_sapiens/Gene/Summary?g=")
      # Yukaridaki eski link calismadi asagidaki link calisiyor
      Ensembl_Link = make_link(df$Feature, "https://resolver.ensembl.org/id/"),
      
      # Yukaridaki virgulu ve alt satiri yeni yazdim
      
      HGMD_Link = make_link(df$SYMBOL, "https://www.hgmd.cf.ac.uk/ac/gene.php?gene=")
    )
}

tsvOku <- function(sname) {
  qwe <- fread(paste0("/files/vcf/", sname, ".annotated.vcf.gz.tsv"))
  qwemeta <- fread(paste0("/files/vcf/", sname, ".annotated.vcf.gz.meta.tsv"))
  # browser()
  names(qwe) <- make.unique(names(qwe), sep = "_")
  processed_df <- create_safe_links(qwe)
  tekrarKolon <- names(processed_df)[grep(pattern = "_1",names(processed_df))]
  processed_df[,(tekrarKolon) := NULL]
  faktorOlacak <- c("gt_GT","Feature_type", "BIOTYPE", "Consequence", "STRAND", "VARIANT_CLASS")
  processed_df[,(faktorOlacak) := lapply(.SD, as.factor), .SDcols = faktorOlacak]
  prcssddfmeta <- list("processed_df" = processed_df, "Meta" = qwemeta)
  # browser()
  return(prcssddfmeta)
}