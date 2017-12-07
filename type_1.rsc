module type_1

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import count_loc;
import String;
import List;
import Set;
import Map;
import IO;
import Type;
import Node;


void type_1_statistics(loc location){
	countDuplication(location);
}

//main function
void countDuplication(loc location){
	ast = createAstFromFile(|project://SoftwareEvolution/src/test_suite/type1test.java|, true);
	list[node] node_list = [];
	int max_depth = 5;
	visit(ast){
		case node n:{
			if(goodNode(n)){
				node_list += n;
			}
		}
	}
	list[node] unset_list = [unsetRec(n) | node n <- node_list];
	//println(unset_list); 
	map[node, set[int]] mapping = toMap(zip(unset_list, index(unset_list)));
	
	iprint(mapping);
}

bool goodNode(node n){
	if(Declaration d := n){
		return true;
	}
	if(Expression e := n){
		return true;
	}
	if(Statement s := n){
		return true;
	}
	
	return false;
}









