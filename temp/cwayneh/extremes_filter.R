# extremes filter
extremes_handler <- function(method, range, data, target){
  data_eh <- data.frame(data[,target])
  switch (method,
    IQR = {
      for (i in 1:NCOL(data_eh)) {
        # q.75 <- quantile(data[,i], probs = 0.75)
        # q.25 <- quantile(data[,i], probs = 0.25)
        iqr <- IQR(data_eh[,i])
        lb <- range[1] #lower bound
        ub <- range[2] #upper bound
        data <- data[data_eh[,i]>(lb*iqr)&data_eh[,i]<(ub*iqr),]
      }
    },
    std = {
      for (i in 1:NCOL(data_eh)) {
        isd <- sd(data_eh[,i]) #standard deviation
        imn <- mean(data_eh[,i]) #mean
        lb <- range[1] #lower bound
        ub <- range[2] #upper bound
        data <- data[data_eh[,i]>(imn+lb*isd)&data_eh[,i]<(imn+ub*isd),]
      }
    }
  )
  data <- data
}
# read parameters
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("USAGE: Rscript extremes_filter.R --method IQR --range -3,3 --target 2:29 --train train.csv --test test.csv --report output/performance.ef.csv", call.=FALSE)
}
# parse parameters
i<-1 
while(i < length(args))
{
  if(args[i] == "--method"){
    method<-args[i+1]
    i<-i+1
  }else if(args[i] == "--range"){
    range<-as.numeric(unlist(strsplit(args[i+1],',')))
    i<-i+1
  }else if(args[i] == "--target"){
    target<-as.integer(unlist(strsplit(args[i+1],':')))
    target<-c(target[1]:target[2])
    i<-i+1
  }else if(args[i] == "--train"){
    filen<-args[i+1]
    i<-i+1
  }else if(args[i] == "--test"){
    filen2<-args[i+1]
    i<-i+1
  }else if(args[i] == "--report"){
    out_f<-args[i+1]
    i<-i+1
  }else{
    stop(paste("Unknown flag or input illegal file name etc. include'--' :", args[i]), call.=FALSE)
  }
  i<-i+1
}
start.time <- Sys.time()
# filen <- 'train.csv'
# filen2 <- 'test.csv'
train <- read.csv(filen, header = TRUE)
test <- read.csv(filen2, header = TRUE)
require(rpart)
# method <- 'IQR'
# target <- '2:2'
# target <- as.integer(unlist(strsplit(target,':')))
# target <- c(target[1]:target[2])
# range <- '-3.5,3.5'
# range <- as.numeric(unlist(strsplit(range,',')))
names(train)[target]
train_v <- extremes_handler(method, range, train, target)
model_v <- rpart(Class~., train_v, method = "class")
pred_v <- predict(model_v, test, type = "class")
cm_v <- table(truth=test$Class, pred=pred_v)
print(cm_v)
p <- diag(cm_v) / colSums(cm_v)
r <- diag(cm_v) / rowSums(cm_v)
print(paste("precision, recall of fraud:",round(p[2],6),",",round(r[2],6)))

out_data <- data.frame(Method=method, 
                       Range=paste(range,collapse = "~"), 
                       TargetFeature=paste(names(train)[target],collapse = "+"),
                       Precision=round(p[2],6),
                       Recall=round(r[2],6),
                       NumberOfRow=nrow(train_v),
                       stringsAsFactors = FALSE)
print(out_data)

#first check path existed with parsing out-path
pth_chk <- unlist(strsplit(out_f,'/'))
pth_chk2 <- unlist(strsplit(out_f,pth_chk[length(pth_chk)]))
#second create dir if existed or not
dir.create(pth_chk2,showWarnings = FALSE)
# then write file
# out_f <- 'outtest.csv'
write.table(out_data, file=out_f, append = T, row.names = F, 
            col.names = ifelse(file.exists(out_f),F,T), quote = F, sep=",")
print("DONE")

end.time <- Sys.time()
time.taken <- end.time - start.time
print(time.taken)
