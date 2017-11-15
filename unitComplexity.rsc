module unitComplexity

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::ValueUI;
import IO;
import Set;
import Type;


void calculateComplexity(loc x){
	a = createM3FromEclipseProject(x);
	text(a);

}