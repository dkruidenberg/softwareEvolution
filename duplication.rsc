module duplication

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


void countDuplication(){
	//Get all the methods of the project
	loc project = |project://smallsql0.21_src|;
	model = createM3FromEclipseProject(project);
	meth = toList(methods(model));
	int num_duplicates = 0;
	int duplicate_lines = 0;
	tmp = split(meth);
	first_halve = tmp[0];
	second_halve = tmp[1];
	int allMethSize = size(first_halve);
	real progress = 0.0;
	real step = 1.0 / allMethSize * 100;
	int counter_x = 0;
	int counter_y = 0;

	//walk through each method
	for(x <- meth){
		counter_x += 1;
		progress += step;
		println(progress);
		source1 = readFile(x);
		sourceMethod = split("\n",cleanCode(source1));
		int sourceSize = size(sourceMethod);
		//only check for methods with size > 6
		if(sourceSize >= 6){
			for(y <- meth){
				counter_y += 1;
				//get source of target method
				source2 = readFile(y);
				if(source1 != source2){
					//split the methods and trim 
					targetMethod = split("\n",cleanCode(source2));
					//only check for methods with size > 6
					int targetSize = size(targetMethod);
					if(targetSize >= 6){
						int sourceLineCounter = 0;
						int skipLines = 0;
						for(line <- sourceMethod){
							
							if(skipLines == 0){
								int index = indexOf(targetMethod, line);
								if((index) != -1 && (targetSize - index >= 6)){
									int indexSource = sourceLineCounter;
									int counter = 0;
									int tmpBegin = sourceLineCounter;
									int tmpBegin2 = index;
									while(sourceMethod[indexSource] == targetMethod[index]){
										counter += 1;
										indexSource += 1;
										index +=1;
										if(indexSource >= sourceSize || index >= targetSize){
											break;
										}
									}
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
							if(sourceSize - sourceLineCounter < 6){
								break;
							}
						}
					}
				}
				if(counter_x == counter_y){
					counter_y = 0;
					break;
				}
			}
		}
	}
	println(num_duplicates);
	println(duplicate_lines);
}

// Function for printing the duplicates to check if they were the same
void printSection(list[str] myList, int startAt, int endAt){
	printString = "";
	for(n <- slice(myList, startAt, (endAt - startAt))){
		printString += n + "\n";
	}
	println(printString);
}