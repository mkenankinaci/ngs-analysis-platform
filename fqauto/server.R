server <- function(input, output, session) {
  timeloop <- reactiveTimer(2000)
  
  # observe({
  #   sname <- input$sname
  #   # browser()
  #   timeloop()
  #   vep_file <- file.path("/files/vcf/", paste0(sname, ".annotated.vcf.gz_summary.html"))
  #   # tsv_file <- file.path("/media/Depo/denemeOtomasyon/n8n-project/tsvs", paste0(sname, ".annotated.vcf.gz.tsv"))
  #   tsv_file <- file.path("/files/vcf/", paste0(sname, ".annotated.vcf.gz.tsv"))
  #   if (!file.exists(tsv_file) & file.exists(vep_file)) {
  #     tsvOlustur(vep_file)
  #   }
  # })
  
  sample_log_path <- reactive({
    sample_name <- input$sname
    req(isTruthy(sample_name), grepl("^[A-Za-z0-9][A-Za-z0-9._-]{0,199}$", sample_name))
    file.path("/files/logs", paste0(sample_name, "_terminal.log"))
  })

  output$download_log <- downloadHandler(
    filename = function() basename(sample_log_path()),
    content = function(file) {
      log_file <- sample_log_path()
      if (!file.exists(log_file) || !file.copy(log_file, file, overwrite = TRUE)) {
        stop("The log file could not be downloaded.")
      }
    },
    contentType = "application/octet-stream"
  )

  observeEvent(input$start, {
    
    print(paste0("The button was pressed.", " - ", Sys.time()))
    
    req(input$sname)
    req(input$fastq1)
    req(input$fastq2)
    req(input$bed)
    
    
    formVerileri <- list(
      ornekAdi = input$sname,
      fq1      = input$fastq1,
      fq2      = input$fastq2,
      bedFile  = input$bed,
      genome   = input$genome,
      paired   = input$paired,
      ncore    = input$nCore
    )
    
    
    sample_dir <- file.path("/files/fastqs")#, sname)
  #   # sample_dir <- file.path("../n8n-project/local-files/inbox")#, sname)
  #   
    bed_dir <- file.path("/files/bed")
  #   # bed_dir <- file.path("../n8n-project/local-files/bed")
  #   
  #   # if (dir.exists(sample_dir)) {
  #   #   output$status <- renderText("Bu örnek adıyla daha önce klasör oluşturulmuş.")
  #   #   return()
  #   # }
  #   # 
  #   # dir.create(sample_dir, recursive = TRUE)
  #   
    fastq1_dest <- file.path(sample_dir, basename(input$fastq1$name))
    fastq2_dest <- file.path(sample_dir, basename(input$fastq2$name))
    bed_dest    <- file.path(bed_dir, basename(input$bed$name))

    sources <- c(input$fastq1$datapath, input$fastq2$datapath, input$bed$datapath)
    destinations <- c(fastq1_dest, fastq2_dest, bed_dest)
    if (anyDuplicated(destinations)) {
      output$status <- renderText("R1 and R2 must have different filenames.")
      return()
    }

    for (i in seq_along(destinations)) {
      source <- sources[[i]]
      destination <- destinations[[i]]
      if (file.exists(destination)) {
        hashes <- tools::md5sum(c(source, destination))
        if (!anyNA(hashes) && hashes[[1]] == hashes[[2]]) {
          next
        }
        message <- paste("A different file already exists:", basename(destination),
                         "Rename the upload and try again.")
        output$status <- renderText(message)
        return()
      }
      if (!file.copy(source, destination)) {
        message <- paste("Could not stage", basename(destination),
                         "in", dirname(destination), "- check permissions and disk space.")
        output$status <- renderText(message)
        return()
      }
    }

    n8n_ic_url <- Sys.getenv(
      "NGS_WEBHOOK_URL",
      "http://n8n:5678/webhook/280eb49f-7dd6-4eac-a5cd-94c3e54fafd1"
    )
    response <- POST(url = n8n_ic_url, body = formVerileri, encode = "json")
  #   
  #   job_info <- list(
  #     sname = sname,
  #     fastq1 = fastq1_dest,
  #     fastq2 = fastq2_dest,
  #     genome = input$genome,
  #     paired = input$paired,
  #     bed = bed_dest,
  #     nCore = input$nCore,
  #     created_at = as.character(Sys.time()),
  #     status = "ready"
  #   )
  #   
    output$status <- renderText({
      if (status_code(response) == 200) {
        "The data has been transmitted to the automation system. The automation has been initiated."
      } else {
        paste("Connection error! Status code: ", status_code(response))
      }
    })
  #   
  #   tmp_done  <- file.path(sample_dir, paste0(sname, ".done.tmp"))
  #   done_file <- file.path(sample_dir, paste0(sname, ".done"))
  #   
  #   # browser()
  #   
  #   writeLines(
  #     jsonlite::toJSON(job_info, pretty = TRUE, auto_unbox = TRUE),
  #     tmp_done
  #   )
  #   
  #   file.rename(tmp_done, done_file)
  #   
  #   # output$status <- renderText(
  #   #   paste0(
  #   #     "Otomasyon başlatma dosyası oluşturuldu:\n",
  #   #     done_file
  #   #   )
  #   # )
  #   
    output$terminal <- renderText({
      invalidateLater(2000, session)

      log_file <- sample_log_path()

      if (!file.exists(log_file)) {
        return("No terminal output yet.")
      }

      # paste(tail(readLines(log_file, warn = FALSE), 150), collapse = "\n")
      paste(tail(readLines(log_file, warn = FALSE), 20), collapse = "\n")
    })
    
    output$logs <- renderUI({
      invalidateLater(2000, session)

      log_file <- sample_log_path()
      if (!file.exists(log_file)) {
        tags$span("Henüz log dosyası oluşmadı.", style = "color: red;")
      } else {
        downloadLink("download_log", label = basename(log_file))
      }
    })

    output$fastp <- renderUI({
      invalidateLater(2000, session)

      fastp_file <- file.path("/files/reports/fastp", paste0(input$sname, "_fastp.html"))
      # fastp_file <- file.path("../n8n-project/local-files/reports/fastp", paste0(sname, "_fastp.html"))

      if (!file.exists(fastp_file)) {
        tags$span("The fastp report has not been generated yet.", style = "color: red;")
      } else {
        tags$a(href = paste0("fastp_rapor/", paste0(input$sname, "_fastp.html")), paste0(input$sname, "_fastp.html"), target = "_blank")
      }
    })

    output$fastqc1 <- renderUI({
      invalidateLater(2000, session)

      fastqc_file1 <- file.path("/files/reports/fastqc/", paste0(input$sname, "_trimmed_R1_fastqc.html"))
      # fastqc_file1 <- file.path("../n8n-project/local-files/reports/fastqc/", paste0(sname, "_trimmed_R1_fastqc.html"))

      if (!file.exists(fastqc_file1)) {
        tags$span("The FastQC R1 report has not been generated yet.", style = "color: red;")
      } else {
        tags$a(href = paste0("fastqc_rapor/", paste0(input$sname, "_trimmed_R1_fastqc.html")), paste0(input$sname, "_trimmed_R1_fastqc.html"), target = "_blank")
      }
    })

    output$fastqc2 <- renderUI({
      invalidateLater(2000, session)

      fastqc_file2 <- file.path("/files/reports/fastqc/", paste0(input$sname, "_trimmed_R2_fastqc.html"))
      # fastqc_file2 <- file.path("../n8n-project/local-files/reports/fastqc/", paste0(sname, "_trimmed_R2_fastqc.html"))

      if (!file.exists(fastqc_file2)) {
        tags$span("The FastQC R2 report has not been generated yet.", style = "color: red;")
      } else {
        tags$a(href = paste0("fastqc_rapor/", paste0(input$sname, "_trimmed_R2_fastqc.html")), paste0(input$sname, "_trimmed_R2_fastqc.html"), target = "_blank")
      }
    })

    output$vep <- renderUI({
      invalidateLater(2000, session)

      vep_file <- file.path("/files/vcf/", paste0(input$sname, ".annotated.vcf.gz_summary.html"))
      # vep_file <- file.path("../n8n-project/local-files/vcf/", paste0(sname, ".annotated.vcf.gz_summary.html"))
      tsv_file <- file.path("/files/vcf/", paste0(input$sname, ".annotated.vcf.gz.tsv"))
      # tsv_file <- file.path("../n8n-project/local-files/vcf/", paste0(sname, ".annotated.vcf.gz.tsv"))

      if (!file.exists(vep_file)) {
        tags$span("The VEP report has not been generated yet.", style = "color: red;")
      } else {
        tags$a(href = paste0("vep_rapor/", paste0(input$sname, ".annotated.vcf.gz_summary.html")), paste0(input$sname, ".annotated.vcf.gz_summary.html"), target = "_blank")
      }
    })
  # ---------------------------------------------------------------------------------------------
    # cat(paste(as.character(formVerileri)))
  })
  
  
  observeEvent(input$vcf2tsv, {
    
    req(input$vcfFiles)
    
    shinyjs::disable("vcf2tsv")
    
    secilen_dosya <- as.character(input$vcfFiles)
    # api_url <- "http://127.0.0.1:8000/tsvCreate"
    # api_url <- "http://0.0.0.0:8000/tsvCreate"
    api_url <- "http://tsvauto-api:8000/tsvCreate"
    # api_url <- "http://n8ntest-tsvauto-api-1:8000/tsvCreate"
    output$tsvStatus <- renderText({
      paste0("TSV is being created: ", secilen_dosya, " — please wait...")
    })
    
    session$onFlushed(function() {
      
      promises::future_promise({
        
        response <- httr::POST(
          url = api_url,
          body = list(sname = secilen_dosya),
          encode = "form",
          httr::timeout(600)
        )
        
        status <- httr::status_code(response)
        
        yanit_metni <- httr::content(
          response,
          as = "text",
          encoding = "UTF-8"
        )
        
        if (status < 200 || status >= 300) {
          stop(
            paste0(
              "API HTTP error: ", status,
              ". Response: ", yanit_metni
            )
          )
        }
        
        
        sonuc <- tryCatch(
          jsonlite::fromJSON(yanit_metni, simplifyVector = FALSE),
          error = function(e) NULL
        )
        
        list(
          http_status = status,
          body = yanit_metni,
          sonuc = sonuc
        )
        
      }) %...>% (function(yanit) {
        
        sonuc <- yanit$sonuc
        
        # API 2xx yanıtı döndürdü; varsa durum alanını da kontrol et.
        durum <- if (!is.null(sonuc$durum)) {
          as.character(sonuc$durum)
        } else {
          NULL
        }
        
        if (is.null(durum) || identical(durum, "success")) {
          
          output$tsvStatus <- renderText({
            paste0(
              "TSV file successfully created: ",
              secilen_dosya
            )
          })
          
          showNotification(
            "The TSV file has been successfully created!",
            type = "message",
            duration = 5
          )
          
        } else {
          
          output$tsvStatus <- renderText({
            paste0("API response: ", durum)
          })
          
          showNotification(
            paste("The API did not return the expected result:", durum),
            type = "warning",
            duration = 5
          )
        }
        
        shinyjs::enable("vcf2tsv")
        
      }) %...!% (function(hata) {
        
        mesaj <- conditionMessage(hata)
        
        output$tsvStatus <- renderText({
          paste("TSV could not be created:", mesaj)
        })
        
        showNotification(
          paste("TSV could not be created:", mesaj),
          type = "error",
          duration = NULL
        )
        
        shinyjs::enable("vcf2tsv")
        
      })
      
    }, once = TRUE)
    
  })
}