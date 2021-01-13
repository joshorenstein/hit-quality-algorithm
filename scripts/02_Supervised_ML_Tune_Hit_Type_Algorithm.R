library(tidyverse)
Packages <- c("here", "caret", "rpartScore", "recipes","MASS","kernlab","naivebayes","yardstick")
lapply(Packages, library, character.only = TRUE)

##load training data if its not loaded already
hit_data_final <- read_csv("data/unsupervised_results.csv") 
names(hit_data_final)
hit_data_final$hit_types <- as.factor(hit_data_final$hit_types)
# Keep unsupervised data as training and the post May 1 split into test and validation
set.seed(5818) #set the starting number used to create a random set of numbers. this is done so that model splits train and test same way every time.
en_train <- createDataPartition(hit_data_final$hit_types,p=.7,list=FALSE)

training <- hit_data_final[en_train,]
testing <- hit_data_final[-en_train,]

#Create the model that will be used in all of the algorithms
hit_recipe <- recipe(hit_types ~ launch_angle + launch_speed 
                      , data= training) %>% step_scale(all_predictors())

#3 repeats, 10 fold cross-validation with upsampling 
ctrl <- trainControl(method = "repeatedcv",number=10,repeats=3,sampling="up",classProbs = TRUE,
                     summaryFunction = multiClassSummary,
                     savePredictions = "final",allowParallel = TRUE)

########Fit 4 models#########
########Naive Bayes, Regression Tree, Bagged Regression Trees and Support Vector Machine########
 
class_nb <- train(hit_recipe, data = training, method = "naive_bayes",  trControl = ctrl,metric="logLoss") #bayesian
class_cart <- train(hit_recipe, data = training, method = "rpart2",  trControl = ctrl,metric="logLoss") #regression tree 
class_tree_b <- train(hit_recipe, data = training, method = "treebag",  trControl = ctrl,metric="logLoss") #bagged regression tree
class_svm <- train(hit_recipe, data = training, method = "svmLinear",  trControl = ctrl,metric="logLoss") #support vector machine

#get model performance
a <- getTrainPerf(class_nb)
b <- getTrainPerf(class_tree_b)
c <- getTrainPerf(class_svm)
d <- getTrainPerf(class_cart)

#Compare Model Performance
train_perf <- bind_rows(a,b,c,d) %>% arrange(TrainlogLoss) %>% 
  dplyr::select(method,TrainlogLoss,TrainMean_Sensitivity,TrainMean_Specificity) #sorted on log loss

train_perf 
train_perf %>% write_csv("model_performance/training_algorithm_performance.csv") #write a summary of the training data performance

# Add predicted hit type to the training data set
results <- training %>%
  mutate(treebag = predict(class_tree_b, training),
         Naive_Bayes = predict(class_nb,training),
         regression_tree = predict(class_cart,training),
         support_vector=predict(class_svm,training))

# Evaluate the performance of the three models using a confusion matrix
confusionMatrix(results$hit_types,results$treebag) #bagged trees are overfit
confusionMatrix(results$hit_types,results$Naive_Bayes) #pretty good performance
confusionMatrix(results$hit_types,results$support_vector) #struggled with the high flys
confusionMatrix(results$hit_types,results$regression_tree) #struggled with the high flys but not as much as SVM

# Add a prediction to the test dataset
testing_results <- testing %>%
  mutate(treebag = predict(class_tree_b, testing),
         Naive_Bayes = predict(class_nb,testing),
         regression_tree = predict(class_cart,testing),
         support_vector = predict(class_svm,testing))

#do a confusion matrix on test results and compare to training data
confusionMatrix(testing_results$hit_types,testing_results$treebag) #still way overfit
confusionMatrix(testing_results$hit_types,testing_results$Naive_Bayes) #good accuracy and matches training results well
confusionMatrix(testing_results$hit_types,testing_results$regression_tree) #similar results to training
confusionMatrix(testing_results$hit_types,testing_results$support_vector) #similar results to training

#Naive Bayes is the best model

testing_results %>% write_csv("results/naive_bayes_hit_model.csv") #line-by-line data

naive_bayes_summary <- testing_results %>% 
  ungroup() %>% 
  group_by(Naive_Bayes) %>% 
  dplyr::summarise(launch_speed=mean(launch_speed),launch_angle=mean(launch_angle),est_ba=mean(estimated_ba_using_speedangle),est_woba=mean(estimated_woba_using_speedangle))

naive_bayes_summary
a <- ggplot(testing_results, aes(x = launch_speed,y=launch_angle, 
                                color = hit_types)) +
  geom_point(size = 1, alpha=0.5,position="jitter") +
  labs(title = "Naive Bayes Classification of Launch Speed vs Launch Angle",
       subtitle = "7 classes assigned",
       caption = "Data Source: Statcast",
       x = "Launch Speed (MPH)", y = "Launch Angle (deg)", color = "Hit Type")+
  scale_color_discrete(labels=c("Fliner","Hard Air Contact","Hard Ground Contact",
                                "High Fly","Soft Air Contact","Soft Ground Contact",
                                "Pop up")) +
  theme(legend.key.size = unit(3,"point"))

a
ggsave("final_model_plot.pdf", width = 6, height = 4)
naive_bayes_summary %>% write_csv("results/naive_bayes_summarized_results.csv")




