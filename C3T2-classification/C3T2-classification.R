#import libraries
library(caret)
library(gbm)
library(C50)

#explore data
attributes(data)
summary(data) #looks like there aren't any NA values
str(data)

#graph some data
hist(data$salary) #all values have similar frequency
hist(data$age) #values have similar frequency
hist(data$elevel) #values have similar frequency
hist(data$car) #most frequent is car 1
hist(data$zipcode) #values have similar frequency
hist(data$credit) #values have similar frequency
hist(data$brand) #1 value (~6000) tends to be preferred over 0 (~4000)

plot(data$salary, data$brand) #higher salary may have higher preference for 1
plot(data$age, data$brand) #age doesn't seem to influence as much

#checking feature correlation

#corrMatrix <- cor(,1:6) #dtypes must be numeric
#print(corrMatrix)
#we could use this for feature selection -- 
#if variables are too highly correlated

#change dtypes to factor
data$brand <- as.factor(data$brand)
data$elevel <- as.factor(data$elevel)
data$car <- as.factor(data$car)
data$zipcode <- as.factor(data$zipcode)


###################################################################

#start model building
#Stoachastic Gradient Boosting (GBM) -- Automatic tuning -- 10 fold cv
#y value = brand
set.seed(123) #set seed first

#create 75%/25% train/test split of dataset
inTraining <- createDataPartition(data$brand, p = .75, list = FALSE)
training <- data[inTraining,]
testing <- data[-inTraining,]

#create 10 fold cv
fitControl <- trainControl(method = "repeatedcv", number = 10, repeats = 1)

#train GBM model
set.seed(123)
gbmFit1 <- train(brand~., data = training, method = "gbm", 
                 trControl = fitControl, verbose = FALSE) 

#view model results
gbmFit1

#variable importance
importance <- varImp(gbmFit1, numTrees = 150) #if scale = FALSE  is added,
# it won't scale the values to 100
importance
plot(importance)
#Error in relative.influence(object, n.trees = numTrees) : 
#could not find function "relative.influence"
#Had to load the gbm library to make this work

###################################################################

#C50 -- Automatic Tuning -- 10 fold cv
#we will be using the same training sets as the previous model

#train C50 model
set.seed(123)
c50Fit1 <- train(brand~., data = training, method = "C5.0",
                 trControl = fitControl)

#view model results
c50Fit1

c50importance <- varImp(c50Fit1)
c50importance
plot(c50importance)

###################################################################

#Random Forest -- Manual Tuning -- 10 fold cv
#will be using the same training set as with the previous model

#create tuning grid
rfGrid <- expand.grid(mtry=c(1,2,3,4,5))

#train rf model
set.seed(123) #seed needs to be set right before each model?
system.time(rfFit1 <- train(brand~., data = training, method = "rf", 
                             trControl = fitControl, tuneGrid = rfGrid))
#view results
rfFit1

#find feature importance
rfimportance <- varImp(rfFit1)
rfimportance
plot(rfimportance)

##################################################################

#compare models
results <- resamples(list(C50 = c50Fit1, GBM = gbmFit1, RF = rfFit1))

# summarize the distributions
summary(results)

# boxplots of results
bwplot(results)

# dot plots of results
dotplot(results)

##################################################################

#The GBM model performed slightly better than the RF and C50 models, 
#so I will use the GBM model to make predictions

predictions <- predict(gbmFit1, testing)
predictions

#confusion matrix
confusionMatrix(predictions, testing$brand)

#post resample
postResample(predictions, testing$brand)
#accuracy and kappa are higher than in training

summary(predictions)
summary(testing$brand)

#Try predictions with C50 model
#C50 used more features and was faster plus had a good score

predictions2 <- predict(c50Fit1, testing)
predictions2

confusionMatrix(predictions2, testing$brand) #did not perform as well as gbm

postResample(predictions2, testing$brand)

#################################################################

#Use GBM model to make predictions on unseen data

#first check out dataset
summary(newdata)
str(newdata)
str(data)

#change dtypes to factors
newdata$brand <- as.factor(newdata$brand)
newdata$elevel <- as.factor(newdata$elevel)
newdata$car <- as.factor(newdata$car)
newdata$zipcode <- as.factor(newdata$zipcode)
str(newdata)

#make predictions
newpreds <- predict(gbmFit1, newdata)
newpreds

#confusion matrix
confusionMatrix(newpreds, newdata$brand)

#post resampling
postResample(newpreds, newdata$brand) #accuracy and kappa are much lower, 
# but that is because the survey filled in 0 for incomplete answers, so our
# results will appear different from the ground truth

summary(newpreds)
summary(predictions)

#add the new predictions to the dataframe
newdata$newpreds <- predict(gbmFit1, newdata)

#save the dataset with added predictions as a .csv file
write.table(newdata, file = "newsurveypreds.csv",
            sep = ",", row.names = F)
