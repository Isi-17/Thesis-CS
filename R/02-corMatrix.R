library(gplots)

# Define the path to the CSV file in the "Files" folder
path <- "Files/ireland_centroids.csv"

# Read the CSV file
centroids_data <- read.csv(path, sep=';', row.names=1, header=TRUE, dec=',')

# Transpose the data frame
centroids_data <- t(centroids_data)

# Calculate the correlation matrix
correlation_matrix <- cor(centroids_data)

# Rename row and column names with cluster names (letters A to U)
rownames(correlation_matrix) <- LETTERS[1:21]
colnames(correlation_matrix) <- LETTERS[1:21]

# Plot the heatmap
heatmap.2(correlation_matrix, 
          trace="none", 
          col=bluered(100), 
          Rowv=NA, 
          Colv=NA, 
          dendrogram="none", 
          cellnote=format(correlation_matrix, digits=2), 
          notecol="black", 
          notecex=0.7)

# Save the correlation matrix to a CSV file in the "Files" folder
write.csv(correlation_matrix, "Files/correlation_matrix.csv", row.names = TRUE)
