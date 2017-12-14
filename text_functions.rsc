module text_functions


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

void json(list[list[node]]  clones_classes, map[node, list[loc]] nodeToLoc){
	list[list[loc]] dupl = [];
	for(clone<-clones_classes){
		if(size(clone) == 0){
			continue;
		}
		list[list[loc]] locations = [];
		for(l <- clone){
			locations += [nodeToLoc[l]];
		}
		dupl += [findfiles(locations)];
		
	}
	map[loc,list[loc]] result = createMap(dupl);
	writeJSON(result);	
}

list[str] getTextBlocks(list[list[node]] node_blocks, map[node, list[loc]] nodeToLoc){
	list[str] result = [];
	for(b <- node_blocks){
		result += [getText(b, nodeToLoc)];
	}
	return result;

}

str getText(list[node] block, map[node, list[loc]] nodeToLoc){
	str result = "";
	for(b<-block){
		list[str] lines = readFileLines(nodeToLoc[b][0]);
		for(line <- lines){
			result += line + "\n";
		}
	}
	return result;
}



void writeJSON(map[loc,list[loc]] input){
	str result = "[";
	int counterOuter = 1;
	int sizeOuter = size(input);
	for(l<-input){
		list[str] lines = [];
		lines += l.path +":" + "<l.begin.line>";
		
		result += "\n{\"name\":";
		result += "\"" + l.path + "\", ";

		result += "\"imports\":[";
		int counter = 1;
		limit = size(input[l]);
		str tmpString = "";
		for(matches <- input[l]){
			lines += matches.path +":" + "<matches.begin.line>";
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

void printNodes(list[list[node]] node_blocks){
	for(n <- node_blocks){
		println("New Block");
		println(size(n));
		for(i <- n){
			iprint(i);
		}
		println("----------------------");
	
	}

}