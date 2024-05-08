package ca.pfv.spmf.test;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.util.List;

import ca.pfv.spmf.algorithms.sequentialpatterns.prefixspan.AlgoPrefixSpan;
import ca.pfv.spmf.algorithms.sequentialpatterns.prefixspan.SequentialPattern;
import ca.pfv.spmf.algorithms.sequentialpatterns.prefixspan.SequentialPatterns;


/**
 * PrefixSpan algorithm in the source code applied to energy consumption data.
 * Copyright 2015.
 */
public class MainTestPrefixSpan_saveToMemory {

	public static void main(String [] arg) throws IOException{  
		// input file
		String inputFile = fileToPath("sequences_output.txt");
		
		// Create an instance of the algorithm 
		AlgoPrefixSpan algo = new AlgoPrefixSpan(); 
		algo.setMaximumPatternLength(400);
		
        // if you set the following parameter to true, the sequence ids of the sequences where
        // each pattern appears will be shown in the result
        algo.setShowSequenceIdentifiers(true);
		
		// execute the algorithm with minsup = 50 %
		SequentialPatterns patterns = algo.runAlgorithm(inputFile, 0.4, null);    
		System.out.println(" == PATTERNS FOUND ==");
		for(List<SequentialPattern> level : patterns.levels) {
			for(SequentialPattern pattern : level){
				System.out.println(pattern + " support : " + pattern.getAbsoluteSupport());
			}
		}
		
		// print statistics
		algo.printStatistics();
	}
	
	public static String fileToPath(String filename) throws UnsupportedEncodingException{
		URL url = MainTestPrefixSpan_saveToMemory.class.getResource(filename);
		 return java.net.URLDecoder.decode(url.getPath(),"UTF-8");
	}
}