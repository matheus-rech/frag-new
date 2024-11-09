# Enhanced Shiny application demonstrating integration with Fragments

# Load required libraries
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(tidyr)
library(readr)
library(lubridate)
library(stringr)

# Define UI
ui <- fluidPage(
    theme = bslib::bs_theme(version = 4, bootswatch = "flatly"),
    
    titlePanel("Data Analysis Dashboard"),
    
    sidebarLayout(
        sidebarPanel(
            # Data generation controls
            numericInput("n_points", 
                        "Number of data points:", 
                        value = 100, 
                        min = 10, 
                        max = 1000),
            
            selectInput("plot_type",
                       "Select Plot Type:",
                       choices = c("Scatter Plot" = "scatter",
                                 "Box Plot" = "box",
                                 "Time Series" = "time")),
            
            # Conditional inputs based on plot type
            conditionalPanel(
                condition = "input.plot_type == 'scatter'",
                sliderInput("point_size", 
                           "Point Size:",
                           min = 1, 
                           max = 10, 
                           value = 3)
            ),
            
            actionButton("generate", "Generate Data", 
                        class = "btn-primary")
        ),
        
        mainPanel(
            tabsetPanel(
                tabPanel("Visualization",
                         plotlyOutput("main_plot", height = "500px"),
                         verbatimTextOutput("summary_stats")),
                tabPanel("Data Table",
                         DT::dataTableOutput("data_table"))
            )
        )
    )
)

# Define server logic
server <- function(input, output, session) {
    # Reactive data generation
    dataset <- eventReactive(input$generate, {
        n <- input$n_points
        
        # Generate sample data
        data.frame(
            timestamp = seq(as.POSIXct(Sys.time() - days(n)), 
                          as.POSIXct(Sys.time()), 
                          length.out = n),
            value = cumsum(rnorm(n)),
            category = sample(LETTERS[1:4], n, replace = TRUE),
            metric = runif(n) * 100
        )
    })
    
    # Main plot output
    output$main_plot <- renderPlotly({
        req(dataset())
        
        data <- dataset()
        
        p <- switch(input$plot_type,
                   "scatter" = {
                       ggplot(data, aes(x = metric, y = value, color = category)) +
                           geom_point(size = input$point_size) +
                           labs(title = "Scatter Plot Analysis",
                                x = "Metric",
                                y = "Value")
                   },
                   "box" = {
                       ggplot(data, aes(x = category, y = value, fill = category)) +
                           geom_boxplot() +
                           labs(title = "Distribution by Category",
                                x = "Category",
                                y = "Value")
                   },
                   "time" = {
                       ggplot(data, aes(x = timestamp, y = value, color = category)) +
                           geom_line() +
                           labs(title = "Time Series Analysis",
                                x = "Time",
                                y = "Value")
                   }
        )
        
        p <- p + theme_minimal() +
            theme(legend.position = "bottom")
        
        ggplotly(p) %>%
            layout(showlegend = TRUE)
    })
    
    # Summary statistics output
    output$summary_stats <- renderPrint({
        req(dataset())
        
        data <- dataset()
        
        cat("Summary Statistics:\n\n")
        summary(data$value)
    })
    
    # Data table output
    output$data_table <- DT::renderDataTable({
        req(dataset())
        
        DT::datatable(dataset(),
                     options = list(pageLength = 10,
                                  scrollX = TRUE),
                     rownames = FALSE)
    })
}

# Run the application
shinyApp(ui = ui, server = server)
