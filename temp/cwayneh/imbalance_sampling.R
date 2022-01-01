under_sample <- function(data, nsmp, amp){
  f_ind <- which(data$Class == 1)
  nf_ind <- which(data$Class == 0)
  pick_f <- sample(f_ind, nsmp)
  pick_nf <- sample(nf_ind, nsmp*amp)
  usmp.data <- data[c(pick_f, pick_nf),]
}
# read parameters
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("USAGE: Rscript hw6_studentID.R --nsmp n --amp m --train Data/train.csv --test Data/test.csv --report performance.csv --predict predict.csv", call.=FALSE)
}
# parse parameters
i<-1 
while(i < length(args))
{
  if(args[i] == "--nsmp"){
    nsmp<-as.integer(args[i+1])
    i<-i+1
  }else if(args[i] == "--amp"){
    amp<-as.integer(args[i+1])
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

# nrow(train[train$Class==1,])
# dat <- under_sample(train, nrow(train[train$Class==1,]), 5)
# which(dat$Class==0)

require(rpart)
set.seed(65)
# nsmp <- nrow(train[train$Class==1,])
# amp <- 10
train_v <- under_sample(train, nsmp, amp)
model_v <- rpart(Class~., train_v, method = "class")
pred_v <- predict(model_v, test, type = "class")
cm_v <- table(truth=test$Class, pred=pred_v)
print(cm_v)
p <- diag(cm_v) / colSums(cm_v)
r <- diag(cm_v) / rowSums(cm_v)
print(paste("precision, recall of fraud:",round(p[2],6),",",round(r[2],6)))

out_data <- data.frame(NumberOfSample=nsmp, 
                       Amplification=amp, 
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
