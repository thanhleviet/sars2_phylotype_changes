#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)
library(shinydashboard)

dashboardPage(
    dashboardHeader(title = "SARS2 NORW"),
    dashboardSidebar(
        dateInput("inDate", "Sequences collected from:", "2020-10-01"),
        
        sliderInput("days",
                    "Exclude sequences collected within (days):",
                    min = 2,
                    max = 30,
                    value = 7,
                    step = 1),
        
        selectizeInput('phy', 'Select (multiple) top phylotypes', choices = phylotypes, multiple = TRUE)
        
    ),
    dashboardBody(
        fluidRow(
            box(status = "warning", title = "Cummulative sequences for each phylotype by collection date", width = 8, height = plotly_height + 55, plotlyOutput("cumsum_phylotype")),
            fluidRow(
                box(status = "info", width = 4, plotlyOutput("spike"), height = (plotly_height + 55)/2),
                box(status = "success", width = 4, plotOutput("collecting_org"), height = (plotly_height + 40)/2)
                )
            
        )
    )
)
