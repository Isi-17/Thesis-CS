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
N <- nrow(data)

# Initialize vector to hold accuracies
accuracies <- numeric()

# Initialize matrix to hold accuracies for each user and sequence length
user_accuracies <- matrix(nrow = N, ncol = 100)

# Loop through each sequence length
for (seq_length in 300:399) {
  # Extract features and target variable
  features <- observations[, 1:seq_length]
  target <- observations[, (seq_length + 1)]
  
  # Initialize vector to hold predictions for this sequence length
  seq_predictions <- character(length = nrow(observations))
  
  # Loop through each row in the dataset
  for (j in 1:nrow(observations)) {
    # Extract the sequence from the current row
    sequence <- as.character(observations[j, 1:seq_length])
    
    # Fit a Markov chain model to the features
    mc <- markovchainFit(data = features, method = "mle")
    
    # Get the transition matrix
    transition_matrix <- as(mc, "matrix")[[1]]@transitionMatrix
    
    # Get the last observed state in the sequence
    last_state <- as.character(observations[j, seq_length])
    
    # Find the index of the last observed state
    state_index <- which(colnames(transition_matrix) == last_state)
    
    # Extract the probabilities of transitioning to each state
    transition_probabilities <- transition_matrix[state_index, ]
    
    # Find the state with the highest probability
    next_state_index <- which.max(transition_probabilities)
    
    # Assign the next state
    next_state <- colnames(transition_matrix)[next_state_index]
    
    # Store the prediction
    seq_predictions[j] <- next_state
    
    # Calculate accuracy for this user and sequence length
    user_accuracies[j, seq_length-300] <- ifelse(seq_predictions[j] == target[j], 1, 0)
    
  }
  
  # Evaluate the accuracy for this sequence length
  accuracy <- sum(seq_predictions == target, na.rm = TRUE) / N
  
  # Store accuracy for this sequence length
  accuracies <- c(accuracies, accuracy)
}

###################### PLOT ACCURACIES ##############################################
# Plot the histogram of accuracies
hist(accuracies, main = "Distribution of Accuracies", xlab = "Accuracy")

# Evolution of accuracies
plot(seq(300, 399), accuracies, type = "l", xlab = "Length of Sequences", ylab = "Accuracy", main = "Distribution of Accuracies")


# Print final average accuracy
final_accuracy <- mean(accuracies)
print(paste("Final Average Accuracy:", final_accuracy)) # 0.6540365111

########################## ID ACCURACY #########################################
# Get the matrix of accuracies from columns [300-399]
matrix_of_accuracies <- user_accuracies[ , 300:(ncol(observations)-1)]

# Select ID (modify this parameter as needed)
target_ID <- 1000

# Find the row corresponding to the ID in the first column of the dataset
row_ID <- which(data[, 1] == target_ID)

if (length(row_ID) == 0) {
  cat("The specified ID is not found in the dataset.")
} else {
  # Select the predictions for the specified ID
  predictions <- matrix_of_accuracies[row_ID, ]
  
  # Plot the evolution of predictions
  plot(seq(300, 399), predictions, type = "l", xlab = "Model", ylab = "Prediction", 
       main = paste("Prediction Evolution for ID", target_ID))
}

########################### ACCURACY RATIO #####################################
# Calculate the accuracy ratio for each ID
accuracy_ratios <- apply(matrix_of_accuracies, 1, mean)

# Get the IDs with the highest and lowest ratios
top_accurate_ids <- order(accuracy_ratios, decreasing = TRUE)[1:5]
top_inaccurate_ids <- order(accuracy_ratios)[1:5]

# Create the plot with y-axis limits
plot(1, type = "n", xlim = c(0, 100), ylim = c(0, 1), xlab = "Model", ylab = "Prediction", main = "Prediction Evolution")

# Iterate over the top accurate IDs and plot their predictions on the graph
for (id in top_accurate_ids) {
  lines(matrix_of_accuracies[id, ], type = "o", col = "green")
}

# Iterate over the top inaccurate IDs and plot their predictions on the graph
for (id in top_inaccurate_ids) {
  lines(matrix_of_accuracies[id, ], type = "o", col = "red")
}

# Add a legend
legend("right", legend = c("Top Accurate IDs", "Top Inaccurate IDs"), col = c("green", "red"), pch = 1)

# Print the IDs that classify well
cat("IDs that classify well:\n", data[top_accurate_ids, 1], "\n")

# Print the IDs that classify poorly
cat("IDs that classify poorly:\n", data[top_inaccurate_ids, 1], "\n")


