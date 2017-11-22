module unitSize

import count_loc;

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::ValueUI;
import IO;
import Set;
import Type;

void calculateSize(loc x){
	myModel = createM3FromEclipseProject(x);
	meth = methods(myModel);
	
	numberOfMethods = 0;
	numberOfLines = 0;
	for(c <- meth){;
		numberOfMethods += 1;
		source = readFile(c);
		result = countLOC(source);
		numberOfLines += result;
	}
	
}