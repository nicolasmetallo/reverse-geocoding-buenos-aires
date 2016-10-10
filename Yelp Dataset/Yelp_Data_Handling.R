## 1. I loaded the yelp_academic_review completely. 
## This is the csv file I generated with the Python script.
## This file's size is 1.94 Gb.
yelp_academic_dataset_review <- read.csv("~/NYU/yelp_academic_dataset_review.csv", comment.char="#")
View(yelp_academic_dataset_review)

## 2. I deleted the columns that were not useful.

yelp_academic_dataset_review$votes.cool = NULL
yelp_academic_dataset_review$votes.funny = NULL
yelp_academic_dataset_review$type = NULL
yelp_academic_dataset_review$votes.useful = NULL
yelp_academic_dataset_review$review_id = NULL

## 3. I loaded the yelp_academic_business file as "yelpBusiness"

yelpBusiness <- read.csv("~/NYU/yelp_academic_dataset_business.csv", comment.char="#")

## 4. Then I did a subset of that to only show things from Las Vegas

yelpBussEnd = subset(yelpBusiness, city == "Las Vegas")
View(yelpBussEnd)

## 5. I then merged both dataframes into "mYelp" by using their business_id

mYelp=merge(yelp_academic_dataset_review,yelpBussEnd,by="business_id")

## 6. I then exported it to a csv file to work it on Tableau

write.csv(mYelp, file = "mYelp.csv")

## 7. I then created 5 different subsets of data to account for all asian restaurants using grepl function
## Note: Grepl is a function that searches text in a variable and returns if its true.
mYelp1 = subset(mYelp, grepl("Chinese", mYelp$categories))
mYelp2 = subset(mYelp, grepl("Japanese", mYelp$categories))
mYelp3 = subset(mYelp, grepl("Sushi", mYelp$categories))
mYelp4 = subset(mYelp, grepl("Thai", mYelp$categories))
mYelp5 = subset(mYelp, grepl("Vietnamese", mYelp$categories))

## 8. I combined all the datasets using rbind (which just adds them one after the other)

mYelpComb = rbind(mYelp1, mYelp2, mYelp3, mYelp4, mYelp5)

## 9. Then we had to eliminate duplicates because in some cases there were "Categories" written like this:
## (Vietnamese, Thai, Restaurant) at the same time. For that we used this script

# Show the repeat entries
df[duplicated(df),]
# Show unique repeat entries (row names may differ, but values are the same)
unique(df[duplicated(df),])
# Original data with repeats removed. These do the same:
unique(df)
df[!duplicated(df),]

## 10. We then export it as csv to work on Tableau

mYelpFinal = unique(mYelpComb)
write.csv(mYelpFinal, file = "mYelpAsian.csv")