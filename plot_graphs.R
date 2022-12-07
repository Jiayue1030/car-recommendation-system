library(ggplot2)
df_cars
# Basic scatter plot
ggplot(df_cars, aes(x=data_make, y=data_listing_id)) + geom_point()
# Change the point size, and shape
#ggplot(mtcars, aes(x=wt, y=mpg)) + geom_point(size=2, shape=23)