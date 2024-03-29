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
library(shinyWidgets)

dashboardPage(
    dashboardHeader(title = "SARS2 NORW"),
    dashboardSidebar(
        dateInput("inDate", "Sequences collected from:", "2020-12-01"),
        
        sliderInput("days",
                    "Exclude sequences collected within (days):",
                    min = 0,
                    max = 30,
                    value = 7,
                    step = 1),
        selectizeInput('collecting_org', 'Select collecting org', choices = collecting_org, multiple = TRUE),
        selectizeInput('phy', 'Select (multiple) top phylotypes', choices = phylotypes, multiple = TRUE)
        
    ),
    dashboardBody(
        fluidRow(
            tabBox(title = "Plots",
                   id = "tabset1", height = plotly_height + 55, width = 8,
                   tabPanel("Cummulative sequences for each phylotype by collection date", addSpinner(plotlyOutput("cumsum_phylotype"), spin = "circle", color = "#E41A1C")),
                   tabPanel("Number of collected sequences by phylotype per week", addSpinner(plotlyOutput("weekly_phylotype"), spin = "circle", color = "#E41A1C"))
                # status = "warning", title = "Cummulative sequences for each phylotype by collection date", width = 8, height = plotly_height + 50, addSpinner(plotlyOutput("cumsum_phylotype"), spin = "circle", color = "#E41A1C")
                ),
            fluidRow(
                box(status = "info", width = 4, plotlyOutput("spike"), height = (plotly_height + 55)/2),
                box(status = "success", width = 4, plotOutput("collecting_org"), height = (plotly_height + 40)/2)
                )
            
        )
    )
)
