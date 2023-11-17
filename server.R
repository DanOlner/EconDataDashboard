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
reactive_values <-
  reactiveValues(
    #List of places that have been added to the LQ plot
    #Starts with Greater Manchester but can be added to and removed
    LQ_places = NULL#Default set in UI default text box option
    
  )





# server.R ----------------------------------------------------------------

function(input, output, session) {
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #COMMON LEFTHAND FUNCTIONS----
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
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
  
  
  
  #~~~~~~~~~~~~~~~~~~~~~
  #TAB FUNCTIONALITY----
  #~~~~~~~~~~~~~~~~~~~~~
  
  #Tab 2 LQ plot - detect extra geographyy input, add to LQ place list
  observeEvent(input$LQplot_newselection,{
    
    #check not null (need to set to null if empty)
    if(is.null(reactive_values$LQ_places)){
     
      reactive_values$LQ_places = input$LQplot_newselection
      
    }
    #Check haven't already added, and keep to 7 extra. That's probably too many to be legible, so plenty.
    else if(!input$LQplot_newselection %in% c(reactive_values$LQ_places,isolate(input$area_chosen)) & length(reactive_values$LQ_places < 7)){
    
      reactive_values$LQ_places = c(reactive_values$LQ_places, input$LQplot_newselection)
    
    }
    
  })
  
  
  
  #Remove elements from the LQ plot extra places
  observeEvent(input$removeBtn,{
    
    if(length(reactive_values$LQ_places) > 1){
      
      reactive_values$LQ_places <- reactive_values$LQ_places[1:length(reactive_values$LQ_places)-1]
      
    } else if(length(reactive_values$LQ_places) == 1){
      
      reactive_values$LQ_places <- NULL
      
    }
    
  })
  
  
  
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~
  #TAB PLOTS AND CONTENT----
  #~~~~~~~~~~~~~~~~~~~~~~~~~
  
  #Text of added places for LQ plot tab 2
  output$list_of_places_LQplot <- renderText({
    
    #Add in marker descriptions
    if(length(reactive_values$LQ_places)>0){
    places_w_markers <- paste0(reactive_values$LQ_places, shapeorder_forLQplot.names[1:length(reactive_values$LQ_places)])
    } else {
      places_w_markers <- ''
    }
    
    paste0(
      "Other places added to the LQ plot: ",
       # paste0(reactive_values$LQ_places, collapse = ", ")
       paste0(places_w_markers, collapse = ", ")
    )
    
  })
  
  
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
    
    
    
    
    #INITIALISE LQ PLOT
    p <- LQ_baseplot(df = yeartoplot, alpha = 0, sector_name = SIC07_description, 
                     LQ_column = LQ, change_over_time = slope)
    
    #Add any other places, up to some maximum number
    #Use integers so we can also add in set shapes for each additional place
    if(length(reactive_values$LQ_places) > 0){
      for(i in 1:length(reactive_values$LQ_places)){
        
        p <- addplacename_to_LQplot(df = yeartoplot, plot_to_addto = p, 
                                    placename = reactive_values$LQ_places[i], shapenumber = shapeorder_forLQplot[i],
                                    region_name = ITL_region_name,#The next four, the function needs them all 
                                    sector_name = SIC07_description, change_over_time = slope, LQ_column = LQ)
        
      }
    }
      
    #MAIN GEOGRAPHY LAST, TO APPEAR ON TOP
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
    
  }, height = 800, res = 100)
  
  
  
  
  
  
  #OUTPUT FOR SICSOC PLOT
  output$sicsoc_plot <- renderPlot({
     
    # debugonce(get_all_places_sicsocs)
    
    allz <- purrr::map(
      .f = get_all_places_sicsocs, 
      .x = unique(sicsoc$GEOGRAPHY_NAME[sicsoc$GEOGRAPHY_NAME!=input$area_chosen]),
      comparator_name = input$area_chosen
    ) %>% bind_rows
    
    
    allz <- allz %>% 
      unite(sicsoc, c('SOC2020','SIC2007'), sep = ' || ', remove = F) %>% 
      mutate(
        valdiff = ifelse(!CIs_overlap, valdiff, NA)
      ) 
    
    
    #Finding the zero breakpoint to adjust the legend/scale
    valz <- c(range(allz$valdiff[allz$SIC2007!='Total Services'], na.rm = T), 0)
    scale_values <- function(x){(x-min(x))/(max(x)-min(x))}
    scaled <- scale_values(valz)
    zerocutoff <- scaled[3]
    
    #Colours to separate the different SOCs on the y axis
    b <- c(
      rep('#FF5733',9),
      rep('#CDDC39',9),
      rep('#00BCD4',9),
      rep('#9C27B0',9),
      rep('#3F51B5',9),
      rep('#E91E63',9),
      rep('#009688',9),
      rep('#FFEB3B',9),
      rep('#607D8B',9)
    )
    
    ggplot(allz %>% filter(SIC2007!='Total Services'), aes(x = substr(GEOGRAPHY_NAME,0,20), y = sicsoc, fill= valdiff)) + 
      geom_tile() +
      scale_fill_gradientn(
        name = "ppt diff",
        colours = c("red", "white", "darkgreen"),
        values = c(0, zerocutoff, 1)#https://stackoverflow.com/a/58725778/5023561
      ) +
      theme(axis.text.x = element_text(angle = 270, vjust = 0.5, hjust=0)) +
      ggtitle(input$area_chosen) +
      theme(
        plot.title = element_text(face = 'bold'),
        axis.text.y = element_text(colour = b)
      ) +
      xlab("") +
      ylab("") 
      
  }, height = 1000, res = 100)
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

}#END SESSION FUNCTION
