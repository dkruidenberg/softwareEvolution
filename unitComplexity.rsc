module unitComplexity

import LOC;

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::ValueUI;
import IO;
import Set;
import Type;

void holla(){
	a = createM3FromEclipseProject(|project://smallsql0.21_src|);
	uses = a.uses;
	declarations = a.declarations;
	meth = methods(a);
	
	numberOfMethods = 0;
	numberOfLines = 0;
	for(c <- meth){
		numberOfMethods += 1;
		source = readFile(c);
		result = countLOC(source);
		numberOfLines += result;
	}
	println(numberOfMethods);
	println(numberOfLines);
	
}
public set[loc] classes2(M3 m) =  {e,z | <e,z> <- m.declarations, isMethod(e)};