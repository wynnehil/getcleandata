This codebook describes the variables, the data, and any transformations or work performed to clean up the data

1. Dataset structure
str(dtTidy)

Classes ‘data.table’ and 'data.frame':	11880 obs. of  11 variables:
 $ subject         : int  1 1 1 1 1 1 1 1 1 1 ...
 $ activity        : Factor w/ 6 levels "LAYING","SITTING",..: 1 1 1 1 1 1 1 1 1 1 ...
 $ featDomain      : Factor w/ 2 levels "Time","Freq": 1 1 1 1 1 1 1 1 1 1 ...
 $ featAcceleration: Factor w/ 3 levels NA,"Body","Gravity": 1 1 1 1 1 1 1 1 1 1 ...
 $ featInstrument  : Factor w/ 2 levels "Accelerometer",..: 2 2 2 2 2 2 2 2 2 2 ...
 $ featJerk        : Factor w/ 2 levels NA,"Jerk": 1 1 1 1 1 1 1 1 2 2 ...
 $ featMagnitude   : Factor w/ 2 levels NA,"Magnitude": 1 1 1 1 1 1 2 2 1 1 ...
 $ featVariable    : Factor w/ 2 levels "Mean","SD": 1 1 1 2 2 2 1 2 1 1 ...
 $ featAxis        : Factor w/ 4 levels NA,"X","Y","Z": 2 3 4 2 3 4 1 1 2 3 ...
 $ count           : int  50 50 50 50 50 50 50 50 50 50 ...
 $ average         : num  -0.0166 -0.0645 0.1487 -0.8735 -0.9511 ...
 - attr(*, "sorted")= chr  "subject" "activity" "featDomain" "featAcceleration" ...
 - attr(*, ".internal.selfref")=<externalptr> 
 
 2. Key to Variables
 key(dtTidy)
[1] "subject"          "activity"         "featDomain"       "featAcceleration" "featInstrument"   "featJerk"        
[7] "featMagnitude"    "featVariable"     "featAxis"        
>

3. Example Data:
dtTidy
       subject         activity featDomain featAcceleration featInstrument featJerk featMagnitude featVariable featAxis count
    1:       1           LAYING       Time               NA      Gyroscope       NA            NA         Mean        X    50
    2:       1           LAYING       Time               NA      Gyroscope       NA            NA         Mean        Y    50
    3:       1           LAYING       Time               NA      Gyroscope       NA            NA         Mean        Z    50
    4:       1           LAYING       Time               NA      Gyroscope       NA            NA           SD        X    50
    5:       1           LAYING       Time               NA      Gyroscope       NA            NA           SD        Y    50
   ---                                                                                                                       
11876:      30 WALKING_UPSTAIRS       Freq             Body  Accelerometer     Jerk            NA           SD        X    65
11877:      30 WALKING_UPSTAIRS       Freq             Body  Accelerometer     Jerk            NA           SD        Y    65
11878:      30 WALKING_UPSTAIRS       Freq             Body  Accelerometer     Jerk            NA           SD        Z    65
11879:      30 WALKING_UPSTAIRS       Freq             Body  Accelerometer     Jerk     Magnitude         Mean       NA    65
11880:      30 WALKING_UPSTAIRS       Freq             Body  Accelerometer     Jerk     Magnitude           SD       NA    65
           average
    1: -0.01655309
    2: -0.06448612
    3:  0.14868944
    4: -0.87354387
    5: -0.95109044
   ---            
11876: -0.56156521
11877: -0.61082660
11878: -0.78475388
11879: -0.54978489
11880: -0.58087813

4. Steps taken in transforming data
Read data files
Bind data files
Merge columns
read features, subset mean and SD
make table of variable names
read activity data and merge
new variable names created
grep function

