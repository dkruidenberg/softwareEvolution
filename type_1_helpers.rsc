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


// test on a list of ints if our subsumption algorithm works
// clone_list is a list with lists with lists of integers, the concatenation of the inner lists results in an entire clone.
void subsumptionTest(list[list[list[int]]] clone_list){
	list[list[int]] result = [];
	for(clone_block <- clone_list){
		// if there is only a single block it can never have a subclass
		if(size(clone_block) != 1){
			int max_size_block = size(clone_block) - 1;
			// check if part of this clone is in another clone
			for(check_block <- (clone_list - [clone_block])){
				// loop through the blocks of the overall clone
				int skip = 0;
				for(clone_index <- [0 .. size(clone_block)]){
					x = true;
					if(skip == 0){
						// if there is only a single block it can never have a subclass
						if(size(check_block) != 1){
							// current clone 
							clone = clone_block[clone_index];
							list[int] cur_bucket = [];
							int check_index = indexOf(check_block, clone);
							if(check_index != -1){
								int max_size_check = size(check_block) - 1;
								println("overall test clone: <clone_block>");
								println("overall check clone: <check_block>");
								println("Working with clone: <clone>");
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
									println("bucket: <cur_bucket>");
								}
								if((cur_bucket in result) == false){
									result += [cur_bucket];
								}
								println("skip is <skip>");
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
	println(result);
}
// is actually: [[1, 2, 3], [1, 2, 3, 4, 5], [1, 2, 3, 4], [2, 3, 4, 5, 6]]
//[[[1, 2, 3]], [[1, 2, 3], [2, 3, 4], [3, 4, 5]], [[1, 2, 3], [2, 3, 4]], [[2, 3, 4], [3, 4, 5], [4, 5, 6]]]