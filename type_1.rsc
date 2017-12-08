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

get all subtrees, get mapping
remove all single occuring maps

clone classes -> set van subtrees van de clone class
voor elke clone class check if subset of the subtrees of one other clone classes. 
(mostly check if it is not a subset of all classes, if this is the case, it is a clone class).

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
import type_1_helpers;


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
	list[list[node]] node_blocks = createBlocks(node_list, 2);
		
	map[list[node], set[int]] mapping = toMap(zip(node_blocks, index(node_blocks)));
	mapping = (n : mapping[n] | n <- mapping, size(mapping[n]) > 1);
	collect_clones(mapping, node_blocks);
	//list[list[int]] node_classes = groupIndices(node_indices);
	//printNodeClasses(node_classes, nodeToLoc, node_list);
	//getCloneClass(mapping);
	
}

public void collect_clones(map[list[node], set[int]] mapping, list[list[node]] node_list){
	list[int] node_indices = sort([*n |n<-range(mapping), size(n)>1]);
	list[list[int]] grouped_list = groupIndices(node_indices);
	list[list[node]] node_groups = getNodeGroups(grouped_list, node_list);
	createSequences(node_groups);

}


// group all lines that are found to be clones and are subsequent in the AST
public list[list[node]] getNodeGroups(list[list[int]] grouped_list, list[list[node]] node_blocks){
	list[list[node]] result = [];
	for(n <- grouped_list){
		list[node] cur = [];
		for(i <- n){
			cur += (node_blocks[i] - cur);
		}
		result += [cur];
	}
	return result;
}

public void removeSubsequences(list[list[node]] node_groups){
	println("");
}

//Create blocks of size x
public list[list[node]] createBlocks(list[node] code, int x){
	list[list[node]] blocks = [[]];
	int code_size = size(code);
	//loop through every line and create a block of x starting from that index
	for(int index <- [0 .. code_size - (x - 1)]){
		list[node] new_block = slice(code, index, x);
		blocks += [new_block];
	}
	return blocks;
}

public list[list[int]] groupIndices(list[int] node_indices){
	list[list[int]] clone_classes = [];
	node_indices = sort(node_indices);
	skip_counter = 0;
	for(int n <- [0 .. size(node_indices)]){
		int cur_index = node_indices[n];
		list[int] cur_bucket = [];
		if(skip_counter == 0){
			cur_bucket += cur_index;
			while(cur_index + 1 in node_indices){
				cur_index = cur_index + 1;
				cur_bucket += cur_index;
				skip_counter += 1;
				
			}
			clone_classes += [cur_bucket];
		}
		else{
			skip_counter -= 1;
		}
	}
	return clone_classes;

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

bool goodNode(node n){
	if(Declaration d := n){
		return true;
	}
	if(Statement s := n){
		return true;
	}
	
	return false;
}









