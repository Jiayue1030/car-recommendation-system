#load libraries
library(stringr)
library(rvest)
library(ggvis)
library(dplyr)
library(ggplot2)

max_page_number<-102

props<-c("data-listing-id", "data-title", "data-display-title", "data-url", "data-installment", "data-image-src", "data-compare-image", "data-make", "data-model", "data-year", "data-mileage", "data-transmission", "data-ad-type", "data-variant", "data-seller-id", "data-profile-id", "data-listing-trusted", "data-dealer-isverified", "data-view-store", "data-country-code", "data-vehicle-type")

#Create an empty dataframe
df_cars<-data.frame(matrix(nrow = 0, ncol = length(props)))

scrap<-function(df,page_num){
  carlist_url<-"https://www.carlist.my/new-cars-for-sale/malaysia?page_size=50&page_number="
  site_url<-paste0(carlist_url,page_num)
  print(paste("Scrapping",site_url))
  carlists_html <- read_html(site_url)
  carlist_node <- carlists_html%>%html_nodes(".listing")
  for(car in carlist_node){
    car_price <- car %>% html_node(".listing__price") %>% html_text()
    car_props <- car %>% html_attrs()
    new_car<-c(car_props[props],car_price)
    print(paste(new_car["data-listing-id"],":",car_price))
    df_cars<-rbind(df_cars,new_car)
  }
  colnames(df_cars)<-props
  return(df_cars)
}

current<-1
while(current<=max_page_number){
  df_cars<-scrap(df_cars,current)
  current<-current+1
}

View(df_cars)
#colnames(df)[23]<-"listing-price"
write.csv(df_cars,"carlist_2022Nov.csv", row.names = TRUE)








