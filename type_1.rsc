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
import util::ValueUI;


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
	for(n <- node_list){
		iprint(n);
		locatie = n.src;
		println(locatie);
		println(readFile(locatie));
	}
	text(mapping);
}
public loc getLocationOfNode(node subTree) {
	loc location = |project://pipo|;

	if (Declaration d := subTree) {
		if (d.src?) {
			location = d.src;
		}
	} else if (Expression e := subTree) {
		if (e.src?) {
			location = e.src;
		}
	} else if (Statement s := subTree) {
		if (s.src?) {
			location = s.src;
		}
	}

	return location;
}


bool goodNode(node n){
	if(Declaration d := n){
		return true;
	}
	if(Expression e := n){
		return false;
	}
	if(Statement s := n){
		return true;
	}
	
	return false;
}

int countDepth(node n){
	int depth = 0;
	visit(n){
		case node d:{
			depth += 1; 
		}
	}
	return depth;
}









