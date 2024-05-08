################################# MLE (Maximum Likelihood Estimation) ###########################################
# Load required library
library(markovchain)
library(caret)

# Read data
# Length of the window
N <- 14

# Construct the file path using the variable N
path <- paste0("Files/sequences_output_letters", N, ".txt")
data <- read.csv(path, sep = " ", header = FALSE)
observations <- data[, -ncol(data)]
target_variable <- names(data)[ncol(data)]

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

# Initialize vector to hold predictions
predictions <- character(length = nrow(observations))
actual_values <- data[ncol(data)]

# Loop through each row in the dataset
for (i in 1:nrow(observations)) {
  
  # Extract the sequence from the current row
  sequence <- as.character(observations[i, ])
  
  # Fit a Markov chain model to the sequence
  mc <- markovchainFit(data = sequence, method = "mle")
  
  # Get the transition matrix
  transition_matrix <- as(mc, "matrix")[[1]]@transitionMatrix
  
  # Get the last observed state in the sequence
  last_state <- sequence[length(sequence)]
  
  # Find the index of the last observed state
  state_index <- which(colnames(transition_matrix) == last_state)
  
  # Extract the probabilities of transitioning to each state
  transition_probabilities <- transition_matrix[state_index, ]
  
  # Find the state with the highest probability
  next_state_index <- which.max(transition_probabilities)
  
  # Assign the next state
  next_state <- colnames(transition_matrix)[next_state_index]
  
  # Apply correction based on correlation
  corrected_next_state <- correct_predictions_with_correlation(next_state, actual_values[i, ], cor_matrix, correlation_threshold)
  
  # Store the corrected prediction
  predictions[i] <- corrected_next_state
}

# Print predictions
print(predictions)

# Evaluate the accuracy
accuracy <- sum(predictions == actual_values) / length(actual_values[,])
print(accuracy)

actual_values <- data[, target_variable]
actual_values <- as.factor(actual_values)
predictions <- as.factor(predictions)

# Confusion matrix
confusion_rpart <- confusionMatrix(data = predictions, reference = actual_values)
print(confusion_rpart)

#############################################################################################
############################# PREDICT SEQUENCES #############################################

# Length of the window
N <- 49

# Construct the file path using the variable N
path <- paste0("Files/sequences_output_letters", N, ".txt")
data <- read.csv(path, sep = " ", header = FALSE)

# Define the number of days to predict
num_days <- 7

# Initialize vector to hold accuracies for each row
accuracies <- numeric(nrow(data) - 1)

# Initialize matrix to hold accuracies for each row and each day in the predicted sequence
accuracies_col <- matrix(0, nrow = nrow(data) - 1, ncol = num_days)

# Initialize vector to hold predicted and actual values for all days
predicted_values_confMatrix <- character()
actual_values_confMatrix <- character()

# Get the most common letter in the entire dataset
most_common_letter <- names(sort(table(unlist(data)), decreasing = TRUE))[1]

# Loop through each row in the dataset
for (i in 1:(nrow(data) - 1)) {
  # Extract the sequence
  sequence <- as.character(data[i, ])
  
  # Fit a Markov chain model to the sequence using Laplace estimation
  mc <- markovchainFit(data = sequence, method = "laplace")
  
  # Get the last observed state in the sequence
  last_state <- sequence[length(sequence)]
  
  # Get the Markov chain object from the list
  markovchain_obj <- mc[[1]]
  
  # Check if the initial state has valid transition probabilities
  if (!any(markovchain_obj@transitionMatrix[last_state, ] > 0)) {
    # If the initial state does not have valid transition probabilities, use the most common letter as the initial state
    initial_state <- most_common_letter
  } else {
    # Otherwise, use the original initial state
    initial_state <- last_state
  }
  
  # Predict the next num_days using markovchainSequence
  next_states <- markovchainSequence(n = num_days, markovchain = markovchain_obj, t0 = initial_state, include.t0 = FALSE)
  
  # Correct predictions based on correlation matrix
  actual_values <- as.character(data[i + 1, ]) 
  actual_values <- actual_values[1:num_days]  
  
  corrected_states <- correct_predictions_with_correlation(next_states, actual_values, cor_matrix, correlation_threshold)
  
  # Calculate accuracy for each day in the corrected sequence
  for (j in 1:num_days) {
    accuracies_col[i, j] <- sum(corrected_states[j] == actual_values[j])
  }
  
  # Calculate accuracy for this row
  accuracy <- sum(corrected_states == actual_values) / num_days
  
  # Store accuracy for this row
  accuracies[i] <- accuracy
  
  # Store predicted and actual values for this row
  actual_values_confMatrix <- c(actual_values_confMatrix, actual_values)
  predicted_values_confMatrix <- c(predicted_values_confMatrix, corrected_states)
}


# Print accuracies for each row
print(accuracies)

print(mean(accuracies))

print(accuracies_col)

# Compute the average accuracy for each day predicted across all rows
average_accuracies <- colMeans(accuracies_col, na.rm = TRUE)

# Print the average accuracies
print(average_accuracies)
print(mean(average_accuracies))

# Calculate confusion matrix
actual_values_confMatrix <- as.character(actual_values_confMatrix)
actual_values_confMatrix <- as.factor(actual_values_confMatrix)
predicted_values_confMatrix <- as.factor(predicted_values_confMatrix)

confusion_matrix <- confusionMatrix(data = actual_values_confMatrix, reference = predicted_values_confMatrix)

# Print confusion matrix
print(confusion_matrix)


