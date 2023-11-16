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

source('functions/misc_functions.R')

itl2 <- read_csv('data/ITL2currentprices_long.csv')
itl3 <- read_csv('data/ITL3currentprices_long.csv')

#Setting initial geography, can change to e.g. ITL3 later
geography <- itl2

## postcode lookup 
postcode_lookup <- readRDS('data/postcode lookup table.rds')

postcode_options <- postcode_lookup$pcd_area
