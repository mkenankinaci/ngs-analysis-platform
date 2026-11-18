dashboardPage(
  
  dashboardHeader(
    title = "Variant Analysis Panel"
  ),
  
  dashboardSidebar(
    width = 320,
    
    sidebarMenu(
      menuItem("File and Variant Table", tabName = "variant_table", icon = icon("table")),
      menuItem("Column Descriptions", tabName = "column_desc", icon = icon("circle-info"))
    ),
    
    div(
      class = "sidebar-card",
      h4(icon("folder-open"), " File"),
      
      pickerInput(
        inputId = "selected_sample",
        label = "File to be read",
        choices = available_samples,
        selected = if (length(available_samples) > 0) available_samples[1] else NULL,
        multiple = FALSE,
        options = list(
          `live-search` = TRUE,
          size = 10
        )
      ),
      
      actionButton(
        inputId = "load_file",
        label = "Read the File",
        icon = icon("folder-open"),
        class = "btn-primary sidebar-btn"
      )
    ),
    
    div(
      class = "sidebar-card",
      h4(icon("eye"), " Columns"),
      
      pickerInput(
        inputId = "visible_cols",
        label = "Columns to display",
        choices = NULL,
        selected = NULL,
        multiple = TRUE,
        options = list(
          `actions-box` = TRUE,
          `live-search` = TRUE,
          `selected-text-format` = "count > 5",
          size = 15
        )
      )
    ),
    
    div(
      class = "sidebar-card",
      h4(icon("filter"), " Active Filters"),
      
      uiOutput("active_filter_cols"),
      
      actionButton(
        inputId = "reset_filters",
        label = "Reset Filters",
        icon = icon("rotate-left"),
        class = "btn-warning sidebar-btn"
      )
    )
  ),
  
  dashboardBody(
    
    tags$head(
      tags$style(HTML("
    .content-wrapper, .right-side {
      background-color: #f4f6f9;
    }

    .box {
      border-radius: 8px;
    }

    .dataTables_wrapper {
      font-size: 13px;
    }

    .main-sidebar .sidebar {
      padding: 10px;
    }

    .sidebar-card {
      background-color: #222d32;
      border: 1px solid #3c8dbc;
      border-radius: 8px;
      padding: 12px;
      margin: 12px 4px;
    }

    .sidebar-card h4 {
      color: #ffffff;
      font-size: 15px;
      margin-top: 0;
      margin-bottom: 12px;
      border-bottom: 1px solid #3c8dbc;
      padding-bottom: 8px;
    }

    .sidebar-card label {
      color: #ffffff;
      font-weight: 400;
    }

    .sidebar-card .form-group {
      margin-bottom: 12px;
    }

    .sidebar-card .bootstrap-select {
      width: 100% !important;
    }

    .sidebar-card .btn,
    .sidebar-btn {
      width: 100% !important;
      box-sizing: border-box;
      margin-top: 6px;
    }

    .filter-box {
      padding: 6px;
      margin-bottom: 6px;
      border: 1px solid #ddd;
      border-radius: 6px;
      background-color: #f8f8f8;
      color: #333;
      word-break: break-word;
    }

    .sidebar-card em {
      color: #cccccc;
      display: block;
      margin-bottom: 10px;
    }
  "))
    ),
    
    tabItems(
      
      tabItem(
        tabName = "variant_table",
        
        fluidRow(
          valueBoxOutput("variant_count", width = 3),
          valueBoxOutput("column_count", width = 3),
          valueBoxOutput("visible_column_count", width = 3),
          valueBoxOutput("sample_name_box", width = 3)
        ),
        
        fluidRow(
          box(
            title = "Variant Table",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            collapsible = TRUE,
            DTOutput("tbl")
          )
        )
      ),
      
      tabItem(
        tabName = "column_desc",
        
        fluidRow(
          box(
            title = "Column Descriptions",
            width = 12,
            status = "info",
            solidHeader = TRUE,
            collapsible = TRUE,
            DTOutput("tbldecription")
          )
        )
      )
    )
  )
)