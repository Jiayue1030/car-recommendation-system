##Cleaning data
install.packages("tidyverse/stringr")
##read csv
df_cars<-read.csv(file = 'carlist.csv')

min_index<-min(df_cars["X"])
max_index<-max(df_cars["X"])

summary(df_cars)
summary(df_cars$"data_installment")

sanitize_number<-function(text){
  words<-c("RM","/","month",",")
  for(w in words){
    text<-str_replace_all(text,w,"")
  }
  sanitized_number<-str_trim(text)
  return(as.numeric(sanitized_number))
  #sanitized_number<-as.numeric(gsub(".*?([0-9]+).*", "\\1", text))
  #return(sanitized_number)
}

count<-1
while(count<=max_index){
  df_cars[count,"data_installment"]<-sanitize_number(df_cars[count,"data_installment"])
  df_cars[count,"listing_price"]<-sanitize_number(df_cars[count,"listing_price"])
  count<-count+1
}

View(df_cars)
write.csv(df_cars,"carlist_cleaned.csv", row.names = TRUE)

