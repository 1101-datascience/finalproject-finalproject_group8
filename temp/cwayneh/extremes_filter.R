# extremes filter
file1 <- 'train.csv'
file2 <- 'test.csv'
train <- read.csv(file1, header = TRUE)
test <- read.csv(file2, header = TRUE)
ncol(train)
summary(train)
median(train$Amount[train$Class==1])
# initial
train_fe <- train[,-1]
start.time <- Sys.time()
  for (i in 1:(ncol(train_fe)-1)) {
    isd <- sd(train_fe[,i])
    imd <- median(train_fe[,i])
    train_fe <- train_fe[train_fe[,i]<(imd+3*isd)&train_fe[,i]>(imd-3*isd),]
    print(paste0("filter ",i," feature(s) left rows:",nrow(train_fe)))
    print(paste0("num of fraud:",nrow(train_fe[train$Class==1,])))
    model_fe <- rpart(train_fe$Class~.,train_fe[,-ncol(train_fe)],method = "class")
    # ,control = rpart.control(cp=0.001,minsplit = 650,minbucket = 220,maxdepth = 8))
    pred_fe <- predict(model_fe,test[,-ncol(test)],type="class")
    cm_fe <- table(truth=test$Class,pred=pred_fe)
    print(cm_fe)
    # acu_fe <- round(sum(diag(cm_fe))/sum(cm_fe),2)
    # print(acu_fe)
    p <- diag(cm_fe) / colSums(cm_fe)
    r <- diag(cm_fe) / rowSums(cm_fe)
    print(paste0("precision, recall:",p[2],",",r[2]))
  }
end.time <- Sys.time()
time.taken <- end.time - start.time
print(time.taken)
