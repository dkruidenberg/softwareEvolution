module unitComplexity

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::Core;
import util::ValueUI;
import IO;
import Set;
import Type;
import lang::java::\syntax::Java15;
import count_loc;

list[list[int]] calculateComplexityUnitSize(){
	ast = createAstsFromEclipseProject(|project://smallsql0.21_src|,true);
	lengths = [];
	complexities = [];
	visit(ast){
		case meth : \method(_, _, _, _, _) : {
			complexity = 1;
			loc n = meth.decl;
			source = readFile(n);
			lengths += countLOC(source);
			visit(meth){
				case \if(Expression condition, Statement thenBranch) : complexity += 1;
		        case \if(Expression condition, Statement thenBranch, Statement elseBranch) : complexity += 1;
		        case \case(Expression expression) : complexity += 1;
		        case \do(Statement body, Expression condition) : complexity += 1;
		        case \while(Expression condition, Statement body) : complexity += 1;
		        case \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body) : complexity += 1;
		        case \for(list[Expression] initializers, list[Expression] updaters, Statement body) : complexity += 1;
		        case \foreach(Declaration parameter, Expression collection, Statement body) : complexity += 1;
		        case \catch(Declaration exception, Statement body): complexity += 1;
		        case \switch(Expression expression, list[Statement] statements): complexity += 1;
			}
			complexities += complexity;
			
		}
	}
	return [complexities,lengths];
}

