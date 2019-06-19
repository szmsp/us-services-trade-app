###############################################################################################################################

# README
# Project:    Services trade from the Department of Commerce Bureau of Economic Analysis
# Objective:  Server for BEA services data app

# BEA API Setup
# API Key request here: https://apps.bea.gov/API/signup/index.cfm 

# For help on BEA international services trade data API:
# https://apps.bea.gov/api/_pdf/bea_web_service_api_user_guide.pdf

# For BEA services trade category definitions:
# https://www.bea.gov/sites/default/files/methodologies/ONE%20PDF%20-%20IEA%20Concepts%20Methods.pdf#page=63

# To run app, replace "[path]" and "[key]" below

###############################################################################################################################

# Root paths
folder <- "[path]"
setwd(folder)
# BEA API key obtained from website above
bea_key <- "[key]"

# BEA services data API call function
source(paste0(folder, "bea_services_api_call.R"))

###############################################################################################################################

# Load libraries
library("tidyverse")  
library("sqldf")      
library("ggthemes")   
library("zoo")        
library("dplyr")      
library("tools")
library("lubridate") 
library("reshape2")
library("jsonlite")
library("shiny")

#### CREATE SHINY APP SERVER ####

server <- function(input, output) {
  
  #### PULL BILATERAL TRADE IN SERVICES DATA ####
  
  output$barchart <- renderPlot({
    
    # Call and format data for bar chart
    
    data <- services_call(country = input$country, bea_key, first_year = input$first_year, final_year = input$final_year)
    by_service <- subset(data, TypeOfService == input$service)
    by_service_bar <- by_service[, c(1, 2, 5, 11)]
    by_service_bar$DataValue <- as.numeric(by_service_bar$DataValue)
    
    # Create barchart object the plotOutput function is expecting
    
    ggplot(data = by_service_bar, aes(x = Year, y = DataValue, fill = TradeDirection)) +
      geom_bar(position = "dodge", stat = "identity", color = "black") +
      ylab("Value (Millions $)") +
      xlab("Year") +
      # scale_y_continuous(labels = dollar) +
      
      ggtitle(paste("U.S.-", input$country, " Services Trade in ", input$service, ", ", input$first_year, " to ", input$final_year, sep = "")) +
      theme_bw() +
      theme(legend.position = "bottom") +
      theme(legend.title = element_blank()) +
      theme(legend.spacing.x = unit(0.25, 'cm')) +
      labs(caption = "Source: U.S. Department of Commerce Bureau of Economic Analysis.")
    
  })
  
}
