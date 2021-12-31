check_library <- function(name) {
  if(!(name %in% rownames(installed.packages()))) {
    install.packages(name)
  }
}

# source: https://stackoverflow.com/questions/8499361/easy-way-of-counting-precision-recall-and-f1-score-in-r
evaluation_score <- function(predicted, expected, positive.class="1") {
  predicted <- factor(as.character(predicted), levels=unique(as.character(expected)))
  expected  <- as.factor(expected)
  cm = as.matrix(table(expected, predicted))
  
  precision <- diag(cm) / colSums(cm)
  recall <- diag(cm) / rowSums(cm)
  f1 <-  ifelse(precision + recall == 0, 0, 2 * precision * recall / (precision + recall))
  
  #Assuming that F1 is zero when it's not possible compute it
  f1[is.na(f1)] <- 0
  
  #Binary F1 or Multi-class macro-averaged F1
  f1 <-  ifelse(nlevels(expected) == 2, f1[positive.class], mean(f1))
  
  return(list(precision=precision, recall=recall, f1=f1))
}

get_evaluate <- function(model, train, test, label, val=NA, th=NA, pred_type="class") {
  calculate_accuracy <- function(frame) {
    rtab <- table(frame)
    return(sum(diag(rtab)) / sum(rtab)) # diag 取對角線值
  }
  # 計算 train、val、test 分數
  train_resultframe <- data.frame(truth=train[, label],
                                  pred=predict(model, train, type=pred_type))

  test_resultframe <- data.frame(truth=test[, label],
                                 pred=predict(model, test, type=pred_type))
  
  if (!is.na(th)) {
    train_resultframe$pred <- ifelse(train_resultframe$pred>th, 1, 0)
    test_resultframe$pred <- ifelse(test_resultframe$pred>th, 1, 0)
  }
  
  train_acc <- calculate_accuracy(train_resultframe)
  test_acc <- calculate_accuracy(test_resultframe)
  
  # 如果有 val 的話才跑
  if (!is.na(val)) {
    val_resultframe <- data.frame(truth=val[, label],
                                  pred=predict(model, val, type = 'class'))
    if (!is.na(th)) {
      val_resultframe$pred <- ifelse(val_resultframe$pred>th, 1, 0)
    }
    
    val_acc <- calculate_accuracy(val_resultframe)
    
    result <- list(train=train_acc, val=val_acc, test=test_acc, 
                   train_table=train_resultframe, 
                   val_table=val_resultframe, 
                   test_table=test_resultframe)

  } else {
    result <- list(train=train_acc, test=test_acc, 
                   train_table=train_resultframe,
                   test_table=test_resultframe)
  }
  
  evaluation_score
  merge.list(x,y)

}