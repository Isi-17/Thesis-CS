# Load necessary package
library(HMM)

# Baum-Welch algorithm to fit the HMM model
# Objective: Learn transition probabilities between states and emission probabilities associated with each state

# Read data
data_path <- "Files/sequence_patterns_2_6-10.csv"
data <- read.csv(data_path)
set.seed(123)

# Define cluster alphabet
cluster_alphabet <- LETTERS[1:21]

# Exclude the ID column
observations <- data[, -1]  

############### Markov Model for a single sequence from the beginning ######################
# Number of days to consider in the sequence
num_days <- 399
num_ID <- 3 # custom
sequence <- as.vector(as.character(observations[num_ID, 1:num_days]))

# Create an HMM model
hmm_model <- initHMM(States = cluster_alphabet, Symbols = cluster_alphabet)

# HMM model using Baum-Welch
trained_model <- baumWelch(hmm_model, observation = sequence, maxIterations = 1000)

# Cluster of the last day
last_state <- sequence[length(sequence)]

# Probabilities of transitioning to cluster X from last_state
emission_probabilities <- trained_model$hmm$emissionProbs[last_state, ]

# Choose the one with the highest probability, it will be the next in the sequence
new_observation <- sample(names(emission_probabilities), size = 1, prob = emission_probabilities)

# Print actual observations for comparison
print(observations[num_ID, 1:num_days])
print(sequence)
print(emission_probabilities)
print(new_observation)
print(observations[num_ID, num_days+1])


###### Markov Model for all sequences for a number of days from the beginning ########
# Number of days to consider in the sequence
num_days <- 399

hmm_model <- initHMM(States = cluster_alphabet, Symbols = cluster_alphabet)

# Store predictions for each ID in this variable
new_observations <- character(nrow(observations))

for (i in 1:nrow(observations)) {
  sequence <- as.vector(as.character(observations[i, 1:num_days]))
  
  # HMM model using Baum-Welch
  trained_model <- baumWelch(hmm_model, observation = sequence, maxIterations = 1000)
  
  # Cluster of the last day
  last_state <- sequence[length(sequence)]
  
  # Probabilities of transitioning to cluster X from last_state
  emission_probabilities <- trained_model$hmm$emissionProbs[last_state, ]
  
  # Choose the one with the highest probability, it will be the next in the sequence
  new_observations[i] <- sample(cluster_alphabet, size = 1, prob = emission_probabilities)
}

cat("Next consumption by ID:\n", paste(new_observations, collapse = " "), "\n")

# Compare predictions with actual values
actual_observations <- observations[, num_days + 1]
matches <- new_observations == actual_observations

# Calculate accuracy
accuracy <- sum(matches) / length(matches)

cat("Accuracy for all sequences:", accuracy, "\n")
