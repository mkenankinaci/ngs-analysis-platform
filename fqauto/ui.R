dashboardPage(
  # dashboardHeader(title = "FASTQ Otomasyonu"),
  dashboardHeader(title = "FASTQ Automation"),
  
  dashboardSidebar(
    div(style = "padding: 15px;",
        # selectInput("sname", "Örnek adı",
        #             choices = unique(sub("_R[1,2].*$", "",
        #                           # dir("/files/fastqs/",
        #                           dir("/media/Depo/denemeOtomasyon/n8n-project/local-files/fastqs/",
        #                               pattern = "\\.fastq.gz$"))),
        #             selected = NULL,
        #             multiple = FALSE
        # ),
        
        # textInput("sname", "Örnek adı"),
        textInput("sname", "Sample name"),
        
        # fileInput("fastq1", "FASTQ R1 dosyası seç", accept = c(".fastq", ".fq", ".gz")),
        fileInput("fastq1", "Select FASTQ R1 file", accept = c(".fastq", ".fq", ".gz")),
        # fileInput("fastq2", "FASTQ R2 dosyası seç", accept = c(".fastq", ".fq", ".gz")),
        fileInput("fastq2", "Select FASTQ R2 file", accept = c(".fastq", ".fq", ".gz")),
        # fileInput("bed", "BED dosyası seç", accept = c(".bed")),
        fileInput("bed", "Select BED file", accept = c(".bed")),
        
        selectInput("genome", "Genome", choices = c("hg38"), selected = "hg38"),
        
        checkboxInput("paired", "Paired-end", value = TRUE),
        
        # numericInput("nCore", "Çekirdek sayısı", value = 8, min = 1, max = 32),
        numericInput("nCore", "Number of cores", value = 8, min = 1, max = 32),
        
        # actionButton("start", "Otomasyonu Başlat", class = "btn-primary"),
        actionButton("start", "Start automation", class = "btn-primary"),
        
        br(),
        br(),
        
        # selectInput("vcfFiles", "tsv oluşturulacak vcf seçiniz",
        #             choices = sub("\\.annotated.vcf.gz$", "",
        #                           # dir("/files/vcf/",
        #                           dir("/media/Depo/denemeOtomasyon/n8n-project/local-files/fastqs/",
        #                               pattern = "\\.annotated.vcf.gz$")),
        #             selected = NULL,
        #             multiple = FALSE
        #             ),
        selectInput("vcfFiles", "Select the VCF file to create a TSV file",
                    choices = sub("\\.annotated.vcf.gz$", "",
                                  dir("/files/vcf/",
                                  # dir("../local_files/vcf/",
                                      pattern = "\\.annotated.vcf.gz$")),
                    selected = NULL,
                    multiple = FALSE
        ),
        # actionButton("vcf2tsv", "tsv oluştur", class = "btn-primary"),
        actionButton("vcf2tsv", "Create tsv", class = "btn-primary"),
        br(),
        textOutput("tsvStatus")
    )
  ),
  
  dashboardBody(
    shinyjs::useShinyjs(),
    fluidRow(
      box(title = "System Status", width = 12, status = "primary", solidHeader = TRUE,
          verbatimTextOutput("status"),
          uiOutput("logs"),
          h3("Terminal Log"),
          verbatimTextOutput("terminal")
      )
    ),
    fluidRow(
      box(title = "Analysis Reports", width = 12, status = "success", solidHeader = TRUE,
          h4("Fastp report"),
          uiOutput("fastp"),
          br(),
          h4("FastQC reports"),
          uiOutput("fastqc1"),
          uiOutput("fastqc2"),
          br(),
          h4("VEP report"),
          uiOutput("vep")
      )
    )
  )
)