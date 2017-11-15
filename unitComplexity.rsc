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
	count_if = 0;
	count_while = 0; 
	y = 0;
	visit(ast){
		case meth : \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl) : {
			y += 1;
			visit(meth){
				case \if(Expression condition, Statement thenBranch):{
					count_if += 1;
				}
				case \if(Expression condition, Statement thenBranch, Statement elseBranch):{
					count_if += 1;
				}
				case \while(Expression condition, Statement body):{
					count_while += 1; 
				}
				case myCase : \case(Expression expression):{
					text(meth);
					println(myCase);
					return;
				}
			}
		}
	}
	println(x);
	println(y);
}