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

import type_1_helpers;
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
	list[list[node]] node_blocks = createBlocks(node_list, 3);
	map[list[node], set[int]] mapping = toMap(zip(node_blocks, index(node_blocks)));
	mapping = (n : mapping[n] | n <- mapping, size(mapping[n]) > 1);
	collect_clones(mapping, node_blocks);
	//printNodeClasses(node_classes, nodeToLoc, node_list);
	//getCloneClass(mapping);
	
}

public void collect_clones(map[list[node], set[int]] mapping, list[list[node]] node_block){
	list[int] node_indices = sort([*n |n<-range(mapping), size(n)>1]);
	list[list[int]] grouped_list = groupIndices(node_indices);
	list[list[node]] node_groups = getNodeGroups(grouped_list, node_block, mapping);
	//createSequences(node_groups);

}

// subsumption part
public list[list[node]] getNodeGroups(list[list[int]] grouped_list, list[list[node]] node_blocks, map[list[node], set[int]] mapping){
	list[list[node]] result = [];
	list[list[list[node]]] clone_list = group_listToCloneList(grouped_list, node_blocks);
	list[list[node]] overall_clones = group_clones(clone_list);
	list[list[node]] subclasses = [];
	for(clone_block <- clone_list){
		list[node] cur_bucket = [];
		for(int clone_index <- [0 .. size(clone_block)-1]){
			list[node] clone = clone_block[clone_index];
			subclasses = subsumption(clone_list, clone_block, clone_index, subclasses);
		}
	}
	text(subclasses);
	return result;
}


// For a clone block (x lines), loop through the other blocks and see if it can find itself.
// If it can find itself, it is a subclass since the clone list is actually a set of all the overall clone classes.
// If it found itself, it will search for the largest clone-sub-class
list[list[node]] subsumption(list[list[list[node]]] clone_list, list[list[node]] myBlock, int clone_index, list[list[node]] subclasses){
	clone_class = true;
	list[node] clone = myBlock[clone_index];
	int max_size_block = size(myBlock) - 1;
	for(check_block <- (clone_list - [myBlock])){
		x = true;
		list[node] cur_bucket = [];
		int check_index = indexOf(check_block, clone);
		if(check_index != -1){
			println("-----------------------");
			iprint(clone);
			println("-----------------------");
			int max_size_check = size(check_block) - 1;
			while(x){
				println(myBlock[clone_index]);
				if(cur_bucket == []){
					cur_bucket += myBlock[clone_index];
				}
				else{
					cur_bucket += myBlock[clone_index][max_size_block];
				}
				if((clone_index + 1 <= max_size_block && check_index + 1 <= max_size_check)
					&& (myBlock[clone_index + 1] == check_block[check_index + 1])){
					clone_index += 1;
					check_index += 1;
					
				}
				else{
					x = false;
				}
			}
			subclasses = addToSubClasses(subclasses, cur_bucket);
		}
	}
	subclasses = toList(toSet(subclasses));
	return subclasses;
}

// if the subclass occurs in only 1 other subclass, and not on its own, do not add it
list[list[node]] addToSubClasses(list[list[node]] subclasses, list[node] cur_bucket){
	int i = 0;
	for(n <- subclasses){
		if(cur_bucket in subclasses){
			i += 1;
		}
	}
	if(i != 1){
		subclasses += [cur_bucket];
	}
	return subclasses;
}

// Takes a list of nodes like [[a, b, c], [b,c,d]] and makes it into 1 overall clone: [a, b, c, d]
list[list[node]] group_clones(list[list[list[node]]] clone_list){
	list[list[node]] result = [];
	// for every clone, collect the nodes into buckets and add it to the result
	for(clone_block <- clone_list){
		list[node] cur_bucket = [];
		for(int i <- [0 .. size(clone_block)-1]){
			
			if(i == 0){
				cur_bucket += clone_block[i];
			}
			else{
				cur_bucket += clone_block[i][size(clone_block[i]) - 1];
			}
		}
		result += [cur_bucket];
	}
	result = toList(toSet(result));
	return result;	
}

// Take a list of positions and put the clones in them
list[list[list[node]]] group_listToCloneList(list[list[int]] grouped_list, list[list[node]] node_blocks){
	list[list[list[node]]] result = [];
	for(n <- grouped_list){
		list[list[node]] cur_bucket = [];
		for(i <- n){
			cur_bucket += [node_blocks[i]];
		}
		if(!(cur_bucket in result)){
			result += [cur_bucket];
		}
	}
	return result;

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

// group all lines that are found to be clones and are subsequent in the AST
public list[list[int]] groupIndices(list[int] node_indices){
	list[list[int]] clone_classes = [];
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











