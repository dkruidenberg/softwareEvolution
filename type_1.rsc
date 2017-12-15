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

clone classes definition -> http://maveric0.uwaterloo.ca/~migod/846/papers/roy-CloningSurveyTechReport.pdf
clone classes -> set van subtrees van de clone class
voor elke clone class check if subset of the subtrees of one other clone classes. 
(mostly check if it is not a subset of all classes, if this is the case, it is a clone class).

TODOS:
- Change json parser with filename
- HTML bedazzle
- Create test suite
*/

module type_1

import type_1_helpers;
import text_functions;
import ast_functions;
import clone_statistics;

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

// main function, also tells you what you are doing
void type_1_statistics(loc location, int min_clone_size, bool type1){
	if(type1){
		println("Searching for type 1 clones...");
	}
	else{
		println("Searching for type 2 clones...");
	}
	countDuplication(location, min_clone_size, type1);
}

// Get the node blocks with their location, detect the clones, group them, execute subsumption,
// print the statistics, and return the clone classes
list[list[node]] countDuplication(loc location, int min_clone_size, bool type1){
	tuple[list[list[node]],list[list[loc]], int, map[node, list[loc]]] result = getNodeBlocks(location, min_clone_size, type1);
	list[list[node]] node_blocks = result[0];
	map[node, list[loc]] nodeToLoc = result[3];
	int total_size = result[2];
	list[list[loc]] loc_blocks = result[1];
	// Detecting clones
	map[list[node], set[int]] mapping = toMap(zip(node_blocks, index(node_blocks)));
	mapping = (n : mapping[n] | n <- mapping, size(mapping[n]) > 1);
	println("Created Mapping");

	// get all the overall clone classes
	tuple[list[list[node]],list[list[int]]] result_clones = collect_clones(mapping, node_blocks);
	list[list[node]] clone_classes = result_clones[0];
	list[list[int]] grouped_list = result_clones[1];

	
	list[list[list[node]]] clone_list = group_listToCloneList(grouped_list, node_blocks); 
	list[list[list[loc]]] location_list = getLocation(grouped_list, node_blocks,loc_blocks);
	json(clone_list, location_list, nodeToLoc);

	percentageAstClones(grouped_list, total_size, min_clone_size);
	cloneClassesToFile(clone_classes, nodeToLoc);
	return clone_classes;
	

}

// group all indices where clones occur to find clones larger than the specified size (we chose 6)
public tuple[list[list[node]],list[list[int]]] collect_clones(map[list[node], set[int]] mapping, list[list[node]] node_block){
	list[int] node_indices = sort([*n |n<-range(mapping), size(n)>1]);
	list[list[int]] grouped_list = groupIndices(node_indices);
	list[list[node]] clone_classes = getCloneClasses(grouped_list, node_block);
	return <clone_classes,grouped_list>;
}

// group the blocks per clone into 1 clone class and add the subsumption clone classes to the result to get all clone classes
public list[list[node]] getCloneClasses(list[list[int]] grouped_list, list[list[node]] node_blocks){
	list[list[list[node]]] clone_list = group_listToCloneList(grouped_list, node_blocks);
	list[list[node]] clone_classes = group_clones(clone_list);
	list[list[node]] sumb_classes = subsumption(clone_list);
	createStatistics(sumb_classes, clone_classes);
	clone_classes += sumb_classes;
	
	clone_classes = toList(toSet(clone_classes));
	return clone_classes;
}

// Find sub-clones that are part of 2 clones, but are not clones on their own. A.K.A: If A is a sub clone from B,
// and A is a sub clone from C, where B != C, A is a subclone.
//
// This is done by manually iterating over all sub clones, and checking if they occur in other clones. If they do,
// we also look for the largest sub-clone that can be found.
// The test function for this method is stated in type_1_helper, that function takes lists of ints as input (which is a lot
// easier to read). Test code will be created for that function
//
// Note that this method is insanely long and has a high cyclomatic complexity. We left it like this since there is a lot of
// variable dependency in between the loops, and mostly because we were happy it worked. 
list[list[node]] subsumption(list[list[list[node]]] clone_list){
	num progress = 0;
	num total_size = size(clone_list);
	list[list[node]] result = [];
	for(clone_block <- clone_list){
		progress += 1;
		println("Progress in subsumption (might take a while): <progress / total_size * 100>%");
		// if there is only a single block it can never have a subclass
		if(size(clone_block) != 1){
			int max_size_block = size(clone_block) - 1;
			// check if part of this clone is in another clone
			for(check_block <- (clone_list - [clone_block])){
				// loop through the blocks of the overall clone
				int skip = 0;
				for(clone_index <- [0 .. size(clone_block)]){
					x = true;
					
					// The skip parameter is needed in order to only find the largest sub-clone
					// otherwise every sub-clone will be added too after the while loop
					if(skip == 0){
						// if there is only a single block it can never have a subclass
						if(size(check_block) != 1){
							// current clone 
							clone = clone_block[clone_index];
							list[node] cur_bucket = [];
							int check_index = indexOf(check_block, clone);
							// if a sub-clone occurs in another clone, search for the largest sub-clone and add this to the result
							if(check_index != -1){
								int max_size_check = size(check_block) - 1;
								while(x){
									skip += 1;
									if(cur_bucket == []){
										cur_bucket += clone_block[clone_index];
									}
									else{
										cur_bucket += clone_block[clone_index][2];
									}
									if((clone_index + 1 <= max_size_block && check_index + 1 <= max_size_check)
									&& (clone_block[clone_index + 1] == check_block[check_index + 1])){
										clone_index += 1;
										check_index += 1;
									
									
									}
									else{
										x = false;
									}
								}
								if((cur_bucket in result) == false){
									result += [cur_bucket];
								}
							}
						}
					}
					else{
						skip -= 1;
					}
				}
			}
		}
	}
	return result;
}

// Takes a list of nodes like [[a, b, c], [b,c,d]] and makes it into 1 overall clone: [a, b, c, d]
list[list[node]] group_clones(list[list[list[node]]] clone_list){
	clone_list = [n |n<-clone_list,size(n)!=0];
	list[list[node]] result = [];
	// for every clone, collect the nodes into buckets and add it to the result
	for(clone_block <- clone_list){
		list[node] cur_bucket = [];
		for(int i <- [0 .. size(clone_block)]){
			if(size(clone_block[i]) != 0){
				if(i == 0){
					cur_bucket += clone_block[i];
				}
				else{
					cur_bucket += clone_block[i][size(clone_block[i]) - 1];
				}
			}
		}
		result += [cur_bucket];
	}
	result = toList(toSet(result));
	return result;	
}

// Take a list of positions and put the clones in them
// We also remove duplicate clones here (so the subsumption will go faster, since we only need the overall clone classes
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

list[list[list[loc]]] getLocation(list[list[int]] grouped_list, list[list[node]] node_blocks, list[list[loc]] loc_blocks){
	list[list[list[node]]] result = [];
	list[list[list[loc]]] result_loc = [];
	for(n <- grouped_list){
		list[list[node]] cur_bucket = [];
		set[loc] set_loc = {};
		for(i <- n){
			cur_bucket += [node_blocks[i]];
			set_loc += toSet(loc_blocks[i]);
		}
		if(!(cur_bucket in result)){
			result += [cur_bucket];
			result_loc += [[toList(set_loc)]];
		}
		else{
			int index = indexOf(result, cur_bucket);
			result_loc[index] += [toList(set_loc)];
		}
	}
	return result_loc;
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



