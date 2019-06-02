# us-services-trade-app
Shiny app for pulling and visualizing U.S. services trade data from the BEA

Pull US trade in services data from the Bureau of Economic Analysis (BEA) API.

This app pulls and visualizes bilateral U.S. services trade data from the BEA API. It allows users flexibility to specify the partner country and period of interest. 

To access the BEA API, first request an API key online: https://apps.bea.gov/API/signup/index.cfm

To run the app, copy the programs into a directory. Insert your directory file path and your BEA API key into "[path]" and "[key]" in the programs. Set the working directory to your directory file path, then run: 

  library(shiny)
  
  runApp()

For help or to learn more about international services trade data available from the BEA API, please see the API guide: https://apps.bea.gov/api/_pdf/bea_web_service_api_user_guide.pdf

For help or to learn more about the types of services BEA collects data on, please see the BEA estimation methods description: https://www.bea.gov/sites/default/files/methodologies/ONE%20PDF%20-%20IEA%20Concepts%20Methods.pdf#page=63
