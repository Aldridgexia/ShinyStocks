
# Load required packages and data -----------------------------------------

library(shiny)
library(quantmod)
library(stringr)

all_returns <- readRDS("./data/all_returns.rds")
# all_returns <- readRDS("all_returns.rds")
Tix <- colnames(all_returns)

# Define ui logic ---------------------------------------------------------

ui <- fluidPage(
    h1(titlePanel("Shiny Stock")),
    
    sidebarLayout(
        sidebarPanel(
            h3("Author: Jiahui Xia"),
            br(),
            selectInput("var", 
                        label = h3("Ticker"),
                        choices = as.list(Tix),
                        selected = "AAPL"),
            
            dateRangeInput("dates", 
                           h3("Choose a date range"),
                           start = "2018-01-01",
                           end = "2019-01-15")
            
        ),
        
        mainPanel(
            tabsetPanel(type = "tabs",
                        tabPanel("Candlestick Chart", plotOutput("drplot")),
                        tabPanel("Correlation Table", strong(tableOutput("cor_table"))),
                        tabPanel("Peers", textOutput("selected_var"))
            )
        )
        
    )
)

# Define server logic ----
server <- function(input, output) {
    
    output$drplot <- renderPlot({
        var <- str_replace(input$var, '\\.', '-')
        getSymbols(var, from = input$dates[1], to = input$dates[2])
        candleChart(get(var),
                    theme = chartTheme('white'))
    }, height = 400, width = 800)
    
    output$cor_table <- renderTable({
        date_index <- str_c(input$dates[1], "/", input$dates[2])
        ret_within_period <- as.data.frame(all_returns[date_index])
        cor_matrix <- cor(ret_within_period)
        peers <- names(sort(cor_matrix[input$var,], decreasing = TRUE)[1:6])
        as.data.frame(cor_matrix[peers, peers])
    }, rownames=TRUE)
    
    output$selected_var <- renderText({ 
        date_index <- str_c(input$dates[1], "/", input$dates[2])
        ret_within_period <- as.data.frame(all_returns[date_index])
        cor_matrix <- cor(ret_within_period)
        peers <- names(sort(cor_matrix[input$var,], decreasing = TRUE)[2:6])
        chosen <- paste("You have selected", 
                        input$var, 
                        ".Peers of this stock are", str_c(peers, collapse = ", "))
        chosen
    })
    
}

# Run the app ----
shinyApp(ui = ui, server = server)
