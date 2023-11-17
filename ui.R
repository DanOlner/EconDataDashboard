#Area options for the UI, to select place to view
#Start with ITL2 geography (loaded in global.R)
area_options <- unique(geography$ITL_region_name)

# ui elements  --------------------------------------------------------------


postcode_searcher_panel <-
  function(){
    selectizeInput("postcode_chosen", "Input first part of a postcode to see its containing region:",
                   choices = NULL, ## do this clientside
                   options=list(maxOptions = 5)
    )
  }

summary_input_panel <-
  function(){
    selectInput(
      inputId = 'area_chosen',
      label = 'To choose a region to view, click on a different region on the map, input its name below or use the postcode searcher.',
      choices = area_options,
     selected = 'South Yorkshire',
      selectize = T
    )
  }


# Panel layouts -----------------------------------------------------------

about_tab_panel <- 
  function(title){
    tabPanel(title,  
             fluidRow(
               column(width = 11, includeMarkdown("text/about.md"), offset = 1)
             )
             # ,
             # fluidRow(
             #   column(width = 11, offset = 1,
             #          span(
             #            img(
             #              src = '',
             #              width = "40%",
             #              inline = T
             #            ),
             #            img(
             #              src = '',
             #              width = "40%",
             #              inline = T
             #            )
             #          )
             #   )
             # )
             
    )
  }





fluidPage(
  
  titlePanel("UK regional economic data generic viewer thingy"),
  
  sidebarLayout(
    sidebarPanel(
      # Place common sidebar elements here
      summary_input_panel()
      # postcode_searcher_panel(),
      # actionButton("action", "Action Button"),
      # sliderInput("slider", "Slider Input", 1, 100, 50),
      
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("About", 
                 about_tab_panel('About')
                 ),
        tabPanel(
          "Tab 2", 
          textOutput("text2"),
          plotOutput(outputId = "LQ_plot")
          ),
        tabPanel(
          "Tab 3", 
          textOutput("text3"),
          plotlyOutput(outputId = "LQ_plotly", height = '600px')
          )
        # Add more tabs as needed
      )
    )
  )
)
    
