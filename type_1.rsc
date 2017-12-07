/*
Jordy Bottelier 10747338
Dennis Kruidenberg

We only look at the statements and declarations according to:
http://facebook.comwww.semanticdesigns.com/Company/Publications/ICSM98.pdf

We loop through the ast.
Every node that is a declaration or statement (all visible code), is added to the node list (which is ordered).
We then create a mapping, counting on what index every statement occurs. 
Using all the values of this mapping, we now know every position of a cloned statement. 
Now we group consecutive values, so we can find a clone class

*/

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
	node ast = createAstFromFile(|project://SoftwareEvolution/src/test_suite/type1test.java|, true);
	tuple[list[node], map[node, loc], map[loc, node]] result = createCloneMappers(ast);
	list[node] node_list = result[0];
	map[node, loc] nodeToLoc = result[1];
	map[loc, node] locToNode = result[2];
		
	map[node, set[int]] mapping = toMap(zip(node_list, index(node_list)));
	mapping = (n : mapping[n] | n <- mapping, size(mapping[n]) > 1);
	list[int] node_indices = [*n |n<-range(mapping), size(n)>1];
	groupIndices(node_indices);
}

public int groupIndices(list[int] myList){
	list[list[int]] clone_classes = [[]];
	
	
	return 0;

}



tuple[list[node], map[node, loc], map[loc, node]] createCloneMappers(node ast){
	list[node] node_list = [];
	map[node, loc] nodeToLoc = ();
	map[loc, node] locToNode = ();
	visit(ast){
		case node n:{
			if(goodNode(n)){
				loc l = getNodeLoc(n);
				n = unsetRec(n);
				if(l != |unknown:///|){
					nodeToLoc[n] = l;
					loc tmp = changeLocZero(l);
					locToNode[tmp] = n;
					node_list += n;
				}
			}
		}
	}
	return <node_list, nodeToLoc, locToNode>;
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










