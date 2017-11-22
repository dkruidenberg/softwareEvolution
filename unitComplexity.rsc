module unitComplexity
import unitSize;
import count_loc;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::Core;
import util::ValueUI;
import IO;
import Set;
import Type;
import lang::java::\syntax::Java15;
import Exception;
import List;


list[list[int]] calculateComplexityUnitSize(loc location){
	ast = createAstsFromEclipseProject(location,true);
	lengths = [];
	complexities = [];
	int counter = 0;
	visit(ast){
		case meth : \method(_, _, _, _, _) : {
			complexity = 1;
			loc n = meth.decl;
			try{
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
			        case \conditional(Expression expression, Expression thenBranch, Expression elseBranch): complexity += 1;
			        case \infix(_,"&&",_): complexity += 1;
			        case \infix(_,"||",_): complexity += 1;
				};
				complexities += complexity;
			}
			catch : {
				counter += 1;
			}
		}
	}
	println("Methods skipped <counter>");
	println(min(lengths));
	println(max(lengths));
	return [complexities,lengths];
}


