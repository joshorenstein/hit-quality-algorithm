#####Unsupervised Machine Learning to Identify Hit Type####
##################Hierarchical clustering#################
library(tidyverse)
library(here)
s <-  read_csv("data/hit_data.csv") # read the data in if need be
s$estimated_ba_using_speedangle <- as.numeric(s$estimated_ba_using_speedangle)
s$estimated_woba_using_speedangle <- as.numeric(s$estimated_woba_using_speedangle)
hit_data <- s %>% na.omit() #remove any data without hit data
summary(hit_data)

# Convert the features of the data
test.data <- as.matrix(hit_data[5:6])

# Check column means and standard deviations
colMeans(test.data)
summary(test.data)
apply(test.data,2,sd)

# Scale the test.data
data.scaled <- scale(test.data)
# Calculate the (Euclidean) distances: data.dist
data.dist <- dist(data.scaled)
# Create a hierarchical clustering model: data.hclust
data.hclust <- hclust(d=data.dist,method="complete")
plot(data.hclust)
abline(h=4,lty=2)

# Cut tree so that it has 7 clusters
data.hclust.clusters <- cutree(data.hclust,k=7)
data_clust <- data.frame(data.hclust.clusters)
data_clust$data.hclust.clusters <- as.character(data_clust$data.hclust.clusters)

# Compare clusters
summary <- hit_data %>% ungroup() %>%  bind_cols(data_clust) %>% 
  dplyr::group_by(data.hclust.clusters) %>% 
  dplyr::summarise(launch_speed=mean(launch_speed),launch_angle=mean(launch_angle),
                   est_ba=mean(estimated_ba_using_speedangle),est_woba=mean(estimated_woba_using_speedangle),count=n()) 
summary
summary %>% write_csv("results/unsupervised_cluster_summary.csv")

#Update the data with the new clusters
hit_data_updated <- hit_data %>% bind_cols(data_clust) 

#Name the clusters and join it to the dataset
hit_type_index <- as.character(c(1:7))
hit_types <- c("High_Fly","Hard_Air_Contact","Hard_Ground_Contact","Fliner"
               ,"Soft_Ground_Contact","Soft_Air_Contact","Very_Soft_Air_Contact")
lookup <- data.frame(hit_type_index,hit_types)
hit_data_final <- hit_data_updated %>% inner_join(lookup,by=c("data.hclust.clusters"="hit_type_index"))
hit_data_final$hit_types <- as.factor(hit_data_final$hit_types)
head(hit_data_final)

# Plot of Speed vs. Angle by cluster membership
#install.packages('ggthemes')
library(ggthemes)
z <- ggplot(hit_data_final, aes(x = launch_speed,y=launch_angle, 
                           color = hit_types)) +
  geom_point(size = 1, alpha=0.5,position="jitter") +
  labs(title = "Hierarchical Clustering of Launch Speed vs Launch Angle",
       subtitle = "7 clusters assigned",
       caption = "Data Source: Statcast",
       x = "Launch Speed (MPH)", y = "Launch Angle (deg)", color = "Hit Type")+
  scale_color_discrete(labels=c("Fliner","Hard Air Contact","Hard Ground Contact",
                                "High Fly","Soft Air Contact","Soft Ground Contact",
                                "Pop up")) +
  theme(legend.key.size = unit(3,"point"))
z
ggsave("model_performance/unsupervised_plot.pdf", width = 6, height = 4)
#Save the data
hit_data_final %>% write_csv("data/unsupervised_results.csv") 

