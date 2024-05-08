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
set.seed(123)

# Initialize vector to hold predictions
predictions <- character(length = nrow(observations))

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
  
  # Store the prediction
  predictions[i] <- next_state
}

# Print predictions
print(predictions)

# Evaluate the accuracy (assuming you have the actual values)
actual_values <- data[, target_variable]
accuracy <- sum(predictions == actual_values, na.rm = TRUE) / length(actual_values)
print(accuracy)

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
  
  # Replace missing probabilities with the most common letter
  next_states[is.na(next_states)] <- most_common_letter
  
  # Calculate accuracy for each day in the predicted sequence
  actual_values <- as.character(data[i + 1, ])
  actual_values <- actual_values[1:num_days]
  
  for (j in 1:num_days) {
    accuracies_col[i, j] <- sum(next_states[j] == actual_values[j])
  }
  
  # Calculate accuracy for this row
  accuracy <- sum(next_states[1:num_days] == actual_values) / num_days  # Adjust length to match num_days
  
  # Store accuracy for this row
  accuracies[i] <- accuracy
  
  # Store predicted and actual values for this row
  actual_values_confMatrix <- c(actual_values_confMatrix, actual_values)
  predicted_values_confMatrix <- c(predicted_values_confMatrix, next_states)
  
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


