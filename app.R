# app.R
# Shiny App: Complete Customer Segmentation + Profile Dashboard

library(shiny)
library(shinydashboard)
library(tidyverse)
library(lubridate)
library(DT)
library(plotly)

# -----------------------------
# Step 1: Load & Prepare Data
# -----------------------------
df <- read_csv("online_retail_clean.csv") %>%
  mutate(revenue = quantity * price)

# Reference date for recency
ref_date <- max(df$invoice_date) + days(1)

# RFM calculation
rfm <- df %>%
  group_by(customer_id) %>%
  summarise(
    Recency = as.numeric(ref_date - max(invoice_date)),
    Frequency = n(),
    Monetary = sum(revenue, na.rm = TRUE)
  ) %>%
  ungroup()

# KMeans clustering
rfm_scaled <- scale(rfm[,c("Recency","Frequency","Monetary")])
set.seed(123)
km <- kmeans(rfm_scaled, centers = 3, nstart = 25)
rfm$Cluster <- as.factor(km$cluster)

# Business-friendly segment labels
cluster_labels <- c("1"="Loyal / Potential","2"="Champions","3"="At Risk")
rfm$Segment <- cluster_labels[as.character(rfm$Cluster)]

# -----------------------------
# Step 2: UI
# -----------------------------
ui <- dashboardPage(
  dashboardHeader(title = "Customer Segmentation Dashboard"),
  
  dashboardSidebar(
    selectInput("segment", "Select Segment:",
                choices = c("All", unique(rfm$Segment)), selected = "All"),
    hr(),
    selectInput("cust_id", "Select Customer ID:",
                choices = sort(unique(rfm$customer_id)))
  ),
  
  dashboardBody(
    # KPI boxes
    fluidRow(
      valueBoxOutput("total_customers"),
      valueBoxOutput("total_revenue"),
      valueBoxOutput("avg_monetary"),
      valueBoxOutput("avg_frequency")
    ),
    
    tabsetPanel(
      tabPanel("Scatterplots", 
               plotlyOutput("scatter1"),
               plotlyOutput("scatter2")),
      tabPanel("Boxplots",
               plotlyOutput("boxplots")),
      tabPanel("Customer Table",
               DTOutput("table")),
      tabPanel("Customer Profile",
               verbatimTextOutput("cust_summary"),
               plotlyOutput("cust_revenue_chart"),
               DTOutput("cust_history"))
    )
  )
)

# -----------------------------
# Step 3: Server
# -----------------------------
server <- function(input, output) {
  
  # Reactive filtered RFM
  filtered_rfm <- reactive({
    if (input$segment == "All") {
      rfm
    } else {
      rfm %>% filter(Segment == input$segment)
    }
  })
  
  # -----------------------------
  # KPI / Value Boxes
  # -----------------------------
  output$total_customers <- renderValueBox({
    valueBox(
      value = nrow(filtered_rfm()),
      subtitle = "Total Customers",
      icon = icon("users"),
      color = "blue"
    )
  })
  
  output$total_revenue <- renderValueBox({
    valueBox(
      value = round(sum(filtered_rfm()$Monetary),2),
      subtitle = "Total Revenue",
      icon = icon("dollar-sign"),
      color = "green"
    )
  })
  
  output$avg_monetary <- renderValueBox({
    valueBox(
      value = round(mean(filtered_rfm()$Monetary),2),
      subtitle = "Average Monetary",
      icon = icon("chart-line"),
      color = "purple"
    )
  })
  
  output$avg_frequency <- renderValueBox({
    valueBox(
      value = round(mean(filtered_rfm()$Frequency),1),
      subtitle = "Average Frequency",
      icon = icon("shopping-cart"),
      color = "yellow"
    )
  })
  
  # -----------------------------
  # Scatterplots
  # -----------------------------
  output$scatter1 <- renderPlotly({
    df_plot <- filtered_rfm()
    plot_ly(df_plot, x=~Recency, y=~Monetary, color=~Segment,
            type="scatter", mode="markers", marker=list(size=7)) %>%
      layout(title="Recency vs Monetary")
  })
  
  output$scatter2 <- renderPlotly({
    df_plot <- filtered_rfm()
    plot_ly(df_plot, x=~Frequency, y=~Monetary, color=~Segment,
            type="scatter", mode="markers", marker=list(size=7)) %>%
      layout(title="Frequency vs Monetary")
  })
  
  # -----------------------------
  # Boxplots
  # -----------------------------
  output$boxplots <- renderPlotly({
    df_plot <- filtered_rfm()
    rfm_long <- df_plot %>%
      pivot_longer(cols=c(Recency, Frequency, Monetary), names_to="Metric", values_to="Value")
    
    plot_ly(rfm_long, x=~Segment, y=~Value, color=~Segment, type="box") %>%
      layout(title="RFM Distribution by Segment", xaxis=list(title="Segment"), yaxis=list(title="Value"))
  })
  
  # -----------------------------
  # Summary Table
  # -----------------------------
  output$table <- renderDT({
    df_plot <- filtered_rfm()
    df_plot %>%
      summarise(
        Count = n(),
        Avg_Recency = round(mean(Recency),1),
        Avg_Frequency = round(mean(Frequency),1),
        Avg_Monetary = round(mean(Monetary),1)
      ) %>%
      datatable()
  })
  
  # -----------------------------
  # Customer Profile
  # -----------------------------
  selected_customer <- reactive({
    rfm %>% filter(customer_id == input$cust_id)
  })
  
  output$cust_summary <- renderPrint({
    cust <- selected_customer()
    cat("Customer ID:", cust$customer_id, "\n")
    cat("Segment:", cust$Segment, "\n")
    cat("Recency:", cust$Recency, "days\n")
    cat("Frequency:", cust$Frequency, "\n")
    cat("Monetary:", round(cust$Monetary,2), "\n")
  })
  
  # Customer Revenue Over Time Chart
  output$cust_revenue_chart <- renderPlotly({
    cust_df <- df %>% filter(customer_id == input$cust_id) %>%
      group_by(invoice_date) %>%
      summarise(daily_revenue = sum(revenue, na.rm=TRUE))
    
    plot_ly(cust_df, x=~invoice_date, y=~daily_revenue, type="scatter", mode="lines+markers") %>%
      layout(title="Customer Revenue Over Time", xaxis=list(title="Invoice Date"), yaxis=list(title="Revenue"))
  })
  
  # Customer Purchase History
  output$cust_history <- renderDT({
    df %>%
      filter(customer_id == input$cust_id) %>%
      select(Invoice, invoice_date, description, quantity, price, revenue) %>%
      datatable(options = list(pageLength = 10))
  })
}

# -----------------------------
# Step 4: Run the App
# -----------------------------
shinyApp(ui = ui, server = server)
