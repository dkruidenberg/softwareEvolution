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


void countDuplication(){
	//Get all the methods of the project
	loc project = |project://smallsql0.21_src|;
	model = createM3FromEclipseProject(project);
	meth = methods(model);
	int num_duplicates = 0;
	
	//walk through each method
	for(x <- meth){
		source1 = readFile(x);
		sourceMethod = split("\n",cleanCode(source1));
		//only check for methods with size > 6
		if(size(sourceMethod)>6){
			for(y <- meth){
				//get source of target method
				source2 = readFile(y);
				if(source1 != source2){
					//split the methods and trim 
					targetMethod = split("\n",cleanCode(source2));
					counter = 0;
					//only check for methods with size > 6
					if(size(targetMethod) > 6){
						for(line <- sourceMethod){
							if(line in targetMethod){
								println(line);
							}
						}
					}
				}
			}
		}
	}
}