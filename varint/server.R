server <- function(input, output, session) {
  
  # session$onSessionEnded(function() {
  #   stopApp()
  # })
  
  rv <- reactiveValues(
    data = NULL,
    meta = NULL,
    col_names = NULL,
    sample = NULL
  )
  
  observeEvent(input$load_file, {
    
    req(input$selected_sample)
    
    showNotification(
      paste("File is being read:", input$selected_sample),
      type = "message",
      duration = 3
    )
    
    x <- tsvOku(input$selected_sample)
    
    df <- x$processed_df
    meta <- x$Meta
    
    setDT(df)
    names(df) <- make.unique(names(df), sep = "_")
    
    rv$data <- df
    rv$meta <- meta
    rv$col_names <- names(df)
    rv$sample <- input$selected_sample
    
    selected_cols <- intersect(default_cols, names(df))
    
    if (length(selected_cols) == 0) {
      selected_cols <- names(df)[1:min(10, ncol(df))]
    }
    
    updatePickerInput(
      session = session,
      inputId = "visible_cols",
      choices = names(df),
      selected = selected_cols
    )
    
    showNotification(
      "File read successfully.",
      type = "message",
      duration = 3
    )
  })
  
  output$variant_count <- renderValueBox({
    req(rv$data)
    
    valueBox(
      value = format(nrow(rv$data), big.mark = "."),
      subtitle = "Total Variant",
      icon = icon("dna"),
      color = "blue"
    )
  })
  
  output$column_count <- renderValueBox({
    req(rv$data)
    
    valueBox(
      value = ncol(rv$data),
      subtitle = "Total Column",
      icon = icon("columns"),
      color = "green"
    )
  })
  
  output$visible_column_count <- renderValueBox({
    req(input$visible_cols)
    
    valueBox(
      value = length(input$visible_cols),
      subtitle = "Visible Column",
      icon = icon("eye"),
      color = "yellow"
    )
  })
  
  output$sample_name_box <- renderValueBox({
    req(rv$sample)
    
    valueBox(
      value = rv$sample,
      subtitle = "Active File",
      icon = icon("file"),
      color = "purple"
    )
  })
  
  output$tbl <- renderDT({
    
    req(rv$data)
    
    datatable(
      as.data.frame(rv$data),
      escape = FALSE,
      filter = "top",
      rownames = FALSE,
      extensions = c("Buttons"),
      options = list(
        scrollX = TRUE,
        scrollY = "650px",
        pageLength = 25,
        lengthMenu = c(10, 25, 50, 100),
        deferRender = TRUE,
        stateSave = FALSE,
        dom = "lfrtBip",
        buttons = c("copy", "csv", "excel")
      )
    )
    
  }, server = TRUE)
  
  output$tbldecription <- renderDT({
    
    req(rv$meta)
    
    datatable(
      rv$meta,
      rownames = FALSE,
      options = list(
        pageLength = 50,
        lengthMenu = c(10, 25, 50, 100),
        scrollX = TRUE
      )
    )
  })
  
  output$active_filter_cols <- renderUI({
    
    vals <- input$tbl_search_columns
    
    if (is.null(vals) || is.null(rv$col_names)) {
      return(tags$em("No filter applied"))
    }
    
    n <- min(length(vals), length(rv$col_names))
    
    vals <- vals[seq_len(n)]
    cols <- rv$col_names[seq_len(n)]
    
    active <- vals != ""
    
    if (!any(active)) {
      return(tags$em("No filter applied"))
    }
    
    tagList(
      lapply(which(active), function(i) {
        tags$div(
          class = "filter-box",
          tags$strong(cols[i]),
          tags$br(),
          tags$code(vals[i])
        )
      })
    )
  })
  
  proxy <- dataTableProxy("tbl")
  
  observeEvent(input$reset_filters, {
    clearSearch(proxy)
  })
  
  observeEvent(input$visible_cols, {
    
    req(rv$data)
    req(input$visible_cols)
    
    visible_index <- match(input$visible_cols, names(rv$data)) - 1
    all_index <- seq_along(names(rv$data)) - 1
    hidden_index <- setdiff(all_index, visible_index)
    
    proxy %>%
      hideCols(hidden_index) %>%
      showCols(visible_index)
    
  }, ignoreInit = TRUE)
}
