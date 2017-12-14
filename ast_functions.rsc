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

tuple[list[list[node]], list[list[loc]]] getNodeBlocks(loc location){
	list[Declaration] ast = walkFilesAST(location);
	println("Created Asts");
	list[list[node]] node_blocks = [];
	list[list[loc]] loc_blocks = [];
	for(a <- ast){
		tuple[list[node], list[loc]] result = createCloneMappers(a);
		list[node] node_list = result[0];
		list[loc] loc_list = result[1];
		
		
		tuple[list[list[node]],list[list[loc]]] blocks = createBlocks(node_list, 6, loc_list);
		node_blocks += blocks[0];
		loc_blocks += blocks[1];
	}
	println("Created Blocks");
	return <node_blocks, loc_blocks>;
}


//Create blocks of size x
public tuple[list[list[node]],list[list[loc]]] createBlocks(list[node] code, int x, list[loc] loc_list){
	list[list[node]] blocks = [];
	list[list[loc]] loc_blocks = [];
	int code_size = size(code);
	//loop through every line and create a block of x starting from that index
	if(code_size>=6){
		for(int index <- [0 .. code_size - (x - 1)]){
			list[node] new_block = slice(code, index, x);
			blocks += [new_block];
			list[loc] new_loc = slice(loc_list, index, x);
			loc_blocks += [new_loc];
		}
	}
	return <blocks,loc_blocks>;
}

tuple[list[node],list[loc]] createCloneMappers(node ast){
	list[node] node_list = [];
	list[loc] loc_list = [];
	visit(ast){
		case node n:{
			if(goodNode(n)){
				loc l = getNodeLoc(n);
				n = unsetRec(n);
				if(l != |unknown:///|){
					loc tmp = changeLocZero(l);
	
					node_list += n;
					loc_list += l;
				}
			}
		}
	}
	
	return <node_list, loc_list>;
}