
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
               "../data/project.zip", method = "curl")
unzip("../data/project.zip",exdir="../data")

# bring in data
X_test = read.table("../data/UCI HAR Dataset/test/X_test.txt",sep="")
Y_test = read.table("../data/UCI HAR Dataset/test/Y_test.txt",sep="")
X_train = read.table("../data/UCI HAR Dataset/train/X_train.txt",sep="")
Y_train = read.table("../data/UCI HAR Dataset/train/Y_train.txt",sep="")

# bring in activity, subject, and features
activity = read.table("../data/UCI HAR Dataset/activity_labels.txt",sep="")
names(activity) = c("classlabel","activityname")
activity$activityname = gsub("_"," ",activity$activityname)
subject_test = read.table("../data/UCI HAR Dataset/test/subject_test.txt",sep="")
subject_train = read.table("../data/UCI HAR Dataset/train/subject_train.txt",sep="")
features_list = read.table("../data/UCI HAR Dataset/features.txt",sep="",stringsAsFactors=FALSE)$V2

dim(X_test)
#[1] 2947  561
dim(Y_test)
#[1] 2947    1
dim(subject_test)
#[1] 2947    1

dim(X_train)
#[1] 7352  561
dim(Y_train)
#[1] 7352    1
dim(subject_train)
#[1] 7352    1

# subset and merge data
keepFeatures = sort(c(setdiff(grep("mean()",features_list),grep("meanFreq()",features_list)),
                 grep("std()",features_list)))

# fix names in features_lsit
f2 = gsub("\\(\\)-","_",features_list)
f3 = gsub("\\(\\)","",f2)
features_list = gsub("-","_",f3)

X_test = X_test[,keepFeatures]
names(X_test) = features_list[keepFeatures]
X_train = X_train[,keepFeatures]
names(X_train) = features_list[keepFeatures]

names(Y_test) = "classlabel"
Y_test = merge(Y_test,activity,sort=FALSE)
names(Y_train) = "classlabel"
Y_train = merge(Y_train,activity,sort=FALSE)

names(subject_test) = "subject"
names(subject_train) = "subject"

test_all = data.frame(cbind("set"="test",subject_test,Y_test,X_test))
train_all = data.frame(cbind("set"="train",subject_train,Y_train,X_train))

data_combined = rbind(test_all,train_all)


# by() didn't work for me... so I'm doing this brute force
groupings = factor(apply(data_combined[,1:4],1,function(x) paste(as.character(x),collapse="_")))
outList =list()
for(iGroup in levels(groupings)) {
  whichVec = which(groupings == iGroup)
  outList[[iGroup]] = apply(data_combined[whichVec,5:ncol(data_combined)],2,mean)
}

tidy.groups = cbind(do.call(rbind,strsplit(levels(groupings),"_")))
tidy.data = do.call(rbind,outList)

tidy = data.frame(cbind(tidy.groups,tidy.data))
names(tidy) = names(data_combined)

write.table(tidy,"tidydata.txt",sep=",",row.names=FALSE)

