#load dplyr library for use in this script
library(dplyr)

# Download Data if not already included
dataurl <- "http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones"
filepath <- "./data.zip"
if (!file.exists(filepath)) {
    download.file(dataurl, filepath)
}

# read txt files contain observations
# read txt files that contains subject ID label for each observation
# read y - activity labels

test_data <- read.table("./data/test/X_test.txt")
train_data <- read.table("./data/train/X_train.txt")
test_subject <- read.table("./data/test/subject_test.txt")
train_subject <- read.table("./data/train/subject_train.txt")
test_y <- read.table("./data/test/y_test.txt")
train_y <- read.table("./data/train/y_train.txt")

# Merge obs and subject ID label into one, then append test and train together
test_data <- cbind(test_subject, test_y, test_data)
train_data <- cbind(train_subject, train_y, train_data)
data <- rbind(test_data,train_data) 

# Remove dataframes created in intermediary steps
remove(test_data, test_subject, test_y, train_data, train_subject, train_y)

# label the first variable as "subject", and the second as "activity", for
# the rest of the variables, use features.txt to label the

label_names <- read.table("./data/features.txt")[,2]
label_names <- gsub("\\)|\\(","",label_names)

names(data) <- c("subject", "activityid", label_names) 

# Use dplyr.select with match (alt. grepl) to filter for variables only with
# "subject", "mean()" or "std()"
data<- select(data, matches("[Ss]td|[Mm]ean|subject|activityid"))

# read activity label, merge into data
activity_label <- read.table("./data/activity_labels.txt")
names(activity_label) <- c("activityid", "activity")
data <- merge(data, activity_label, by.x = "activityid", by.y = "activityid") %>%
    select(activity, everything())

# Create separate tidy data with average per activity and subject.
# Write data to text file named tidydata.txt
tidy_data <- aggregate(data[4:89],data[1:3], mean )
write.table(tidy_data, file="./tidydata.txt",row.name = FALSE)
