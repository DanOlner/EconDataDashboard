#Installed check for package "reactlog", for visualising reactive graph
#Base "R package installed" check: https://stackoverflow.com/a/38082613/5023561
is_inst <- function(pkg) {
  nzchar(system.file(package = pkg))
}

if(is_inst("reactlog")){
  cat('Reactlog installed, enabling. Use CTRL/CMD + F3 to open reactive graph plot.\n')
  options(shiny.reactlog = TRUE)
}


# inputs ------------------------------------------------------------------

#This fixes st_intersection not working
#Without it, we get the error described here
#(Only need to set once but keeping here for now for clarity)
#https://stackoverflow.com/a/68481205/5023561
sf::sf_use_s2(FALSE)

#Assign reactive value that will be used throughout
# reactive_values <- 
#   reactiveValues(
#   )



# server.R ----------------------------------------------------------------

function(input, output, session) {
  
  
  ## reactive to update area chosen 
  ## This will set the TTWA first, from what the default in the input$area_chosen is
  observeEvent(input$area_chosen,{

    # reactive_values$area_chosen <- input$area_chosen

    cat('input$area_chosen observe triggered.\n')
    
    #problem this fixes: input invalidates as soon as a letter is deleted.
    #Could also use on of these as well, but let's just check the field is sensible before changing
    #https://shiny.rstudio.com/reference/shiny/1.7.0/debounce.html
    if(isolate(input$area_chosen) %in% geography$ITL_region_name){
    
      cat('And place found.\n')
      
    } else (
      
      cat('... but place not found yet. Hang on. \n')
      
    )
    
    }, ignoreInit = T
  )
  
  
  
  
  
  observeEvent(input$postcode_chosen,{
    
    data_chosen <- 
      (postcode_lookup %>%
      filter(pcd_area == input$postcode_chosen)
      )
    
    updateSelectInput(session, inputId = "area_chosen", selected = data_chosen$ttwa[1])
    
    cat('Updated place via postcode selection.\n')
  
    #We don't want postcode input triggering initially; text input$area_chosen is being the central place store, we don't want to overwrite with NULL  
  }, ignoreInit = T#https://stackoverflow.com/questions/42165567/prevent-execution-of-observe-on-app-load-in-shiny
  )
  
  ## Serverside postcode select 
  updateSelectizeInput(inputId = 'postcode_chosen',
                       choices = postcode_options,
                       selected = '',
                       server = T)
  
  
  
  #LQ plot for tab 2
  output$LQ_plot <- renderPlot({
    
    #Get a vector with sectors ordered by the place's LQs, descending order
    #Use this next to factor-order the SIC sectors
    sectorLQorder <- itl2.cp %>% filter(
      ITL_region_name == input$area_chosen,
      year == 2021
    ) %>% 
      arrange(-LQ) %>% 
      select(SIC07_description) %>% 
      pull()
    
    #Turn the sector column into a factor and order by LCR's LQs
    yeartoplot$SIC07_description <- factor(yeartoplot$SIC07_description, levels = sectorLQorder, ordered = T)
    
    # Reduce to SY LQ 1+
    lq.selection <- yeartoplot %>% filter(
      ITL_region_name == input$area_chosen,
      # slope > 1,#LQ grew relatively over time
      LQ > 1
    )
    
    #Keep only sectors that were LQ > 1 from the main plotting df
    yeartoplot <- yeartoplot %>% filter(
      SIC07_description %in% lq.selection$SIC07_description
    )
    
    p <- LQ_baseplot(df = yeartoplot, alpha = 0.1, sector_name = SIC07_description, 
                     LQ_column = LQ, change_over_time = slope)
    
    p <- addplacename_to_LQplot(df = yeartoplot, placename = input$area_chosen,
                                plot_to_addto = p, shapenumber = 16,
                                min_LQ_all_time = min_LQ_all_time, max_LQ_all_time = max_LQ_all_time,#Range bars won't appear if either of these not included
                                value_column = value, sector_regional_proportion = sector_regional_proportion,#Sector size numbers won't appear if either of these not included
                                region_name = ITL_region_name,#The next four, the function needs them all 
                                sector_name = SIC07_description,
                                change_over_time = slope, 
                                LQ_column = LQ 
    )
    
    p
    
  }, height = 600, res = 100)
  
  
  
  
  #LQ plot for tab 3, testing plotly
  output$LQ_plotly <- renderPlotly({
    
    #Get a vector with sectors ordered by the place's LQs, descending order
    #Use this next to factor-order the SIC sectors
    sectorLQorder <- itl2.cp %>% filter(
      ITL_region_name == input$area_chosen,
      year == 2021
    ) %>% 
      arrange(-LQ) %>% 
      select(SIC07_description) %>% 
      pull()
    
    #Turn the sector column into a factor and order by LCR's LQs
    yeartoplot$SIC07_description <- factor(yeartoplot$SIC07_description, levels = sectorLQorder, ordered = T)
    
    # Reduce to SY LQ 1+
    lq.selection <- yeartoplot %>% filter(
      ITL_region_name == input$area_chosen,
      # slope > 1,#LQ grew relatively over time
      LQ > 1
    )
    
    #Keep only sectors that were LQ > 1 from the main plotting df
    yeartoplot <- yeartoplot %>% filter(
      SIC07_description %in% lq.selection$SIC07_description
    )
    
    p <- LQ_baseplot(df = yeartoplot, alpha = 0.1, sector_name = SIC07_description, 
                     LQ_column = LQ, change_over_time = slope)
    
    p <- addplacename_to_LQplot(df = yeartoplot, placename = input$area_chosen,
                                plot_to_addto = p, shapenumber = 16,
                                min_LQ_all_time = min_LQ_all_time, max_LQ_all_time = max_LQ_all_time,#Range bars won't appear if either of these not included
                                value_column = value, sector_regional_proportion = sector_regional_proportion,#Sector size numbers won't appear if either of these not included
                                region_name = ITL_region_name,#The next four, the function needs them all 
                                sector_name = SIC07_description,
                                change_over_time = slope, 
                                LQ_column = LQ 
    )
    
    p
    
  })
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

}#END SESSION FUNCTION
