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


#Main geography (ITL2 or 3) chooser, for all tabs
#Also, input$area_chosen is the main place this gets set by other things
#e.g. if changed by postcode search or map click, it gets updated into input$area_chosen
#Which will then let other things react via that update
choose_main_geography <-
  function(){
    selectInput(
      inputId = 'area_chosen',
      label = 'To choose a region to view, click on a different region on the map, input its name below or use the postcode searcher.',
      choices = area_options,
     selected = 'South Yorkshire',
      selectize = T
    )
  }


LQplot_choose_extra_geographies <-
  function(){
    selectInput(
      inputId = 'LQplot_newselection',
      label = 'To add another place to the LQ plot, select here (max. 7) or click "remove" to take off the last one added.',
      choices = area_options,
     selected = 'Greater Manchester',
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
  tags$head(#with progress bar CSS, see https://stackoverflow.com/a/44044060/5023561
    tags$style(
      HTML(".shiny-notification {
              height: 100px;
              width: 500px;
              position:fixed;
              top: calc(0% + 150px);;
              left: calc(50% - 400px);;
            }
           "
      )
    )
  ),
  
  #List themes with: bootswatch_themes(4)
  #View here: https://bootswatch.com/
  # theme = bs_theme(version = 4, bootswatch = "united"),
  theme = bs_theme(version = 4, bootswatch = "minty"),
  # theme = bs_theme(version = 4, bootswatch = "cerulean"),
  
  titlePanel("Dig into UK regional economic data"),
  
  sidebarLayout(
    sidebarPanel(
      # Place common sidebar elements here
      choose_main_geography()
      # postcode_searcher_panel(),
      # actionButton("action", "Action Button"),
      # sliderInput("slider", "Slider Input", 1, 100, 50),
      
    ),
    
    mainPanel(
      tabsetPanel(
        
        #TAB 1 ABOUT PAGE
        tabPanel("About", 
                 about_tab_panel('About')
                 ),
        
        #TAB 2 LQ PLOT
        tabPanel(
          "LQ plot", 
          
          LQplot_choose_extra_geographies(),
          # actionButton("addBtn", "Add Name"),
          actionButton("removeBtn", "Remove Last Name"),
          
          # textOutput("list_of_places_LQplot"),#plain text
          
          htmlOutput("list_of_places_LQplot_html"),#html version of same, for bold text
          
          plotOutput(outputId = "LQ_plot")
          ),
        
        #TAB 3 SIC VS SOC EVERYWHERE COMPARISON
        tabPanel(
          "SICSOC",
          plotOutput(outputId = "sicsoc_plot")
        )
        
        # Add more tabs as needed
      )
    )
  )
)
    
