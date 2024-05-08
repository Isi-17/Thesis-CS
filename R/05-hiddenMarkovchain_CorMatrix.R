# Load necessary package
library(HMM)

# Baum-Welch algorithm to fit the HMM model
# Objective: Learn transition probabilities between states and emission probabilities associated with each state

# Read data
data_path <- "Files/sequence_patterns_2_6-10.csv"
data <- read.csv(data_path)

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

cluster_alphabet <- LETTERS[1:21]

# Exclude the ID column
observations <- data[, -1]  

############# All sequences for a number of days from the beginning ################
# Number of days to consider in the sequence
num_days <- 399

hmm_model <- initHMM(States = cluster_alphabet, Symbols = cluster_alphabet)

# Initialize variables for accuracy calculation
num_correct_predictions <- 0
total_predictions <- 0

# Loop through each row in the dataset
for (i in 1:nrow(observations)) {
  sequence <- as.vector(as.character(observations[i, 1:num_days]))
  
  # HMM model using Baum-Welch
  trained_model <- baumWelch(hmm_model, observation = sequence, maxIterations = 1000)
  
  # Cluster of the last day
  last_state <- sequence[length(sequence)]
  
  # Probabilities of transitioning to cluster X from last_state
  emission_probabilities <- trained_model$hmm$emissionProbs[last_state, ]
  
  # Choose the one with the highest probability, it will be the next in the sequence
  predicted_next_state <- sample(cluster_alphabet, size = 1, prob = emission_probabilities)
  
  # Apply correction based on correlation
  corrected_next_state <- correct_predictions_with_correlation(predicted_next_state, observations[i, num_days + 1], cor_matrix, correlation_threshold)
  
  # Increment the total number of predictions
  total_predictions <- total_predictions + 1
  
  # Check if the prediction is correct
  if (corrected_next_state == observations[i, num_days + 1]) {
    num_correct_predictions <- num_correct_predictions + 1
  }
}

# Calculate accuracy
accuracy <- num_correct_predictions / total_predictions

# Print the accuracy
cat("Accuracy for all sequences with correction:", accuracy, "\n")

