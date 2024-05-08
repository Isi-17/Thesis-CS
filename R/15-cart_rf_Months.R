################################# Decision Tree (CART) && RandomForest ###########################################
# Load required library
library(caret)
library(rpart)
library(randomForest)

set.seed(123)

# Define a function to train models, make predictions, and calculate accuracy
train_and_predict <- function(train_data, test_data, target_variable) {
  # Identify all the unique categories present in the training and test sets.
  unique_categories <- unique(c(as.character(unlist(train_data)), as.character(unlist(test_data))))
  test_data_rf <- test_data
  
  N_test <- nrow(test_data)
  train_data_f <- lapply(train_data, function(x) {factor(x, levels = unique_categories)})
  test_data_f <- lapply(test_data, function(x) {factor(x, levels = unique_categories)})
  
  # Decision Tree (CART)
  model_rpart <- rpart(formula(paste(target_variable, "~ .")), data = train_data_f, method = "class")
  predictions_rpart <- predict(model_rpart, test_data_f, type = "class")
  accuracy_rpart <- sum(predictions_rpart == test_data_f[[target_variable]]) / N_test
  
  # RANDOM FOREST
  N <- nrow(data)
  train_data <- lapply(train_data, as.factor)
  model_rf <- randomForest(formula(paste(target_variable, "~ .")), data = train_data, ntree=100)
  test_data <- lapply(test_data, as.factor)
  
  # Remove levels not present in the training data.
  for (i in seq_along(train_data)) {
    if (is.factor(test_data[[i]])) {
      test_data[[i]] <- factor(test_data[[i]], levels = levels(train_data[[i]]))
    }
  }
  
  predictions_rf <- predict(model_rf, test_data)
  predictions_rf <- predictions_rf[!is.na(predictions_rf)]
  actual_values <- test_data_rf[names(predictions_rf),target_variable]
  
  accuracy_rf <- sum(predictions_rf == actual_values) / length(actual_values)
  
  return(list(accuracy_rpart = accuracy_rpart, accuracy_rf = accuracy_rf))
}

# Define file paths
file_paths <- c("Files/sequences_output_letters_with_month7.txt", 
                "Files/sequences_output_letters_with_month14.txt", 
                "Files/sequences_output_letters_with_month21.txt", 
                "Files/sequences_output_letters_with_month28.txt")

# Read data and perform predictions for each dataset file
accuracies <- list()

for (i in 1:length(file_paths)) {
  data <- read.csv(file_paths[i], sep = " ", header = FALSE)
  target_variable <- names(data)[ncol(data)]
  
  N <- nrow(data)
  # Define the size of the training set (80%).
  train_size <- round(0.8 * N)
  
  # Split the data into training and test sets.
  index <- createDataPartition(y = data[[target_variable]], p = 0.8, list = FALSE)
  train_data <- data[index, ]
  test_data <- data[-index, ]
  
  rownames(test_data) <- NULL
  
  result <- train_and_predict(train_data, test_data, target_variable)
  accuracies[[i]] <- result
  cat("Dataset", i, "- Decision Tree (CART) Accuracy:", result$accuracy_rpart, "\n")
  cat("Dataset", i, "- Random Forest Accuracy:", result$accuracy_rf, "\n")
}

# Extract accuracy values for plotting
accuracy_rpart <- sapply(accuracies, function(x) x$accuracy_rpart)
accuracy_rf <- sapply(accuracies, function(x) x$accuracy_rf)

# Plot the evolution of accuracy
plot(1:length(file_paths), accuracy_rpart, type = "o", col = "blue", xlab = "Sequence Length", ylab = "Accuracy", 
     main = "Evolution of Model Accuracy", ylim = c(0, 1), xaxt = "n")
lines(1:length(file_paths), accuracy_rf, type = "o", col = "red")
legend("bottomright", legend = c("Decision Trees (RPART)", "Random Forest"), col = c("blue", "red"), pch = 1)
axis(1, at = 1:length(file_paths), labels = c(7, 14, 21, 28), las = 1)

