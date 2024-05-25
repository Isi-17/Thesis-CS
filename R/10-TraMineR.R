########################################## EJEMPLO PARA ID #####################################
# Load required libraries
library(TraMineR)
library(caret)

# Read data
path <- "Files/sequence_patterns_2_6-10.csv"
data <- read.csv(path)
# These users are removed because their last state has no transition probability as it has not appeared before in the sequence.
data <- data[-279, ]
data <- data[-488, ]
set.seed(123)

# Define the alphabet and state labels
cluster_alphabet <- LETTERS[1:21]
cluster_scodes <- LETTERS[1:21]

# Row ID
num_row <- 3

# Create the sequence
train_seq <- seqdef(data[num_row, 2:(ncol(data)-2)], alphabet = cluster_alphabet, states = cluster_scodes, xtstep = 1)

# Calculate transition probabilities
train_transition_matrix <- seqtrate(train_seq)

sequence <- data[num_row, 2:ncol(data)]
current_cluster <- as.character(sequence[, ncol(sequence)])
last_cluster <- as.character(sequence[, ncol(sequence)-1])
last_cluster_index <- match(last_cluster, cluster_alphabet)
probabilities <- train_transition_matrix[last_cluster_index,]
next_cluster <- sample(cluster_alphabet, 1, prob = probabilities)

print(train_transition_matrix)
print(probabilities)
print(next_cluster)
print(current_cluster)


################ MODEL TRAINED FOR EACH ROW ####################################

# Function to predict next cluster with the trained model
predict_next_cluster <- function(current_cluster, transition_matrix) {
  probabilities <- transition_matrix[current_cluster, ]
  next_cluster <- sample(cluster_alphabet, 1, prob = probabilities)
  return(next_cluster)
}

# Function to train a model for a single row
train_model_for_row <- function(row) {
  # Create the sequence for the row
  train_seq <- seqdef(row, alphabet = cluster_alphabet, states = cluster_scodes, xtstep = 1)
  
  # Calculate transition probabilities
  train_transition_matrix <- seqtrate(train_seq)
  
  # Return the trained model
  return(list(transition_matrix = train_transition_matrix, predict_function = predict_next_cluster))
}

# Function to predict for a single row using its model
predict_for_row <- function(row, model) {
  current_cluster <- as.character(row[length(row)])
  current_cluster_index <- match(current_cluster, cluster_alphabet)
  next_cluster <- model$predict_function(current_cluster_index, model$transition_matrix)
  return(next_cluster)
}

# Initialize variables for accuracy calculation
num_correct_predictions <- 0
total_predictions <- 0
actual_values <- character()
predicted_values <- character()

# Loop through each row in the dataset
for (i in 1:nrow(data)) {
  # Extract the row
  row <- data[i, 2:(ncol(data)-1)]
  
  # Train a model for the current row
  model <- train_model_for_row(row)
  
  # Predict the next cluster for the current row
  predicted_next_cluster <- predict_for_row(row, model)
  
  # Increment the total number of predictions
  total_predictions <- total_predictions + 1
  
  actual_value <- data[i, ncol(data)-1]
  
  # Check if the prediction is correct
  if (predicted_next_cluster == actual_value) {
    num_correct_predictions <- num_correct_predictions + 1
  }
  
  # Collect actual and predicted values
  actual_values <- c(actual_values, actual_value)
  predicted_values <- c(predicted_values, predicted_next_cluster)
  
}

# Calculate accuracy
accuracy <- num_correct_predictions / total_predictions

# Print the accuracy
print(paste("Accuracy of the model for each row:", accuracy))

# Convert actual_values and predicted_values to factors
actual_values <- as.character(actual_values)

all_levels <- union(levels(factor(actual_values)), levels(factor(predicted_values)))

actual_values <- factor(actual_values, levels = all_levels)
predicted_values <- factor(predicted_values, levels = all_levels)

# Compute confusion matrix
conf_matrix <- confusionMatrix(data = predicted_values, reference = actual_values)

# Print confusion matrix
print(conf_matrix)

