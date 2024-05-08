############################ PST MODEL FOR EACH ROW ############################

# Load necessary libraries
library(PST)
library(TraMineR)
library(caret)

# Read data
path <- "Files/sequence_patterns_2_6-10.csv"
data <- read.csv(path)
observations <- data[, -1]  # Exclude the ID column

# Read correlation matrix
cor_matrix <- read.csv("Files/correlation_matrix.csv", colClasses=c("NULL", rep("numeric", 21)))

set.seed(123)

# Threshold for correlation
correlation_threshold <- 0.9  # You can adjust this threshold as needed

correct_predictions_with_correlation <- function(predictions, actual, cor_matrix, threshold) {
  # Get the indices of actual and predicted letters in the correlation matrix
  actual_indices <- match(actual, colnames(cor_matrix))
  predicted_indices <- match(predictions, colnames(cor_matrix))
  
  # Get the correlation values for each prediction
  correlation_values <- cor_matrix[cbind(actual_indices, predicted_indices)]
  
  # Initialize corrected predictions with predicted values
  corrected_predictions <- predictions
  
  # Find indices where correlation is above the threshold
  high_correlation <- correlation_values >= threshold
  
  # Update corrected predictions where correlation is high
  corrected_predictions[high_correlation] <- actual[high_correlation]
  
  return(corrected_predictions)
}

# Define parameters for PST construction
L <- 14  # Maximal depth of the PST

# Function to predict next state for a single row
predict_next_state_single_row <- function(row) {
  # Convert the row into a sequence object
  sequence <- seqdef(row, 1:399, alphabet = LETTERS[1:21])
  
  # Build a probabilistic suffix tree for the current row
  pst_model <- pstree(object = sequence,
                      L = L,
                      nmin = 1,
                      ymin = NULL,
                      weighted = TRUE,
                      with.missing = FALSE,
                      lik = TRUE)  # Compute log-likelihood
  
  # Convert factors to characters and concatenate them into a single string with "-"
  sequence_string <- paste(as.character(unlist(sequence)), collapse = "-")
  
  # Predict the next state probabilities
  next_state_probs <- query(pst_model, context = sequence_string)
  
  # Get the most probable next state
  max_prob_index <- which.max(next_state_probs)
  next_state <- pst_model@alphabet[max_prob_index]
  
  # Return the predicted next state
  return(next_state)
}

# Initialize variables for accuracy calculation
num_correct_predictions <- 0
total_predictions <- 0
actual_values <- character()
corrected_predicted_values <- character()

# Loop through each row in the dataset
for (i in 1:nrow(data)) {
  # Extract the row
  row <- data[i, -1]  # Exclude the ID column
  
  # Predict the next state for the current row
  predicted_next_state <- predict_next_state_single_row(row)
  
  # Apply correction based on correlation
  corrected_next_state <- correct_predictions_with_correlation(predicted_next_state, data[i, 400], cor_matrix, correlation_threshold)
  
  # Increment the total number of predictions
  total_predictions <- total_predictions + 1
  
  actual_value <- data[i, 400]  # Assuming the next state is in the last column
  actual_values <- c(actual_values, actual_value)
  corrected_predicted_values <- c(corrected_predicted_values, corrected_next_state)
  
  # Check if the corrected prediction is correct
  if (corrected_next_state == actual_value) {
    num_correct_predictions <- num_correct_predictions + 1
  }
}

# Calculate accuracy
accuracy <- num_correct_predictions / total_predictions

# Print the accuracy
print(paste("Accuracy with correction:", accuracy))

# Convert actual_values and corrected_predicted_values to factors
actual_values <- as.factor(actual_values)
corrected_predicted_values <- as.factor(corrected_predicted_values)

# Compute confusion matrix
conf_matrix <- confusionMatrix(data = corrected_predicted_values, reference = actual_values)

# Print confusion matrix
print(conf_matrix)
