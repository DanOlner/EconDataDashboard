#Misc data processing
library(tidyverse)

#Downloaded from https://geoportal.statistics.gov.uk/datasets/9ac0331178b0435e839f62f41cc61c16/about
#Too big, stored locally
pcs <- read_csv('local/NSPL_MAY_2022_UK/Data/NSPL_MAY_2022_UK.csv')

#Reduce to first part only, postcode district, and keep only ITL... which ITL does it use?
unique(pcs$itl)

#There's an ITL lookup here
itl.lookup <- read_csv('local/NSPL_MAY_2022_UK/Documents/LAU121_ITL321_ITL221_ITL121_UK_LU.csv')

#Check matches
unique(pcs$itl) %in% itl.lookup$LAU121CD

#What are the falses? Seemingly, non existent postcodes. OK.
pcs %>% filter(!pcs$itl %in% itl.lookup$LAU121CD) %>% View

