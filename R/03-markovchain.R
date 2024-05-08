################################# MLE (Maximum Likelihood Estimation) ###########################################

# Load necessary libraries
library(markovchain)
library(caret)
library(igraph)

# Read data
# Custom directory
data_path <- "Files/sequence_patterns_2_6-10.csv"

data <- read.csv(data_path)

observations <- data[, -1]  # Remove ID column
set.seed(123)
target_variable <- names(observations)[ncol(observations)]

################### Single Sequence #######################
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
accuracy <- as.numeric(next_state == actual_value)
print(accuracy) # 1

# Visualize transition graph
graph <- graph_from_adjacency_matrix(transition_matrix, mode = "directed", weighted = TRUE)
E(graph)$label <- round(E(graph)$weight, 2)
plot(graph, layout = layout.circle, vertex.size = 30, vertex.label.cex = 1.5, edge.label.cex = 1.5, edge.label.color = "blue")

################### All Sequences #######################

# Initialize vector to hold predictions
predictions <- character(length = nrow(observations))

# Loop through each row in the dataset
for (i in 1:nrow(observations)) {
  # Extract the sequence from the current row
  sequence <- as.character(observations[i, 1:399])
  
  # Fit a Markov chain model to the sequence
  model <- markovchainFit(data = sequence, method = "mle")
  
  # Get the transition matrix
  transition_matrix <- as(model, "matrix")[[1]]@transitionMatrix
  
  # Get the last observed state in the sequence
  last_state <- sequence[length(sequence)]
  
  # Find the index of the last observed state in the transition matrix
  state_index <- which(colnames(transition_matrix) == last_state)
  
  # Extract transition probabilities for the last state
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

# Evaluate accuracy (assuming actual values are available)
actual_values <- data[, target_variable]
accuracy <- sum(predictions == actual_values, na.rm = TRUE) / length(actual_values)
print(accuracy)

# Create confusion matrix
actual_values <- as.factor(actual_values)
predictions <- as.factor(predictions)
confusion_matrix <- confusionMatrix(data = predictions, reference = actual_values)
print(confusion_matrix)


#############################################################################################
############################# SEQUENCES #####################################################

################### Single Sequence #######################
# Extract one sequence (assuming it's the first row)
num_days <- 5
row_number <- 1
sequence <- as.character(observations[row_number, 1:(400 - num_days)])

# Fit a Markov chain model to the sequence
model <- markovchainFit(data = sequence, method = "mle")

# Get the last observed state in the sequence
last_state <- sequence[length(sequence)]

# Get the Markov chain object from the list
markovchain_obj <- model[[1]]

# Predict the next ClusterDay using markovchainSequence
next_states <- markovchainSequence(n = num_days, markovchain = markovchain_obj, t0 = last_state, include.t0 = FALSE)

# Print the prediction
print(next_states)

# Evaluate accuracy (assuming actual value is available)
actual_values <- observations[row_number, (401 - num_days):400]
print(actual_values)

accuracy <- sum(next_states == actual_values) / num_days
print(accuracy)

################################# All Sequences ################################

# Define the number of days to predict
num_days <- 60

# Initialize vectors and matrices
accuracies <- numeric(nrow(observations))
accuracies_col <- matrix(NA, nrow = nrow(observations), ncol = num_days)
predicted_values_confMatrix <- character()
actual_values_confMatrix <- character()

# Loop through each row in the dataset
for (i in 1:nrow(observations)) {
  # Extract the sequence (excluding the last num_days days)
  sequence <- as.character(observations[i, 1:(400 - num_days)])
  
  # Fit a Markov chain model to the sequence
  model <- markovchainFit(data = sequence, method = "mle")
  
  # Get the last observed state in the sequence
  last_state <- sequence[length(sequence)]
  
  # Get the Markov chain object from the list
  markovchain_obj <- model[[1]]
  
  # Predict the next num_days ClusterDays using markovchainSequence
  next_states <- markovchainSequence(n = num_days, markovchain = markovchain_obj, t0 = last_state, include.t0 = FALSE)
  
  # Calculate accuracy for each day in the predicted sequence
  actual_values <- observations[i, (401 - num_days):400]
  for (j in 1:num_days) {
    accuracies_col[i, j] <- sum(next_states[j] == actual_values[j]) / 1
  }
  
  # Calculate accuracy for this row
  actual_values <- observations[i, (401 - num_days):400]
  accuracy <- sum(next_states == actual_values) / num_days
  
  # Store accuracy for this row
  accuracies[i] <- accuracy
  
  # Store predicted and actual values for this row
  actual_values_confMatrix <- c(actual_values_confMatrix, observations[i, (401 - num_days):400])
  predicted_values_confMatrix <- c(predicted_values_confMatrix, next_states)
}

# For a 70 days sequence.
# Print accuracies for each row
print(accuracies)
print(max(accuracies))
print(min(accuracies))
print(mean(accuracies))

print(accuracies_col)
# Compute the average accuracy for each day predicted across all rows
average_accuracies <- colMeans(accuracies_col, na.rm = TRUE)

# Print the average accuracies
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



