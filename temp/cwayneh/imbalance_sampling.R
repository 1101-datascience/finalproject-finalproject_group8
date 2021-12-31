file1 <- 'train.csv'
file2 <- 'test.csv'
train <- read.csv(file1, header = TRUE)
test <- read.csv(file2, header = TRUE)
under_sample <- function(data, nsmp, amp){
  f_ind <- which(data$Class == 1)
  nf_ind <- which(data$Class == 0)
  pick_f <- sample(f_ind, nsmp)
  pick_nf <- sample(nf_ind, nsmp*amp)
  usmp.data <- data[c(pick_f, pick_nf),]
}
nrow(train[train$Class==1,])
dat <- under_sample(train, nrow(train[train$Class==1,]), 5)
which(dat$Class==0)

require(rpart)
for (i in c(10,100,1000)) {
  set.seed(65)
  nsmp <- nrow(train[train$Class==1,])
  train_v <- under_sample(train, 150, i)
  model_v <- rpart(Class~., train_v, method = "class")
  pred_v <- predict(model_v, test, type = "class")
  cm_v <- table(test$Class, pred_v)
  print(cm_v)
  p <- diag(cm_v) / colSums(cm_v)
  r <- diag(cm_v) / rowSums(cm_v)
  print(paste0("precision, recall:",p,",",r))
}
