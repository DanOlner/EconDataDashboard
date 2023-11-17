library(shiny)
library(tidyverse)
library(sf)
library(leaflet)
library(plotly)
library(bslib)
library(knitr)
library(toOrdinal)
library(shinyWidgets)
library(markdown)
library(zoo)#For moving average function
library(ggrepel)#For self-adjusting plot labels
options(scipen = 99)#Avoids scientific notation

itl2.cp <- read_csv('data/ITL2currentprices_long.csv')

source('functions/misc_functions.R')

#PRE-PROCESS DATA FOR SPEED OF LOADING----

#See https://github.com/DanOlner/regionalGVAbyindustry

#Run all this then save versions
# itl2.cp <- read_csv('data/ITL2currentprices_long.csv')
# itl3.cp <- read_csv('data/ITL3currentprices_long.csv')
# 
# itl2.cp <- itl2.cp %>% 
#   split(.$year) %>% 
#   map(add_location_quotient_and_proportions, 
#       regionvar = ITL_region_name,
#       lq_var = SIC07_description,
#       valuevar = value) %>% 
#   bind_rows()
# 
# #Use
# #LQ_slopes %>% filter(slope==0)
# #To see which didn't get slopes (only 8 rows in the current data)
# LQ_slopes <- compute_slope_or_zero(
#   data = itl2.cp, 
#   ITL_region_name, SIC07_description,#slopes will be found within whatever grouping vars are added here
#   y = LQ_log, x = year)
# 
# #Filter down to a single year
# yeartoplot <- itl2.cp %>% filter(year == 2021)
# 
# #Add slopes into data to get LQ plots
# yeartoplot <- yeartoplot %>% 
#   left_join(
#     LQ_slopes,
#     by = c('ITL_region_name','SIC07_description')
#   )
# 
# #Get min/max values for LQ over time as well, for each sector and place, to add as bars so range of sector is easy to see
# minmaxes <- itl2.cp %>% 
#   group_by(SIC07_description,ITL_region_name) %>% 
#   summarise(
#     min_LQ_all_time = min(LQ),
#     max_LQ_all_time = max(LQ)
#   )
# 
# #Join min and max
# yeartoplot <- yeartoplot %>% 
#   left_join(
#     minmaxes,
#     by = c('ITL_region_name','SIC07_description')
#   )

#Save versions processed from the code above, for quicker loading speeds
# saveRDS(itl2.cp,'data/itl2currentprices_w_LQs.rds')
# saveRDS(yeartoplot,'data/itl2_2021forLQplot.rds')


#LOAD
itl2.cp <- readRDS('data/itl2currentprices_w_LQs.rds')
yeartoplot <- readRDS('data/itl2_2021forLQplot.rds')





#LOAD OTHER NECESSARY DATA----


#Setting initial geography, can change to e.g. ITL3 later
geography <- itl2.cp

## postcode lookup 
postcode_lookup <- readRDS('data/postcode lookup table.rds')

postcode_options <- postcode_lookup$pcd_area








