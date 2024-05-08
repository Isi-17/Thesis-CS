# Load required library
library(TraMineR)
library(PST)

path <- "Files/sequence_patterns_2_6-10.csv"
data <- read.csv(path)

# We need to adjust labels and codes according to the data
seqstatl(data[, 2:401])

# Create the alphabet and labels
cluster_alphabet <- LETTERS[1:21]
cluster_scodes <- LETTERS[1:21]

# Create the sequence
df.seq <- seqdef(data, 2:401, alphabet = cluster_alphabet, states = cluster_scodes, xtstep = 1)

# Sequence plot sorted by ID
seqIplot(df.seq, with.legend = "right")

# 10 Most repeated sequences (interesting for analysis)
seqfplot(df.seq, with.legend = "right", border = NA)

# Most repeated sequences each day (interesting for later comparison with time) [it's the first image but sorted by type]
seqdplot(df.seq, with.legend = "right", border = NA)

# Entropy index (uncertainty regarding the sequence)
seqHtplot(df.seq)

# Modal state (most common cluster each day and percentage)
seqmsplot(df.seq, with.legend = "right", border = NA)
