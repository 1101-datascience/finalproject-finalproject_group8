# function >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# 先各個標籤分開抽樣處理，最後將各組併在一起(除不盡的隨機配到各組)
get_kfold_idx <- function (d, k, label_col) {
  if (!is.factor(d[, label_col])) {
    d[, label_col] <- as.factor(d[, label_col])
  }
  
  label_class <- levels(d[, label_col])
  
  class_gp_ls <- c()
  for (cls in label_class) {
    cls_id <- which(d[, label_col] == cls)
    # 打亂
    cls_id <- sample(cls_id)
    
    div <- length(cls_id)/k
    group_num <- round(div)
    
    # 每組分 group_num 個，多的會在 k+1 組
    group <- split(cls_id, ceiling(seq_along(cls_id)/group_num)) # https://stackoverflow.com/questions/3318333/split-a-vector-into-chunks
    
    # 除不盡的 k+1 組，隨機分配到各組
    if (paste(k+1) %in% names(group)) {
      # random assign item
      for (idx in group[[k+1]]) {
        rand_group <- sample(k)[[1]]
        group[[rand_group]] <- c(group[[rand_group]], idx)
      }
      # remove last group 
      group[[k+1]] <- NULL
    }
    
    class_gp_ls <- c(class_gp_ls, group)
  }
  
  # 將同組不同標籤的抽樣id合併
  gb_combine <- list()
  for (gp in 1:k) {
    for (i in class_gp_ls[names(class_gp_ls)==gp]) {
      if (paste(gp) %in% names(gb_combine)) {
        gb_combine[[paste(gp)]] <- c(gb_combine[[gp]], i)
      } else {
        gb_combine[[paste(gp)]] <- i
      }
    }
  }
  class_gp_ls[names(class_gp_ls)==1]
  
  
  return (gb_combine)
}

# 根據當前的 fold 和總 fold 數量，回傳 train、val、test 的 fold
get_train_val_fold <- function (test_fold, max_fold) {
  if (test_fold+1 > max_fold) {
    val_fold <- 1
  } else {
    val_fold <- test_fold+1
  }
  
  train_fold <- c()
  for (i in 1:max_fold) {
    if (!(i %in% c(test_fold, val_fold))) {
      train_fold <- c(train_fold, i)
    }
  }
  return (list(train=train_fold, val=val_fold, test=test_fold))
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# main process >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<