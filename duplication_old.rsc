module duplication_old

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::Core;
import util::ValueUI;
import IO;
import Set;
import Type;
import lang::java::\syntax::Java15;
import count_loc;
import String;
import List;
import Type;
import Set;

int countDuplication(loc location){
	//Get all the methods of the project
	model = createM3FromEclipseProject(location);
	meth = toList(methods(model));
	//keep track of duplicates
	int num_duplicates = 0;
	int duplicate_lines = 0;
	//used for indicating process
	int allMethSize = size(meth);
	real progress = 0.0;
	real step = 1.0 / allMethSize * 100;
	
	int counter_x = 0;
	//walk through each method
	for(x <- meth){
		counter_x += 1;
		//progress indicator
		progress += step;
		println(progress);
		//read and clean method
		source1 = readFile(x);
		sourceMethod = split("\n",cleanCode(source1));
		int sourceSize = size(sourceMethod);
		//only check for methods with size > 6
		if(sourceSize >= 6){
			//check method with everu other method strating from the current method (counter_x)
			for(y <- drop(counter_x,meth)){
				//get source of target method
				source2 = readFile(y);
				//get the method and trim
				targetMethod = split("\n",cleanCode(source2));
				int targetSize = size(targetMethod);
				//only check for methods with size > 6
				if(targetSize >= 6){
					int sourceLineCounter = 0;
					int skipLines = 0;
					//walk through every line of the source method
					for(line <- sourceMethod){
						//if statement is used to prevent that a block of 7 duplicate lines is counted as 2
						if(skipLines == 0){
							//get index of the first line of the duplication
							int index = indexOf(targetMethod, line);
							if((index) != -1 && (targetSize - index >= 6)){
								int indexSource = sourceLineCounter;
								int counter = 0;
								//walk through line until they don't match anymore
								while(sourceMethod[indexSource] == targetMethod[index]){
									counter += 1;
									indexSource += 1;
									index +=1;
									//edge case
									if(indexSource >= sourceSize || index >= targetSize){
										break;
									}
								}
								//if the duplicate is more then 6 lines
								if(counter >=6){
									skipLines = counter;
									num_duplicates += 1;
									duplicate_lines += counter;
								}
							}
						}
						else{
							skipLines -= 1;
						}
						sourceLineCounter += 1;
						//don't count the 5 remaining lines
						if(sourceSize - sourceLineCounter < 6){
							break;
						}
					}
				}
			}
		}
	}
	//println(num_duplicates);
	//println(duplicate_lines);
	return duplicate_lines;
}

// Function for printing the duplicates to check if they were the same
void printSection(list[str] myList, int startAt, int endAt){
	printString = "";
	for(n <- slice(myList, startAt, (endAt - startAt))){
		printString += n + "\n";
	}
	println(printString);
}