module unitComplexity

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::Core;

import util::ValueUI;
import IO;
import Set;
import Type;

void calculateComplexity(){
	myModel = createM3FromEclipseProject(|project://smallsql0.21_src|);
	meth = methods(myModel);
	for(c <- meth){
		println(c);
		methodAST = getMethodASTEclipse(|java+method:///smallsql/database/SSStatement/setFetchDirection(int)|, model=myModel);
		text(methodAST);
		return;
	}
}