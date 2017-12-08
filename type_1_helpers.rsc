module type_1_helpers

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


public void createSequences(list[list[node]] node_groups){
	list[list[list[node]]] overall_result = [];
	for(i <- [0..size(node_groups)]){
		overall_result += [getSequences(node_groups[i])];
	}
	iprint(overall_result);
}

// loop through all sequences in decreasing order, and search for the largest sequence that is a clone (check vs the other sequences)
public void matchSequences(list[list[list[node]]] all_sequences){
	println("");
}

// for every item create a list of all subsequent items:
// [a, b, c] -> [[a], [a, b], [a, b, c]]
list[list[node]] getSequences(list[node] myList){
	list[list[node]] result = [];
	for(i <- [0 .. size(myList)]){
		list[node] cur = [];
		for(x <- [i .. size(myList)]){
			cur += myList[x];
		}
		result += [cur];
	}
	return result;
}

loc changeLocZero(loc l){
	l.begin.column = 0;
	l.end.column = 0;
	return l;
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

void checkSubtrees(list[node] node_list){
	list[node] duplicate_trees = [];
	for(a <- node_list){
		for( b <- node_list){
			if(a < b){
				duplicate_trees += b;
			}
		}
	}
	text(duplicate_trees);

}

void printNodeClasses(list[list[int]] node_classes, map[node, loc] nodeToLoc, list[node] node_list){
	for(clas <- node_classes){
		for(n <- clas){
			node cur = node_list[n];
			loc l = nodeToLoc[cur];
			println(readFile(l));
		}
		println("---------------------------");
	}

}

set[node] getChildren(node parent){
	set[node] result = {};
	visit(parent){
		case node n : {
			if(n != parent && goodNode(n)){
				result += n;
			}
		}
	}
	return result;

}

void getCloneClass(map[node, set[int]] mapping){
	text(mapping);
	for(n <- mapping){
		set[node] cur = getChildren(n);
		iprint(cur);
	}

}