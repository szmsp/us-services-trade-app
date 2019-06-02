###############################################################################################################################

# README
# Project:    Services trade from the Department of Commerce Bureau of Economic Analysis
# Objective:  BEA services data call function

# BEA API Setup
# API Key request here: https://apps.bea.gov/API/signup/index.cfm 

# For help on BEA international services trade data API:
# https://apps.bea.gov/api/_pdf/bea_web_service_api_user_guide.pdf

# For BEA services trade category definitions:
# https://www.bea.gov/sites/default/files/methodologies/ONE%20PDF%20-%20IEA%20Concepts%20Methods.pdf#page=63

# To run app, replace "[key]" below

# For BEA country and service parameter values, see lookup dataframes output

###############################################################################################################################

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

#### REVIEW COUNTRY AND SERVICE PARAMETER VALUES ####

country_param   <- fromJSON(paste0("https://apps.bea.gov/api/data/?&UserID=", bea_key, "&method=GetParameterValues",
                                   "&DataSetName=IntlServTrade&ParameterName=AreaOrCountry&ResultFormat=json"))

country_lookup  <- as.data.frame(country_param$BEAAPI$Results$ParamValue)

service_param   <- fromJSON(paste0("https://apps.bea.gov/api/data/?&UserID=", bea_key, "&method=GetParameterValues",
                                   "&DataSetName=IntlServTrade&ParameterName=TypeOfService&ResultFormat=json"))

services_lookup <- as.data.frame(service_param$BEAAPI$Results$ParamValue)

# Function to pull data

services_call <- function(country, bea_key, first_year, final_year){
  
  # Create lookup to identify BEA key for country specified
  
  country_of_interest <- if(str_to_lower(country_lookup$Desc) == str_to_lower(country)){
    country_lookup$Key
  } else {country}
  
  # Create lookup for BEA types of services trade
  
  services_lookup$Category <- trimws(str_extract(services_lookup$Key, "^[A-Z][a-z]+"))
  
  lookup <- as.data.frame(unique(services_lookup$Category))
  names(lookup) <- "Category" 
  lookup$id <- rownames(lookup)
  
  # Loop through services trade categories to download
  
  type_service_cat <- sqldf('select services_lookup.*, lookup.id from services_lookup left join lookup on services_lookup.Category = lookup.Category')
  
  cat_list <- paste(unique(type_service_cat$id), sep = " ")
  
  date_list <- seq(as.Date(paste(first_year, "/1/1", sep = "")), as.Date(paste(final_year, "/1/1", sep = "")), "years")
  year_list <- paste(year(date_list), collapse = ",")
  
  for (c in seq(cat_list)){
    if(!exists("services_data")){
      tempcall <- subset(type_service_cat, id == c)
      service_types <- paste(tempcall$Key, collapse = ",")
      temp_data <- paste0("https://apps.bea.gov/api/data?UserID=", bea_key, 
                          "&method=GetData&datasetname=INTLSERVTRADE&TypeOfService=", service_types,
                          "&TradeDirection=All&Affiliation=AllAffiliations&AreaOrCountry=", country_of_interest, 
                          "&Year=", year_list, "&ResultFormat=json")
      download <- fromJSON(temp_data)
      services_data  <- as.data.frame(download$BEAAPI$Results$Data)
      rm(tempcall)
      rm(service_types)
      rm(temp_data)
      rm(download)
    }
    if(exists("services_data") & c > 1){
      tempcall <- subset(type_service_cat, id == c)
      service_types <- paste(tempcall$Key, collapse = ",")
      temp_data <- paste0("https://apps.bea.gov/api/data?UserID=", bea_key, 
                          "&method=GetData&datasetname=INTLSERVTRADE&TypeOfService=", service_types,
                          "&TradeDirection=All&Affiliation=AllAffiliations&AreaOrCountry=", country_of_interest,
                          "&Year=", year_list, "&ResultFormat=json")
      download <- fromJSON(temp_data)
      temp_dataframe  <- as.data.frame(download$BEAAPI$Results$Data)
      services_data   <- rbind(services_data, temp_dataframe)
      rm(tempcall)
      rm(service_types)
      rm(temp_data)
      rm(download)
      rm(temp_dataframe)
    }
  }
  
  return(services_data)
}