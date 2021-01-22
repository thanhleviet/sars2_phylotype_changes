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
        if (is.vector(phy)) {
            .rs <- input_data %>%
                filter(sample_date >= input$inDate) %>%
                filter(days >= input$days) %>%
                filter(phylotype %in% input$phy)
        } else {
            .rs <- input_data %>%
                filter(sample_date >= input$inDate) %>%
                filter(days >= input$days)
        }
        filtered_phylotype <- unique(.rs)$phylotype
        return(list(data=.rs, phylotype=filtered_phylotype))
    })
    
    observeEvent(input$days, {
        phylotypes_update_server <- input_data %>%
            filter(days >= input$days) %>%
            group_by(phylotype) %>%
            summarise(count = n()) %>%
            arrange(desc(count)) %>%
            pull(phylotype)
        updateSelectizeInput(session, "phy", choices = phylotypes_update_server, server = TRUE)
    })
    
    output$cumsum_phylotype <- renderPlotly({
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
            filter(count > 5)
        
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
            select(phylotype, collecting_org) %>% 
            dplyr::filter(phylotype %in% data()$phylotype) %>%
            group_by(phylotype, collecting_org) %>% 
            summarise(count = n())
        ggplot(data = phylotype_collecting_org, aes(x = collecting_org, y = count)) +
            geom_bar(stat = "identity", aes(fill = collecting_org), show.legend = F) +
            labs(x = "Collecting Org", y = "No of Sequences") +
            theme_minimal()
    })
    
})
