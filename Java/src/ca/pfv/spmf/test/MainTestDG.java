package ca.pfv.spmf.test;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URL;

import ca.pfv.spmf.algorithms.sequenceprediction.ipredict.database.Item;
import ca.pfv.spmf.algorithms.sequenceprediction.ipredict.database.Sequence;
import ca.pfv.spmf.algorithms.sequenceprediction.ipredict.database.SequenceDatabase;
import ca.pfv.spmf.algorithms.sequenceprediction.ipredict.database.SequenceStatsGenerator;
import ca.pfv.spmf.algorithms.sequenceprediction.ipredict.predictor.DG.DGPredictor;

/**
 * DG sequence prediction model in the source code applied to energy consumption data.
 * Copyright 2015.
 */
public class MainTestDG {

	public static void main(String [] arg) throws IOException, ClassNotFoundException{
		
		// Load the set of training sequences
		String inputPath = fileToPath("sequences_output_without_last_before_end.txt");  
		System.out.println(inputPath);
		SequenceDatabase trainingSet = new SequenceDatabase();
		trainingSet.loadFileSPMFFormat(inputPath, Integer.MAX_VALUE, 0, Integer.MAX_VALUE);

		String inputPath2 = fileToPath("sequences_output.txt");  
		SequenceDatabase trainingSet2 = new SequenceDatabase();
		trainingSet2.loadFileSPMFFormat(inputPath2, Integer.MAX_VALUE, 0, Integer.MAX_VALUE);
		
		// Print the training sequences to the console
		System.out.println("--- Training sequences ---");
		for(Sequence sequence : trainingSet.getSequences()) {
			System.out.println(sequence.toString());
		}
		System.out.println();
		
		// Print statistics about the training sequences
		SequenceStatsGenerator.prinStats(trainingSet, " training sequences ");
		
		// The following line is to set optional parameters for the prediction model. 
		String optionalParameters = "lookahead:2";
		
		// Train the prediction model
		DGPredictor predictionModel = new DGPredictor("DG", optionalParameters);
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
						
			// Check if the predicted next number matches the actual next number
			if (predictedNextNumber.equals(actualNextNumber)) {
				correctPredictions++;
			}
			
			totalSequences++;
		}

		// Calculate accuracy
		double accuracy = (double) correctPredictions / totalSequences * 100;
		System.out.println("Accuracy: " + accuracy + "%");
		
//		// ======================== OPTIONAL ==============================================
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
	
	public static String fileToPath(String filename) throws UnsupportedEncodingException{
		URL url = MainTestDG.class.getResource(filename);
		 return java.net.URLDecoder.decode(url.getPath(),"UTF-8");
	}
}
