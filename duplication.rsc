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
	
	//walk through each method
	for(x <- meth){
		for(y <- meth){
			//get source of methods
			source1 = readFile(x);
			source2 = readFile(y);
			if(source1 != source2){
				//split the methods and trim 
				splitted1 = split("\n",cleanCode(source1));
				splitted1 = [trim(m)|m<-splitted1];
				splitted2 = split("\n",cleanCode(source2));
				splitted2 = [trim(m)|m<-splitted2];
				counter = 0;
				//only check for methods with size > 6
				if(size(splitted1)>6){
					for(z <- splitted1){
						if(z in splitted2){
							println(z);
						}
					}
				}
			}
		}
	}
}