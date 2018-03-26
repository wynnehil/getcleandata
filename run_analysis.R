library(dplyr)
library(data.table)
library(tidyr)

packages <- c("data.table", "reshape2")
sapply(packages, require, character.only = TRUE, quietly = TRUE)

path <- getwd()
path

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
d <- "Dataset.zip"
if (!file.exists(path)) {
  dir.create(path)
}
download.file(url, file.path(path, d))

#Unzip the file
unzip('data.zip', exdir = getwd())

fitbit <- file.path(path, "UCI HAR Dataset")
list.files(fitbit, recursive = TRUE)



##merge the training and test sets to one data set
#Read the subject files.
dtSubjectTrain <- fread(file.path(fitbit, "train", "subject_train.txt"))
dtSubjectTest <- fread(file.path(fitbit, "test", "subject_test.txt"))
#read activity files
dtActivityTrain <- fread(file.path(fitbit, "train", "Y_train.txt"))
dtActivityTest <- fread(file.path(fitbit, "test", "Y_test.txt"))

#Read the data files.
fileToDataTable <- function(f) {
  df <- read.table(f)
  dt <- data.table(df)
}
dtTrain <- fileToDataTable(file.path(fitbit, "train", "X_train.txt"))
dtTest <- fileToDataTable(file.path(fitbit, "test", "X_test.txt"))

#Bind the data tables.
dtSubject <- rbind(dtSubjectTrain, dtSubjectTest)
setnames(dtSubject, "V1", "subject")
dtActivity <- rbind(dtActivityTrain, dtActivityTest)
setnames(dtActivity, "V1", "activityNum")
dt <- rbind(dtTrain, dtTest)

#Merge the columns.
dtSubject <- cbind(dtSubject, dtActivity)
dt <- cbind(dtSubject, dt)

setkey(dt, subject, activityNum)

#Read the features.txt file.
dtFeatures <- fread(file.path(fitbit, "features.txt"))
setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName"))

#Subset the mean and standard deviation.
dtFeatures <- dtFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]

#make table of variable names
dtFeatures$featureCode <- dtFeatures[, paste0("V", featureNum)]
head(dtFeatures)
dtFeatures$featureCode
select <- c(key(dt), dtFeatures$featureCode)
dt <- dt[, select, with = FALSE]

#read activity data and merge
dtActivityNames <- fread(file.path(fitbit, "activity_labels.txt"))
setnames(dtActivityNames, names(dtActivityNames), c("activityNum", "activityName"))
dt <- merge(dt, dtActivityNames, by = "activityNum", all.x = TRUE)
setkey(dt, subject, activityNum, activityName)

#reshape data table using melt
dt <- data.table(melt(dt, key(dt), variable.name = "featureCode"))
dt <- merge(dt, dtFeatures[, list(featureNum, featureCode, featureName)], by = "featureCode", 
            all.x = TRUE)

#create new variables
dt$activity <- factor(dt$activityName)
dt$feature <- factor(dt$featureName)

#grep
grepthis <- function(regex) {
  grepl(regex, dt$feature)
}
## Features with 2 categories
n <- 2
y <- matrix(seq(1, n), nrow = n)
x <- matrix(c(grepthis("^t"), grepthis("^f")), ncol = nrow(y))
dt$featDomain <- factor(x %*% y, labels = c("Time", "Freq"))
x <- matrix(c(grepthis("Acc"), grepthis("Gyro")), ncol = nrow(y))
dt$featInstrument <- factor(x %*% y, labels = c("Accelerometer", "Gyroscope"))
x <- matrix(c(grepthis("BodyAcc"), grepthis("GravityAcc")), ncol = nrow(y))
dt$featAcceleration <- factor(x %*% y, labels = c(NA, "Body", "Gravity"))
x <- matrix(c(grepthis("mean()"), grepthis("std()")), ncol = nrow(y))
dt$featVariable <- factor(x %*% y, labels = c("Mean", "SD"))
## Features with 1 category
dt$featJerk <- factor(grepthis("Jerk"), labels = c(NA, "Jerk"))
dt$featMagnitude <- factor(grepthis("Mag"), labels = c(NA, "Magnitude"))
## Features with 3 categories
n <- 3
y <- matrix(seq(1, n), nrow = n)
x <- matrix(c(grepthis("-X"), grepthis("-Y"), grepthis("-Z")), ncol = nrow(y))
dt$featAxis <- factor(x %*% y, labels = c(NA, "X", "Y", "Z"))

r1 <- nrow(dt[, .N, by = c("feature")])
r2 <- nrow(dt[, .N, by = c("featDomain", "featAcceleration", "featInstrument", 
                           "featJerk", "featMagnitude", "featVariable", "featAxis")])
r1 == r2

setkey(dt, subject, activity, featDomain, featAcceleration, featInstrument, 
       featJerk, featMagnitude, featVariable, featAxis)
dtTidy <- dt[, list(count = .N, average = mean(value)), by = key(dt)]

#view your data
dtTidy
str(dtTidy)
key(dtTidy)
#save data
f <- file.path(path, "fitbit.txt")
write.table(dtTidy, f, quote = FALSE, sep = "\t", row.names = FALSE)
