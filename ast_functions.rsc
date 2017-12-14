module ast_functions

import type_1_helpers;
import text_functions;
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


public list[Declaration] walkFilesAST(loc a){
	list[Declaration] ast = [];
	for (entry <- listEntries(a)){
		if (/\.java/ := entry){
			ast += createAstFromFile(a + entry, true);
		}
		elseif (isDirectory(a+entry))
			ast += walkFilesAST(a+entry);
	}
	return ast;
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

tuple[list[list[node]], map[node, list[loc]]] getNodeBlocks(loc location){
	list[Declaration] ast = walkFilesAST(location);
	println("Done1");
	list[list[node]] node_blocks = [];
	map[node, list[loc]] nodeToLoc = ();
	for(a <- ast){
		tuple[list[node], map[node, list[loc]]] result = createCloneMappers(a);
		list[node] node_list = result[0];
		for(res <- result[1]){
			if(nodeToLoc[res]?){
				nodeToLoc[res] += result[1][res];
			}
			else{
				nodeToLoc[res] = result[1][res];
			}
		}
		node_blocks += createBlocks(node_list, 6);
	}
	println("Created Blocks");
	return <node_blocks, nodeToLoc>;
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

tuple[list[node], map[node, list[loc]]] createCloneMappers(node ast){
	list[node] node_list = [];
	map[node, list[loc]] nodeToLoc = ();
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
	
					node_list += n;
				}
			}
		}
	}
	
	return <node_list, nodeToLoc>;
}