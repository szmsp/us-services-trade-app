###############################################################################################################################

# README
# Project:    Services trade from the Department of Commerce Bureau of Economic Analysis
# Objective:  UI for BEA services data app

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

#### CREATE SHINY APP UI ####

# Define UI for application that calls, formats, and plots BEA services data
ui <- fluidPage(
  
  # App title
  titlePanel("U.S. Annual Bilateral Services Trade Data"),
  
  # Sidebar layout with a input and output definitions 
  sidebarLayout(
    
    # Inputs
    sidebarPanel(
      
      # Select country of interest
      selectInput(inputId = "country"
                  , label = "Country"
                  , choices = country_lookup$Desc
                  , selected = "Germany"),
      
      # Select service of interest
      selectInput(inputId = "service"
                  , label = "Service"
                  , choices = services_lookup$Key
                  , selected = "Advertising"),
      
      # Select beginning year 
      selectInput(inputId = "first_year"
                  , label = "Beginning Year"
                  , choices = c("2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018")
                  , selected = "2010"),
      
      # Select final year 
      selectInput(inputId = "final_year"
                  , label = "Final Year"
                  , choices = c("2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018")
                  , selected = "2017")
    ),
    
    # Outputs
    mainPanel(
      plotOutput(outputId = "barchart")
    )
  )
)

