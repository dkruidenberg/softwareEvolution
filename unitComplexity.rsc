module unitComplexity

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::Core;
import util::ValueUI;
import IO;
import Set;
import Type;

void calculateComplexity(){
	//myModel = createM3FromEclipseProject(|project://smallsql0.21_src|);
	ast = createAstsFromEclipseProject(|project://smallsql0.21_src|,true);
	x = 0;
	visit(ast){
		case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl) : {
			x+=1;
		}
	}
	println(x);
}