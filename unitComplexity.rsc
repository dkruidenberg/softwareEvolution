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

//method for finding the complexity of a method
int complexityMethod(Declaration meth){
	complexity = 1; 
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
	return complexity;
}

//calculate the Complexity and the unitSize of every method of every file
list[list[int]] calculateComplexityUnitSize(loc location){
	//create ast
	ast = createAstsFromEclipseProject(location,true);
	lengths = [];
	complexities = [];
	int failed = 0;
	visit(ast){
		//method
		case meth : \method(_, _, _, _, _) : {
			loc n = meth.decl;
			try{
				//caluculate Unit Size
				source = readFile(n);
				lengths += countLOC(source);
				//calculate complexity
				complexities += complexityMethod(meth);
			}
			catch : {
				failed += 1;
			}
		}
		//construtor
		case csr: \constructor(str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):{
			complexities += complexityMethod(csr);
		}
	}
	return [complexities,lengths];
}


