#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)

source("global.r")

# input_data is loaded in global.r

# Define server logic required to plot
shinyServer(function(input, output, session) {
    data <- reactive({
        phy <- input$phy

        qry_data <- aa_changes  %>% 
            dplyr::filter(sample_date >= input$inDate)
        
        collecting_org <- qry_data %>%
            distinct(collecting_org) %>%
            pull(collecting_org) %>%
            sort()
        
        if (is.vector(input$collecting_org)) {
            qry_data <- qry_data %>% 
                dplyr::filter(collecting_org %in% input$collecting_org)
            
            collecting_org <- qry_data %>%
                distinct(collecting_org) %>%
                pull(collecting_org) %>%
                sort()
        }
        
        qry_data <- qry_data %>%
            filter(!is.na(phylotype)) %>%
            mutate(phylotype = paste0(lineage,"-",phylotype)) %>%
            group_by(phylotype, sample_date) %>%
            summarise(count = n()) %>%
            ungroup() %>%
            arrange(sample_date) %>%
            group_by(phylotype) %>%
            mutate(cumsum = cumsum(count)) %>%
            mutate(days = n()) %>% 
            mutate(epi_week = paste0(lubridate::year(sample_date),"/",lubridate::epiweek(sample_date)))
        
        if (is.vector(phy)) {
            qry_data <- qry_data %>%
                filter(days >= input$days) %>%
                filter(phylotype %in% input$phy)
        } else {
            qry_data <- qry_data %>%
                filter(sample_date >= input$inDate) %>%
                filter(days >= input$days)
        }
        
        filtered_phylotype <- unique(qry_data)$phylotype
        # print(head(qry_data))
        return(list(data=qry_data, phylotype=filtered_phylotype, collecting_org = collecting_org))
    })
    
    observeEvent(input$days, {
        phylotypes_update_server <- data()$data %>%
            filter(days >= input$days) %>%
            group_by(phylotype) %>%
            summarise(count = n()) %>%
            arrange(desc(count)) %>%
            pull(phylotype)
        updateSelectizeInput(session, "phy", choices = phylotypes_update_server, server = TRUE)
    })
    
    observeEvent(input$inDate, {
        collecting_org <- aa_changes  %>%
            filter(sample_date >= input$inDate) %>%
            distinct(collecting_org) %>%
            pull(collecting_org) %>%
            sort()
        updateSelectizeInput(session, "collecting_org", choices = collecting_org, server = TRUE)
    })
    
    output$cumsum_phylotype <- renderPlotly({
        validate(
            need(nrow(data()$data) > 0, "No data available for current filters")
        )
        p <- ggplot(data()$data, aes(x = sample_date, y = cumsum, color = phylotype, group=days)) +
            geom_line() +
            geom_point() +
            xlab("Collection date") +
            ylab("Cum sum of sequences") +
            scale_x_date(date_breaks = "1 week", date_labels = "%y/%m/%d") +
            scale_y_continuous(position = "right") +
            theme_minimal() + 
            theme(axis.text.x = element_text(angle = 90))
        ggplotly(p, height = plotly_height)
        # ggplotly(p)
        
    })
    
    
    output$weekly_phylotype <- renderPlotly({
        validate(
            need(nrow(data()$data) > 0, "No data available for current filters")
        )
        weekly_data <- data()$data %>% 
            group_by(phylotype, epi_week) %>% 
            summarise(count = n())
        p <- ggplot(weekly_data, aes(x = epi_week, y = count, fill = phylotype)) +
            geom_bar(position = "stack", stat = "identity") +
            xlab("Epi week") +
            ylab("Number of sequences") +
            # scale_x_date(date_breaks = "1 week", date_labels = "%y/%m/%d") +
            # scale_y_continuous(position = "right") +
            theme_minimal() + 
            theme(axis.text.x = element_text(angle = 90))
        ggplotly(p, height = plotly_height)
        # ggplotly(p)
        
    })
    
    
    output$spike <- renderPlotly({
        
        filtered_data <- spike %>%
            dplyr::filter(phylotype %in% data()$phylotype) %>%
            separate_rows(variants, convert = TRUE, sep = "\\|") %>%
            distinct_all() %>%
            filter(grepl("S:",variants)) %>%
            mutate(variants = gsub("S:","",variants)) %>% 
            filter(!is.na(phylotype)) %>% 
            group_by(variants) %>% 
            summarise(count = n()) %>% 
            arrange(desc(count)) %>% 
            filter(count > 0)
        
        plot_ly(filtered_data, height = (plotly_height)/2) %>% 
            add_bars(y = ~reorder(variants, desc(count)),
                     x = ~count,
                     orientation = 'h') %>% 
            layout(xaxis = list(title = "Frequency"),
                   yaxis = list(title = ""),
                   title = "Spike AA replacement")
    })
    
    output$collecting_org <- renderPlot({
        phylotype_collecting_org <- phylotype_collecting_org %>% 
            dplyr::filter(collecting_org %in% data()$collecting_org) %>% 
            dplyr::filter(phylotype %in% data()$phylotype) %>%
            select(phylotype, collecting_org) %>% 
            group_by(phylotype, collecting_org) %>% 
            summarise(count = n())
        # print(unique(phylotype_collecting_org$collecting_org))
        # print(table(phylotype_collecting_org$collecting_org, phylotype_collecting_org$phylotype))
        ggplot(data = phylotype_collecting_org, aes(x = collecting_org, y = count)) +
            geom_bar(stat = "identity", aes(fill = collecting_org), show.legend = F) +
            labs(x = "Collecting Org", y = "No of Sequences") +
            theme_minimal()
    })
    
})
