################################# MLE (Maximum Likelihood Estimation) ###########################################

# Load necessary libraries
library(markovchain)
library(caret)

# Read data
# Custom directory
data_path <- "Files/sequence_patterns_2_6-10.csv"

data <- read.csv(data_path)

observations <- data[, -1]  # Remove ID column
set.seed(123)
target_variable <- names(observations)[ncol(observations)]

cor_matrix <- read.csv("Files/correlation_matrix.csv", colClasses=c("NULL", rep("numeric", 21)))

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

################### One sequence #######################
# Extract one sequence (assuming it's the first row)
num_row <- 3
sequence <- as.character(observations[num_row, 1:399])

# Fit a Markov chain model to the sequence
mc <- markovchainFit(data = sequence, method = "mle")

# Get the transition matrix
transition_matrix <- as(mc, "matrix")

# Extract the estimated transition matrix from the transition_matrix list
transition_matrix <- transition_matrix[[1]]@transitionMatrix

# Check the column names of transition_matrix
colnames(transition_matrix)

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

# Print the prediction
print(next_state)

# Evaluate the accuracy (assuming you have the actual value)
actual_value <- data[num_row, target_variable]
print(next_state)
print(actual_value)

################### All sequences #######################

# Initialize vector to hold predictions
predictions <- character(length = nrow(observations))
actual_values <- data[ , target_variable]
# Loop through each row in the dataset
for (i in 1:nrow(observations)) {
  # Extract the sequence from the current row
  sequence <- as.character(observations[i, 1:399])
  
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
  predicted_next_state <- colnames(transition_matrix)[next_state_index]
  
  # Apply correction based on correlation
  corrected_next_state <- correct_predictions_with_correlation(predicted_next_state, actual_values[i], cor_matrix, correlation_threshold)
  
  # Store the corrected prediction
  predictions[i] <- corrected_next_state
}

# Print predictions
print(predictions)

# Evaluate the accuracy
accuracy <- sum(predictions == actual_values) / length(actual_values)
print(accuracy)

actual_values <- as.factor(actual_values)
predictions <- as.factor(predictions)

# Confusion matrix for rpart
confusion_rpart <- confusionMatrix(data = predictions, reference = actual_values)
print(confusion_rpart)


#############################################################################################
############################# SEQUENCES #####################################################

################################# All sequences ################################

# Define the number of days to predict
num_days <- 60

# Initialize vector to hold accuracies for each row
accuracies <- numeric(nrow(observations))
# Initialize matrix to hold accuracies for each row and each day in the predicted sequence
accuracies_col <- matrix(NA, nrow = nrow(observations), ncol = num_days)

# Initialize vector to hold predicted and actual values for all days
predicted_values_confMatrix <- character()
actual_values_confMatrix <- character()

# Loop through each row in the dataset
for (i in 1:nrow(observations)) {
  # Extract the sequence (excluding the last num_days days)
  sequence <- as.character(observations[i, 1:(400 - num_days)])
  
  # Fit a Markov chain model to the sequence
  mc <- markovchainFit(data = sequence, method = "mle")
  
  # Get the last observed state in the sequence
  last_state <- sequence[length(sequence)]
  
  # Get the Markov chain object from the list
  markovchain_obj <- mc[[1]]
  
  # Predict the next num_days ClusterDays using markovchainSequence
  next_states <- markovchainSequence(n = num_days, markovchain = markovchain_obj, t0 = last_state, include.t0 = FALSE)
  
  # Apply correction based on correlation for each day
  corrected_next_states <- character(num_days)
  for (k in 1:num_days) {
    corrected_next_states[k] <- correct_predictions_with_correlation(next_states[k], observations[i, 400 - num_days + k], cor_matrix, correlation_threshold)
  }
  
  # Calculate accuracy for each day in the predicted sequence
  actual_values <- observations[i, (401 - num_days):400]
  for (j in 1:num_days) {
    accuracies_col[i, j] <- sum(corrected_next_states[j] == actual_values[j]) / 1
  }
  
  # Calculate accuracy for this row
  accuracy <- sum(corrected_next_states == actual_values) / num_days
  
  # Store accuracy for this row
  accuracies[i] <- accuracy
  
  # Store predicted and actual values for this row
  actual_values_confMatrix <- c(actual_values_confMatrix, observations[i, (401 - num_days):400])
  predicted_values_confMatrix <- c(predicted_values_confMatrix, corrected_next_states)
}

# For 70 days sequence.
# Accuracies per ID
print(accuracies)
print(mean(accuracies))

# Accuracy for every ClusterDayX
print(accuracies_col)
# Compute the average accuracy for each day predicted across all rows
average_accuracies <- colMeans(accuracies_col, na.rm = TRUE)

# Print the average accuracies per day
print(average_accuracies)

print(mean(average_accuracies))

# Convert vectors to factors
actual_values_confMatrix <- as.character(actual_values_confMatrix)
actual_values_confMatrix <- as.factor(actual_values_confMatrix)
predicted_values_confMatrix <- as.factor(predicted_values_confMatrix)

# Calculate confusion matrix
confusion_matrix <- confusionMatrix(data = actual_values_confMatrix, reference = predicted_values_confMatrix)

# Print confusion matrix
print(confusion_matrix)


