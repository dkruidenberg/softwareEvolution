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
	map[node, loc] nodeToLoc = ();
	map[loc, node] locToNode = ();
	visit(ast){
		case node n:{
			if(goodNode(n)){
				loc l = getNodeLoc(n);
				n = unsetRec(n);
				if(l != |unknown:///|){
					nodeToLoc[n] = l;
					node_list += n;
				}
			}
		}
	}
	map[node, set[int]] mapping = toMap(zip(node_list, index(node_list)));
	mapping = (n : mapping[n] | n <- mapping, size(mapping[n]) > 1);
	for(n <- mapping){
		loc l = nodeToLoc[n];
		println(readFile(l));
		println("--------");
	}
}



loc getNodeLoc(node n){
	if(Declaration d := n){
		if(d.src?){
			return d.src;
		}
	}
	if(Statement s := n){
		if(s.src?){
			return s.src;
		}
	}
	return |unknown:///|;
	
}

bool goodNode(node n){
	if(Declaration d := n){
		return true;
	}
	if(Statement s := n){
		return true;
	}
	
	return false;
}










