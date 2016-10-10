############# Business Analytics ###########
################################################
################################################
# Load required packages
library(rpart)
library(rpart.plot)
library(ggplot2)
library(plyr)
library(reshape2)

## Load the data
Yelp_train <- read.csv("~/NYU/Spring 2016/Business Analytics/Yelp_train.csv", comment.char="#")
View(Yelp_train)

Yelp_test <- read.csv("~/NYU/Spring 2016/Business Analytics/Yelp_test.csv", comment.char="#")
View(Yelp_test)

summary(Yelp_train)
names(Yelp_train)
View(Yelp_train)

## We start out regression model with all variables and start eliminating by trial and error

Yelp_train$attributes.Accepts.Credit.Cards = NULL
Yelp_train$attributes.Accepts.Insurance = NULL
Yelp_train$attributes.Ages.Allowed = NULL
Yelp_train$attributes.Alcohol = NULL
Yelp_train$attributes.Ambience.casual = NULL
Yelp_train$attributes.Ambience.divey = NULL
Yelp_train$attributes.Ambience.classy = NULL
Yelp_train$attributes.Ambience.hipster = NULL
Yelp_train$attributes.Ambience.intimate = NULL
Yelp_train$attributes.Ambience.romantic = NULL
Yelp_train$attributes.Ambience.touristy = NULL
Yelp_train$attributes.Ambience.trendy = NULL
Yelp_train$attributes.Ambience.upscale = NULL
Yelp_train$attributes.Attire = NULL
Yelp_train$attributes.By.Appointment.Only = NULL
Yelp_train$attributes.BYOB = NULL
Yelp_train$attributes.Caters = NULL
Yelp_train$attributes.Coat.Check = NULL
Yelp_train$attributes.Corkage = NULL
Yelp_train$attributes.Delivery = NULL
Yelp_train$attributes.Dietary.Restrictions.dairy.free = NULL
Yelp_train$attributes.Dietary.Restrictions.gluten.free = NULL
Yelp_train$attributes.Dietary.Restrictions.halal = NULL
Yelp_train$attributes.Dietary.Restrictions.kosher = NULL
Yelp_train$attributes.Dietary.Restrictions.soy.free = NULL
Yelp_train$attributes.Dietary.Restrictions.vegan = NULL
Yelp_train$attributes.Dietary.Restrictions.vegetarian = NULL
Yelp_train$attributes.Dogs.Allowed = NULL
Yelp_train$attributes.Drive.Thru = NULL
Yelp_train$attributes.Good.For.breakfast = NULL
Yelp_train$attributes.Good.For.brunch = NULL
Yelp_train$attributes.Good.For.Dancing = NULL
Yelp_train$attributes.Good.For.dessert = NULL
Yelp_train$attributes.Good.For.dinner = NULL
Yelp_train$attributes.Good.For.Groups = NULL
Yelp_train$attributes.Good.for.Kids = NULL
Yelp_train$attributes.Good.For.latenight = NULL
Yelp_train$attributes.Good.For.lunch = NULL
Yelp_train$attributes.Happy.Hour = NULL
Yelp_train$attributes.Has.TV = NULL
Yelp_train$attributes.Music.background_music = NULL
Yelp_train$attributes.Music.dj = NULL
Yelp_train$attributes.Music.jukebox = NULL
Yelp_train$attributes.Music.karaoke = NULL
Yelp_train$attributes.Music.live = NULL
Yelp_train$attributes.Music.live = NULL
Yelp_train$attributes.Music.video = NULL
Yelp_train$attributes.Noise.Level = NULL
Yelp_train$attributes.Noise.Level = NULL
Yelp_train$attributes.Open.24.Hours = NULL
Yelp_train$attributes.Order.at.Counter = NULL
Yelp_train$attributes.Outdoor.Seating = NULL
Yelp_train$attributes.Parking.garage = NULL
Yelp_train$attributes.Parking.lot = NULL
Yelp_train$attributes.Parking.street = NULL
Yelp_train$attributes.Parking.valet = NULL
Yelp_train$attributes.Parking.validated = NULL
Yelp_train$attributes.Smoking = NULL
Yelp_train$attributes.Take.out = NULL
Yelp_train$attributes.Takes.Reservations = NULL
Yelp_train$attributes.Waiter.Service = NULL
Yelp_train$attributes.Wheelchair.Accessible = NULL
Yelp_train$attributes.Wi.Fi = NULL
Yelp_train$business_id = NULL
Yelp_train$categories = NULL
Yelp_train$city = NULL
Yelp_train$date = NULL
Yelp_train$full_address = NULL
Yelp_train$hours.Friday.close = NULL
Yelp_train$hours.Friday.open = NULL
Yelp_train$hours.Monday.close = NULL
Yelp_train$hours.Monday.open = NULL
Yelp_train$hours.Saturday.close = NULL
Yelp_train$hours.Saturday.open = NULL
Yelp_train$hours.Sunday.close = NULL
Yelp_train$hours.Sunday.open = NULL
Yelp_train$hours.Thursday.close = NULL
Yelp_train$hours.Thursday.open = NULL
Yelp_train$hours.Tuesday.close = NULL
Yelp_train$hours.Tuesday.open = NULL
Yelp_train$hours.Wednesday.close = NULL
Yelp_train$hours.Wednesday.open = NULL
Yelp_train$latitude = NULL
Yelp_train$longitude = NULL
Yelp_train$name = NULL
Yelp_train$neighborhoods = NULL
Yelp_train$open = NULL
Yelp_train$review_count = NULL
Yelp_train$stars.y = NULL
Yelp_train$state = NULL
Yelp_train$text = NULL
Yelp_train$type = NULL
Yelp_train$user_id = NULL
Yelp_train$X = NULL
Yelp_train$X.1 = NULL
Yelp_train$X.2 = NULL
Yelp_train$X.3 = NULL
Yelp_train$attributes.Price.Range = as.factor(Yelp_train$attributes.Price.Range)
Yelp_train$stars.x = NULL

write.csv(Yelp_train, file = "mYelpAsianTrain.csv")

# For loop to get a binary variable for good reviews (4-5)

for (i in 1:nrow(Yelp_train)){
  if ((Yelp_train$stars.x[i]==4) | (Yelp_train$stars.x[i]==5))
    Yelp_train$GoodReview[i]<-as.logical(1)
  else
    Yelp_train$GoodReview[i]<-as.logical(0)
}

## Linear Regression Model

lm_yelp <- lm(stars.x ~ ., data=mYelpAsian)
summary(lm_yelp)

Yelp_test$stars.x = predict(lm_yelp, Yelp_test, interval="prediction", level=0.95)

# Classification Tree with CART modeling for determining if the client will subcribe for a term 
# deposit or not 
decision_tree <- rpart(GoodReview ~ ., method="class", data=Yelp_train)

## Variable type changing to re-try Classif Tree
Yelp_train$GoodReview = as.numeric(as.character(Yelp_train$GoodReview))

# Detailed summary of the resulting decision tree
summary(decision_tree)

# Output of the decision tree
plot(decision_tree, uniform=TRUE, main="Classification Tree")
text(decision_tree, use.n=TRUE, all=TRUE, cex=.8)

# Create plot of tree using the rpart.plot package for a better look
rpart.plot(decision_tree)
