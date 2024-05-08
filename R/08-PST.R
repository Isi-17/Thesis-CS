################################### PST SINGLE ROW ##############################

# Load necessary libraries
library(PST)
library(TraMineR)
library(caret)

# Read data
path <- "Files/sequence_patterns_2_6-10.csv"
data <- read.csv(path)
observations <- data[, -1]
set.seed(123)

# Row ID
row_num <- 3

# Extract the sequence
row <- observations[row_num, ]
sequence <- seqdef(row, 1:399, alphabet = LETTERS[1:21]) # Excluding ClusterDia400

# Define parameters for PST construction
L <- 14  # Maximal depth of the PST

# Build a probabilistic suffix tree
pst_model <- pstree(object = sequence, 
                    L = L, 
                    nmin = 1, 
                    ymin = NULL,
                    weighted = TRUE,  
                    with.missing = FALSE,
                    lik = TRUE)  # Compute log-likelihood

# Convert factors to characters and concatenate them into a single string with "-"
sequence_string <- paste(as.character(unlist(sequence)), collapse = "-")

# Get probabilities 
next_state_probs <- query(pst_model, context = sequence_string)

# Get the most probable next state
max_prob_index <- which.max(next_state_probs)

# Get the most probable next state
next_state <- pst_model@alphabet[max_prob_index]

# Print the predicted next state
print(paste("Predicted next state:", next_state))
print(row[length(row)])

############################ PST MODEL FOR EACH ROW ############################

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
predicted_values <- character()

# Loop through each row in the dataset
for (i in 1:nrow(data)) {
  # Extract the row
  row <- data[i, -1]  # Exclude the ID column
  
  # Predict the next state for the current row
  predicted_next_state <- predict_next_state_single_row(row)
  
  # Increment the total number of predictions
  total_predictions <- total_predictions + 1
  
  actual_value <- data[i, 400] 
  
  # Check if the prediction is correct
  if (predicted_next_state == actual_value) {  # Assuming the next state is in the last column
    num_correct_predictions <- num_correct_predictions + 1
  }
  
  # Collect actual and predicted values
  actual_values <- c(actual_values, actual_value)
  predicted_values <- c(predicted_values, predicted_next_state)
  
}

# Calculate accuracy
accuracy <- num_correct_predictions / total_predictions

# Print the accuracy
print(paste("Accuracy:", accuracy))

# Convert actual_values and predicted_values to factors
actual_values <- as.character(actual_values)
actual_values <- as.factor(actual_values)
predicted_values <- as.factor(predicted_values)

# Compute confusion matrix
conf_matrix <- confusionMatrix(data = predicted_values, reference = actual_values)

# Print confusion matrix
print(conf_matrix)
