
# Francis Giffard
# run_analysis.R
# September 2020

library(dplyr)


# Get data


# download zip file containing data if it hasn't already been downloaded
zipUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFile <- "UCI HAR Dataset.zip"

if (!file.exists(zipFile)) {
  download.file(zipUrl, zipFile, method = "curl")
}

# unzip zip file containing data if data directory doesn't already exist
dataPath <- "UCI HAR Dataset"
if (!file.exists(dataPath)) {
  unzip(zipFile)
}



# Read data


# read training data
trainingSubjects <- read.table(file.path(dataPath, "train", "subject_train.txt"))
trainingValues <- read.table(file.path(dataPath, "train", "X_train.txt"))
trainingActivity <- read.table(file.path(dataPath, "train", "y_train.txt"))

# read test data
testSubjects <- read.table(file.path(dataPath, "test", "subject_test.txt"))
testValues <- read.table(file.path(dataPath, "test", "X_test.txt"))
testActivity <- read.table(file.path(dataPath, "test", "y_test.txt"))

# read features, don't convert text labels to factors
features <- read.table(file.path(dataPath, "features.txt"), as.is = TRUE)
  
# read activity labels
activities <- read.table(file.path(dataPath, "activity_labels.txt"))
colnames(activities) <- c("activityId", "activityLabel")



#Step 1 - Merge the training and the test sets to create one data set


# concatenate individual data tables to make single data table
PersonActivity <- rbind(
  cbind(trainingSubjects, trainingValues, trainingActivity),
  cbind(testSubjects, testValues, testActivity)
)

# remove individual data tables to save memory
rm(trainingSubjects, trainingValues, trainingActivity, 
   testSubjects, testValues, testActivity)

# assign column names
colnames(PersonActivity) <- c("subject", features[, 2], "activity")



# Step 2 - Extract only the measurements on the mean and standard deviation
#          for each measurement

# determine columns of data set to keep based on column name...
columnsToKeep <- grepl("subject|activity|mean|std", colnames(PersonActivity))

# ... and keep data in these columns only
PersonActivity <- PersonActivity[, columnsToKeep]



# Step 3 - Use descriptive activity names to name the activities in the data
#          set


# replace activity values with named factor levels
PersonActivity$activity <- factor(PersonActivity$activity, 
  levels = activities[, 1], labels = activities[, 2])



# Step 4 - Appropriately label the data set with descriptive variable names

# get column names
PersonActivityCols <- colnames(PersonActivity)

# remove special characters
PersonActivityCols <- gsub("[\\(\\)-]", "", PersonActivityCols)

# expand abbreviations and clean up names
PersonActivityCols <- gsub("^f", "frequencyDomain", PersonActivityCols)
PersonActivityCols <- gsub("^t", "timeDomain", PersonActivityCols)
PersonActivityCols <- gsub("Acc", "Accelerometer", PersonActivityCols)
PersonActivityCols <- gsub("Gyro", "Gyroscope", PersonActivityCols)
PersonActivityCols <- gsub("Mag", "Magnitude", PersonActivityCols)
PersonActivityCols <- gsub("Freq", "Frequency", PersonActivityCols)
PersonActivityCols <- gsub("mean", "Mean", PersonActivityCols)
PersonActivityCols <- gsub("std", "StandardDeviation", PersonActivityCols)

# correct typo
PersonActivityCols <- gsub("BodyBody", "Body", PersonActivityCols)

# use new labels as column names
colnames(PersonActivity) <- PersonActivityCols



# Step 5 - Create a second, independent tidy set with the average of each
#          variable for each activity and each subject


# group by subject and activity and summarise using mean
PersonActivityMeans <- PersonActivity %>% 
  group_by(subject, activity) %>%
  summarise_each(funs(mean))

# output to file "tidy_data.txt"
write.table(PersonActivityMeans, "tidy_data.txt", row.names = FALSE, 
            quote = FALSE)
