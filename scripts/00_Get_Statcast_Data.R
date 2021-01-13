#### Use online tools to download statcast data

#### Removes existing objects from global environment

#rm(list=ls())

#### Install library packages (May take 5-10 minutes to get baseballr)

#install.packages("devtools")

library(devtools)

require(devtools)

install_github("BillPetti/baseballr")

require(baseballr)

library(baseballr)

library(tidyverse)
s1 <- scrape_statcast_savant_batter_all("2019-04-09", 
                                        
                                        "2019-04-15")

s2 <- scrape_statcast_savant_batter_all("2019-04-09", 
                                        
                                        "2019-04-15")

s3 <- scrape_statcast_savant_batter_all("2019-04-16", 
                                        
                                        "2019-04-22")

s4 <- scrape_statcast_savant_batter_all("2019-04-23", 
                                        
                                        "2019-04-29")

s5 <- scrape_statcast_savant_batter_all("2019-04-30", 
                                        
                                        "2019-05-01")

sample <- bind_rows(s1,s2,s3,s4,s5)
names(sample)
s <- sample %>% dplyr::select(game_date,player_name,estimated_ba_using_speedangle,estimated_woba_using_speedangle,launch_speed,launch_angle,batter,pitcher,p_throws,events,description)
s %>% write_csv("data/hit_data.csv")
