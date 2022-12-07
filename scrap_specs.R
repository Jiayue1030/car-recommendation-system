#load libraries
library(stringr)
library(rvest)
library(ggvis)
library(dplyr)
library(ggplot2)
library(xml2)
library(tidyverse)
library(jsonlite)
install.packages("lubridate")
library(lubridate)
library(httr)

key_element_xpath <- '//*[@class="u-width-1/2"]'
key_value_xpath <-
  '//*[@class="u-text-bold u-width-1/2  u-align-right"]'
tab_specification_id <- '#tab-specifications'
tab_equipments_id <- '#tab-equipments'
vehicle_specs_list <-
  c(
    'doors',
    'seat_capacity',
    'engine_cc',
    'fuel_type',
    'fuel_consumption__l_100km',
    'vehicle_id'
  )

extract_specs <- function(df_tab_contents) {
  df_t_tab_contents <- setNames(data.frame(t(df_tab_contents[, -1])), df_tab_contents[, 1])
  df_subset <- data.frame(matrix(nrow = 0, ncol = length(vehicle_specs_list)))
  spec_list <- c()
  for (spec in vehicle_specs_list) {
    spec_value <- df_t_tab_contents[[spec]]
    if (length(spec_value) <= 0) {
      spec_value <- NA
      spec_list <- append(spec_list, spec_value)
    } else{
      spec_list <- append(spec_list, spec_value)
    }
  }
  df_subset <- rbind(df_subset, spec_list)
  colnames(df_subset) <- vehicle_specs_list
  return(df_subset)
}

get_vehicle_specs <- function(vehicle_id, data_url, tab_id) {
  status_code <- GET(data_url)$status_code
  print(status_code)
  if (status_code == 200) {
    data_url_html <- read_html(data_url)
    data_url <- url(data_url, "rb")
    close(data_url)
    data_url_node <- data_url_html %>% html_nodes(".c-tab-content")
    if (length(data_url_node) > 1) {
      #View(data_url_node)
      data_url_node <- data_url_node[2]
    }
    tabs_nodes <- data_url_node %>% html_nodes(tab_id)
    if (!is.null(tabs_nodes)) {
      tabs_nodes2 <- tabs_nodes %>% html_nodes(".u-border-bottom")
      key_element_nodes <-
        tabs_nodes %>% html_nodes(xpath = key_element_xpath)
      df_key_element <-
        data.frame(matrix(nrow = 0, ncol = length(key_element_nodes)))
      for (key in key_element_nodes) {
        key <- key %>% html_text()
        key <- str_replace_all(key, "[^a-zA-Z0-9]", ' ')
        key <- str_trim(tolower(key))
        key <- str_replace_all(key, ' ', '_')
        df_key_element <- rbind(df_key_element, key)
      }
      key_value_nodes <-
        tabs_nodes %>% html_nodes(xpath = key_value_xpath)
      df_key_value <-
        data.frame(matrix(nrow = 0, ncol = length(key_value_nodes)))
      for (key in key_value_nodes) {
        df_key_value <- rbind(df_key_value, key %>% html_text())
      }
      df_tab_contents <- cbind(df_key_element, df_key_value)
      df_tab_contents <-
        rbind(df_tab_contents, c("vehicle_id", vehicle_id))
      colnames(df_tab_contents) <- c("key", "value")
      df_subset <- extract_specs(df_tab_contents)
      df_vehicle_specs <- df_subset
      #close(data_url)
      #df_vehicle_specs<-setNames(data.frame(t(df_subset[,-1])), df_subset[,1])
      return(df_vehicle_specs)
    }
  }else{
    print(paste('Error',status_code))
  }
}

df_all_cars <- read.csv(file = 'carlist_cleaned.csv')

df_all_cars_specs <- data.frame(matrix(nrow = 0, ncol = length(vehicle_specs_list)))
colnames(df_all_cars_specs) <- c(vehicle_specs_list)

i <- 1

while (i <= nrow(df_all_cars)) {
  skip_to_next <- FALSE
  print(i)
  tryCatch({
    vehicle_id <- df_all_cars[i, "data_listing_id"]
    data_url <- df_all_cars[i, "data_url"]
    
    if (i %% 100 == 0) {
      Sys.sleep(5)
    } else if (i %% 1000 == 0) {
      print("Refreshing...")
      Sys.sleep(50)
    }
    
    df_ind_vehicle_spec <- get_vehicle_specs(vehicle_id, data_url, tab_equipments_id)
    print(paste(
      "Retrieving vehicle_id:",
      vehicle_id,
      " data_url:",
      data_url
    ))
    df_all_cars_specs <- rbind(df_all_cars_specs, df_ind_vehicle_spec)
    if (i %% 300 == 0) {
      View(df_all_cars_specs)
    }
    i <- i + 1
  },
  error = function(e) {
    skip_to_next <<- TRUE
  })
  if (skip_to_next) {
    next
  }
}

#merge cars specs and cars list
names(df_all_cars)[names(df_all_cars) == 'data_listing_id'] <- "vehicle_id"
df_all_cars_specs$vehicle_id <- as.integer(df_all_cars_specs$vehicle_id)

df_merged_cars <-
  inner_join(
    df_all_cars,
    df_all_cars_specs,
    by = 'vehicle_id'
  )
write.csv(df_merged_cars, "carlist_merged.csv", row.names = TRUE)
