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
    car_rating <- car %>% html_node(".listing__rating")%>%html_elements(".space--nowrap")%>%html_text()
    if(length(car_rating)<=0){
      car_rating<-"NA"
    }
    car_props <- car %>% html_attrs()
    new_car<-c(car_props[props],car_price,car_rating)
    print(paste(new_car["data-listing-id"],":",car_price," rating:",car_rating))
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
columns_names<-c("data_listing_id", "data_title", "data_display_title", "data_url", "data_installment", "data_image_src", "data_compare_image", "data_make", "data_model", "data_year", "data_mileage", "data_transmission", "data_ad_type", "data_variant", "data_seller_id", "data_profile_id", "data_listing_trusted", "data_dealer_isverified", "data_view_store", "data_country_code", "data_vehicle_type","listing_price","listing_rating")
colnames(df_cars)<-columns_names
#colnames(df)[23]<-"listing-price"
write.csv(df_cars,"carlist.csv", row.names = TRUE)
