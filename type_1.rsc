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

public list[Declaration] walkFiles(loc a){
	list[Declaration] ast = [];
	for (entry <- listEntries(a)){
		if (/\.java/ := entry){
			ast += createAstFromFile(a + entry, true);
		}
		elseif (isDirectory(a+entry))
			ast += walkFiles(a+entry);
	}
	return ast;
}

//main function
void countDuplication(loc location){
	list[Declaration] ast = walkFiles(|project://smallsql0.21_src|);
	println("Done1");
	list[list[node]] node_blocks = [];
	map[node, list[loc]] nodeToLoc = ();
	map[loc, node] locToNode = ();
	for(a <- ast){
		tuple[list[node], map[node, list[loc]], map[loc, node]] result = createCloneMappers(a);
		list[node] node_list = result[0];
		for(res <- result[1]){
			if(nodeToLoc[res]?){
				nodeToLoc[res] += result[1][res];
			}
			else{
				nodeToLoc[res] = result[1][res];
			}
		}
		for(res <- result[2]){
			if(locToNode[res]?){
				locToNode[res] += result[2][res];
			}
			else{
				locToNode[res] = result[2][res];
			}
		}
		node_blocks += createBlocks(node_list, 6);
	}
	println("Done2");
	map[list[node], set[int]] mapping = toMap(zip(node_blocks, index(node_blocks)));
	mapping = (n : mapping[n] | n <- mapping, size(mapping[n]) > 1);
	println("Done3");
	//json(mapping, nodeToLoc);
	collect_clones(mapping, node_blocks);
}
void json(map[list[node], set[int]] mapping, map[node, list[loc]] nodeToLoc){
	list[list[loc]] dupl = [];
	for(k<-mapping){
		if(size(k) == 0){
			continue;
		}
		list[list[loc]] locations = [];
		for(l <- k){
			locations += [nodeToLoc[l]];
		}
		dupl += [findfiles(locations)];
		
	}
	map[loc,list[loc]] result = createMap(dupl);
	writeJSON(result);
	
}
void writeJSON(map[loc,list[loc]] input){
	str result = "[";
	int counterOuter = 1;
	int sizeOuter = size(input);
	for(l<-input){
		list[int] lines = [];
		lines += l.begin.line;
		
		result += "\n{\"name\":";
		result += "\"" + l.path + "\", ";

		result += "\"imports\":[";
		int counter = 1;
		limit = size(input[l]);
		str tmpString = "";
		for(matches <- input[l]){
			lines += matches.begin.line;
			str tmpresult = "\"" + matches.path + "\"";
			result += tmpresult;
			if(counter < limit){
				result += ", ";
			}
			
			tmpString += "\n{\"name\":" + tmpresult  + " , \"imports\":[], \"source\": []}";
			if(counter < limit){
				tmpString += ", ";
			}
			counter += 1;
		}
		

		result += "],\"source\": " + toString(lines) +"},";
		result += tmpString;
		if(counterOuter<sizeOuter){
			result += ",";
		}
		counterOuter += 1;
	}
	result += "\n]";	
	writeFile(|project://SoftwareEvolution/src/readme.json|,result);
}

list[loc] findfiles(list[list[loc]] locations){
	list[loc] result = [];
	
	for(l <- locations[0]){
		bool tmp = true;
		counter = 1;
		for(x <- drop(1,locations)){
			if(!any(loc n <- x, (l.begin.line + counter) == n.begin.line)){
				tmp = false;
			}
			counter += 1;
		}
		if(tmp){
			result += l;
		}
	}
	return result;
}
map[loc,list[loc]] createMap(list[list[loc]] lst){
	map[loc,list[loc]] result = ();
	iprint(lst);
	for(l <- lst){
		println(l);
		if(size(l)>0){
			loc key = l[0];
			list[loc] rem = drop(1,l);
	
			result[key] = rem;
		}
	}
	return result;
}

// group all indices where clones occur to find clones larger than the specified size (we chose 6)
public void collect_clones(map[list[node], set[int]] mapping, list[list[node]] node_block){
	list[int] node_indices = sort([*n |n<-range(mapping), size(n)>1]);
	list[list[int]] grouped_list = groupIndices(node_indices);
	list[list[node]] clone_classes = getCloneClasses(grouped_list, node_block, mapping);
}

// group the blocks per clone into 1 clone class and add the subsumption clone classes to the result to get all clone classes
public list[list[node]] getCloneClasses(list[list[int]] grouped_list, list[list[node]] node_blocks, map[list[node], set[int]] mapping){
	list[list[list[node]]] clone_list = group_listToCloneList(grouped_list, node_blocks);
	list[list[node]] clone_classes = group_clones(clone_list);
	clone_classes += subsumption(clone_list);
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
	text(clone_list);
	list[list[node]] result = [];
	// for every clone, collect the nodes into buckets and add it to the result
	for(clone_block <- clone_list){
			list[node] cur_bucket = [];
			if(size(clone_block) != 0){
				for(int i <- [0 .. size(clone_block)]){
					if(i == 0){
						cur_bucket += clone_block[i];
					}
					else{
						cur_bucket += clone_block[i][size(clone_block[i]) - 1];
					}
				}
				result += [cur_bucket];
			}
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
	if(code_size>=6){
		for(int index <- [0 .. code_size - (x - 1)]){
			list[node] new_block = slice(code, index, x);
			blocks += [new_block];
		}
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



tuple[list[node], map[node, list[loc]], map[loc, node]] createCloneMappers(node ast){
	list[node] node_list = [];
	map[node, list[loc]] nodeToLoc = ();
	map[loc, node] locToNode = ();
	visit(ast){
		case node n:{
			if(goodNode(n)){
				loc l = getNodeLoc(n);
				n = unsetRec(n);
				if(l != |unknown:///|){
					if(nodeToLoc[n]?){
						nodeToLoc[n] += l;
					}
					else{
						nodeToLoc[n] = [l];
					}
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











