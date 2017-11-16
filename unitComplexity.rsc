module unitComplexity

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::Core;
import util::ValueUI;
import IO;
import Set;
import Type;
import lang::java::\syntax::Java15;

int calculateComplexity(){
	//myModel = createM3FromEclipseProject(|project://smallsql0.21_src|);
	ast = createAstsFromEclipseProject(|project://smallsql0.21_src|,true);
	result = 1;
	visit(ast){
		case meth : \method(_, _, _, _, _) : {
			loc n = meth.decl;
			visit(meth){
				case \if(Expression condition, Statement thenBranch) : result += 1;
		        case \if(Expression condition, Statement thenBranch, Statement elseBranch) : result += 1;
		        case \case(Expression expression) : result += 1;
		        case \do(Statement body, Expression condition) : result += 1;
		        case \while(Expression condition, Statement body) : result += 1;
		        case \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body) : result += 1;
		        case \for(list[Expression] initializers, list[Expression] updaters, Statement body) : result += 1;
		        case \foreach(Declaration parameter, Expression collection, Statement body) : result += 1;
		        case \catch(Declaration exception, Statement body): result += 1;
		        case \switch(Expression expression, list[Statement] statements): result += 1;
			}
			return 0;
		}
	}
	println(result);
	return result;
}



