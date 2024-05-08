package ca.pfv.spmf.test;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.util.Map;
import java.util.Map.Entry;

import ca.pfv.spmf.algorithms.sequenceprediction.ipredict.database.Item;
import ca.pfv.spmf.algorithms.sequenceprediction.ipredict.database.Sequence;
import ca.pfv.spmf.algorithms.sequenceprediction.ipredict.database.SequenceDatabase;
import ca.pfv.spmf.algorithms.sequenceprediction.ipredict.database.SequenceStatsGenerator;
import ca.pfv.spmf.algorithms.sequenceprediction.ipredict.predictor.CPT.CPT.CPTPredictor;

/**
 * CPT sequence prediction model in the source code applied to energy consumption data.
 * Copyright 2015.
 */
public class MainTestCPTCorMatrix {

	public static void main(String [] arg) throws IOException, ClassNotFoundException{
		
		// Load the set of training sequences
		String inputPath = fileToPath("sequences_output_without_last_before_end.txt");  
		System.out.println(inputPath);
		SequenceDatabase trainingSet = new SequenceDatabase();
		trainingSet.loadFileSPMFFormat(inputPath, Integer.MAX_VALUE, 0, Integer.MAX_VALUE);

		String inputPath2 = fileToPath("sequences_output.txt");  
		SequenceDatabase trainingSet2 = new SequenceDatabase();
		trainingSet2.loadFileSPMFFormat(inputPath2, Integer.MAX_VALUE, 0, Integer.MAX_VALUE);
		
		String corMatrixPath = "C:/Users/isidr/OneDrive/Escritorio/TFG/Datos/TFG/TFG-Informatica/correlation_matrix.csv";
        double[][] corMatrix = loadCorrelationMatrix(corMatrixPath);
		double threshold = 0.9;
		// Print the training sequences to the console

		for(Sequence sequence : trainingSet.getSequences()) {
			System.out.println(sequence.toString());
		}
		System.out.println();
		
		// Print statistics about the training sequences
		SequenceStatsGenerator.prinStats(trainingSet, " training sequences ");
		
		// The following line is to set optional parameters for the prediction model. 
		// We can activate the recursive divider strategy to obtain more noise
		// tolerant predictions (see paper). We can also use a splitting method
		// to reduce the model size (see explanation below).
		String optionalParameters = "splitLength:6 splitMethod:0 recursiveDividerMin:1 recursiveDividerMax:5";
		
		// An explanation about "splitMethod":
		// - If we set splitMethod to 0, then each sequence will be completely used
		//   for training. 
		// - If we set splitMethod to 1, then only the last k (here k = 6) symbols of
		// each sequence will be used for training. This will result in a smaller model
		// and faster prediction, but may decrease accuracy.
		// - If we set splitMethod to 2, then each sequence will be divided in several
		//   subsequences of length k or less to be used for training. 
		
		// Train the prediction model using the training set
		CPTPredictor predictionModel = new CPTPredictor("CPT", optionalParameters);
		predictionModel.Train(trainingSet.getSequences());
		
		// Now we will use the prediction model that we have trained to predict the last element for each sequence.
		// Loop over each sequence in the training set
		int correctPredictions = 0;
		int totalSequences = 0;

		for (Sequence sequence : trainingSet2.getSequences()) {

			// Get the sequence without the last element
			Sequence sequenceWithoutLast = new Sequence(0);
			for (int i = 0; i < sequence.size() - 1; i++) {
				sequenceWithoutLast.addItem(sequence.get(i));
			}
					
			// Predict the next number using the trained 
			Sequence predictedNext = predictionModel.Predict(sequenceWithoutLast);
			System.out.println("Predicted next: " + predictedNext);
			Item predictedNextNumber = predictedNext.get(0);

			// Get the last element of the sequence
			Item actualNextNumber = sequence.get(sequence.size()-1);
			System.out.println("Actual next: " + actualNextNumber);
					
			double correlationValue = corMatrix[actualNextNumber.val][predictedNextNumber.val];
			if (!predictedNextNumber.equals(actualNextNumber) && correlationValue >= threshold) {
				predictedNextNumber = actualNextNumber;
			}

			// Check if the predicted next number matches the actual next number
			if (predictedNextNumber.equals(actualNextNumber)) {
				correctPredictions++;
			} 
			totalSequences++;
		}

		// Calculate accuracy
		double accuracy = (double) correctPredictions / totalSequences * 100;
		System.out.println("Accuracy: " + accuracy + "%");

		
		// If we want to see why that prediction was made, we can also 
		// ask to see the count table of the prediction algorithm. The
		// count table is a structure that stores the score for each symbols
		// for the last prediction that was made.  The symbol with the highest
		// score was the prediction.
		// System.out.println();
		// System.out.println("To make the prediction, the scores were calculated as follows:");
		//  Map<Integer, Float> countTable = predictionModel.getCountTable();
		//  for(Entry<Integer,Float> entry : countTable.entrySet()){
		// 	 System.out.println("symbol"  + entry.getKey() + "\t score: " + entry.getValue());
		//  }
		 
		// ======================== OPTIONAL ==============================================
//		// *******  IF we want to save the trained model to a file ******* ///
//		ObjectOutputStream stream = new ObjectOutputStream(new FileOutputStream("model.ser"));
//		stream.writeObject(predictionModel);
//		stream.close();
//		
//		// ****** Then, we can also load the trained model from the file ****** ///
//		ObjectInputStream stream2 = new ObjectInputStream(new FileInputStream("model.ser"));
//		Predictor predictionModel2 = (Predictor) stream2.readObject();
//		stream.close();
//		// and then make a prediction
//		Sequence thePrediction2 = predictionModel2.Predict(sequence);
//		System.out.println("For the sequence <(1),(4)>, the prediction for the next symbol is: +" + thePrediction2);
	}
	
	private static double[][] loadCorrelationMatrix(String filePath) throws IOException {
		BufferedReader reader = new BufferedReader(new FileReader(filePath));
		String line;
	
		// Skip the first line (header)
		reader.readLine();
	
		// Count the number of rows and columns
		int numRows = 0;
		int numCols = 0;
		while ((line = reader.readLine()) != null) {
			numRows++;
			String[] values = line.split(",");
			numCols = values.length - 1; // Exclude the first column
		}
		reader.close();
	
		double[][] matrix = new double[numRows][numCols];
	
		// Reset the reader to read from the beginning of the file
		reader = new BufferedReader(new FileReader(filePath));
		reader.readLine(); // Skip the first line (header)
	
		int row = 0;
		while ((line = reader.readLine()) != null) {
			String[] values = line.split(",");
			for (int col = 1; col < values.length; col++) { // Start from index 1 to skip the first column
				matrix[row][col - 1] = Double.parseDouble(values[col]);
			}
			row++;
		}
		reader.close();
	
		return matrix;
	}
	

	public static String fileToPath(String filename) throws UnsupportedEncodingException{
		URL url = MainTestCPT.class.getResource(filename);
		 return java.net.URLDecoder.decode(url.getPath(),"UTF-8");
	}
}
