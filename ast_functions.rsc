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

tuple[list[list[node]], list[list[loc]], int, map[node, list[loc]]] getNodeBlocks(loc location, int min_clone_size, bool type1){
	list[Declaration] ast = walkFilesAST(location);
	println("Created Asts");
	list[list[node]] node_blocks = [];
	list[list[loc]] loc_blocks = [];
	int total_ast_sizes = 0;
	map[node, list[loc]] nodeToLoc = ();
	for(a <- ast){
		tuple[list[node], list[loc], map[node, list[loc]]] result = createCloneMappers(a, type1);
		list[node] node_list = result[0];
		list[loc] loc_list = result[1];
		total_ast_sizes += size(node_list);
		for(res <- result[2]){
			if(nodeToLoc[res]?){
				nodeToLoc[res] += result[2][res];
			}
			else{
				nodeToLoc[res] = result[2][res];
			}
		}		
		tuple[list[list[node]],list[list[loc]]] blocks = createBlocks(node_list, min_clone_size, loc_list);
		node_blocks += blocks[0];
		loc_blocks += blocks[1];
	}
	println("Created Blocks");
	return <node_blocks, loc_blocks, total_ast_sizes, nodeToLoc>;
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

tuple[list[node],list[loc], map[node, list[loc]]] createCloneMappers(node ast, bool type1){
	list[node] node_list = [];
	list[loc] loc_list = [];
	map[node, list[loc]] nodeToLoc = ();
	visit(ast){
		case node n:{
			if(goodNode(n)){
				loc l = getNodeLoc(n);
				n = unsetRec(n);
				if(l != |unknown:///|){
					// in case of type 2 clones, normalize the node
					if(type1){
						n = n;
					}
					else{
						n = changeAstNode(n);
					}
					
					// Add the possible node locations to the mapping
					if(nodeToLoc[n]?){
						nodeToLoc[n] += l;
					}
					else{
						nodeToLoc[n] = [l];
					}
					loc tmp = changeLocZero(l);

					node_list += n;
					loc_list += l;
				}
			}
		}
	}
	return <node_list, loc_list, nodeToLoc>;
}

public node changeAstNode(node n){
	return visit(n) {
		case \stringLiteral(_) => \stringLiteral("string_literal")
    	case \variable(_, x) => \variable("variable", x)
    	case \characterLiteral(_) => characterLiteral("character_literal")
    	case \number(_) => \number("1")
    	case \booleanLiteral(_) => \booleanLiteral(true)
    	case \method(x, _, y, z, q) => \method(x, "method", y, z, q)
		case \method(x, _, y, z) => \method(x, "method", y, z) 	
    	case \variable(_, x, y) => \variable("variable", x, y)
    	case \simpleName(_) => \simpleName("simple_name")
	}


}









