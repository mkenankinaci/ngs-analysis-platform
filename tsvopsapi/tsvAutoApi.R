# .annotated.vcf.gz dosyasını okur csq kolonlarını açar ve tsvs klasörüne kaydeder

source("./libs.R")

#* @apiTitle vcf'ten tsv olusturan api
# =============================================================================
# vcf dosyasindan tsv dosyasi olusturan fonksiyon
# =============================================================================
#* @param sname Sadece ornek adi gonderilecek .annotated.vcf.gz fonksiyon icinde ekleniyor
#* @post /tsvCreate
  function(sname) {
    vcf <- paste0("/files/vcf/", sname, ".annotated.vcf.gz")
    tsv <- paste0(vcf, ".tsv")
    vcfmfname <- paste0(vcf,".meta.tsv") 
    # browser()
    baslangic <- Sys.time()
    asd <- read.vcfR(vcf)
    zxc <- vcfR2tidy(asd)
    setDT(zxc$fix)
    setDT(zxc$gt)
    
    csqlar <- zxc$fix$CSQ
    csqvirgul <- strsplit(csqlar,",")
    csqlarilk <- c()
    for (i in 1:length(csqvirgul)) {
      ilkparca <- csqvirgul[[i]][1]
      csqlarilk <- append(csqlarilk, ilkparca)
    }
    CSQ <- fread(text = csqlarilk, fill = TRUE, header = FALSE)
    
    csqcolname <- strsplit(strsplit(zxc$meta$Description[zxc$meta$ID == "CSQ"],": ")[[1]][2],"[|]")[[1]]
    colnames(CSQ) <- csqcolname
    
    CSQ <- as.data.table(CSQ)
    zxc$fix$CSQ <- NULL
    bakalim <- cbind(zxc$gt,zxc$fix,CSQ)
    
    write.table(bakalim, file = tsv,
                sep = "\t", col.names = TRUE, row.names = FALSE)
    vcfmeta <- metaINFO2df(asd)
    # browser()
    write.table(vcfmeta, file = vcfmfname,
                sep = "\t", col.names = TRUE, row.names = FALSE)
    bitis <- Sys.time()
    fark <- difftime(bitis, baslangic, units = "min")
    cat(paste0("tsv oluşturmak için geçen süre: ", fark, " dakikadır."))
    return(list(durum = "başarılı"))
}
# 
# # =============================================================================
# # Web linklerini olusturan fonksiyon
# # =============================================================================
# #* @param df tsvOku fonksiyonu icinde qwe olarak geliyor
# #* @post /create_safe_links
#   function(df) {
#     
#     make_link <- function(x, base_url) {
#       ifelse(
#         is.na(x) | x == "",
#         "",
#         paste0(
#           '<a href="', base_url, x,
#           '" target="_blank">', x, '</a>'
#         )
#       )
#     }
#     # browser()
#     df %>%
#       mutate(
#         
#         # 1. HGNC: 'www' eklemek ve URL'yi güvenli hale getirmek yönlendirme hatasını çözer
#         # URL formatı: https://genenames.org
#         HGNC_Link = make_link(df$SYMBOL, "https://www.genenames.org/data/gene-symbol-report/#!/hgnc_id/"),
#         
#         # 2. dbSNP: rsID'yi temizleyerek (boşluksuz) doğrudan sayfaya yönlendirir
#         # URL formatı: https://nih.gov
#         rs_id = str_extract(Existing_variation, "rs[0-9]+"),
#         
#         dbSNP_Link = ifelse(!is.na(rs_id), make_link(rs_id, "https://www.ncbi.nlm.nih.gov/snp/"), "-"),
#         
#         # 3. ClinVar: Arama yerine 'term' parametresiyle doğrudan eşleşme sağlar
#         # URL formatı: https://nih.gov
#         # (HGNC ID ile arama yapmak SYMBOL'den daha isabetlidir)
#         # ClinVar_Link = make_link(paste0(df$SYMBOL, df$HGVSc), "https://www.ncbi.nlm.nih.gov/clinvar/variation/"),
#         
#         # 4. COSMIC: COSV ID ile doğrudan arama
#         # cos_id = str_extract(Existing_variation, "COSV[0-9]+"),
#         # COSMIC_Link = ifelse(!is.na(cos_id), 
#         #                      sprintf('<a href="https://sanger.ac.uk" target="_top">🧬 %s</a>', cos_id, cos_id), 
#         #                      "-"),
#         
#         # 5. Ensembl: ENST ID ile doğrudan transkript sayfası
#         # Ensembl_Link = make_link(df$Feature, "https://www.ensembl.org/Homo_sapiens/Gene/Summary?g=")
#         # Yukaridaki eski link calismadi asagidaki link calisiyor
#         Ensembl_Link = make_link(df$Feature, "https://resolver.ensembl.org/id/")
#       )
# }
# 
# # =============================================================================
# # tsv dosyasini okuyup, duzenleyip, linkler ekleyen fonksiyon
# # =============================================================================
# #* @param sname Sadece ornek ismi .annotated.vcf.gz.tsv fonksiyon icerisinde otomatik geliyor
# #* @post /tsvOku
#   function(sname) {
#     qwe <- fread(paste0("../../../../n8n-project/local-files/vcf/", sname, ".annotated.vcf.gz.tsv"))
#     qwemeta <- fread(paste0("../../../../n8n-project/local-files/vcf/", sname, ".annotated.vcf.gz.meta.tsv"))
#     # browser()
#     names(qwe) <- make.unique(names(qwe), sep = "_")
#     processed_df <- create_safe_links(qwe)
#     tekrarKolon <- names(processed_df)[grep(pattern = "_1",names(processed_df))]
#     processed_df[,(tekrarKolon) := NULL]
#     faktorOlacak <- c("gt_GT","Feature_type", "BIOTYPE", "Consequence", "STRAND", "VARIANT_CLASS")
#     processed_df[,(faktorOlacak) := lapply(.SD, as.factor), .SDcols = faktorOlacak]
#     prcssddfmeta <- list("processed_df" = processed_df, "Meta" = qwemeta)
#     # browser()
#     return(prcssddfmeta)
# }
# 
# #* @post /veri-isle
# function(girdi) {
#   return(list(durum = "başarılı"))
# }