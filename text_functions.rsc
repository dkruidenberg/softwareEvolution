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

void json(list[list[int]] group_list, list[list[loc]] loc_blocks){
	str result = "[";
	int counterOuter = 1;
	int sizeOuter = size(group_list);
	
	for(g <- group_list){
		int start_index = g[0];
		int end_index = g[size(g)-1];
		loc start_location = loc_blocks[start_index][0];
		loc end_location = loc_blocks[end_index][size(loc_blocks[end_index])-1];
		iprint(start_location);
		iprint(end_location);
		
		result += "\n{\"name\":";
		result += "\"" + start_location.path + "\", ";
		
		result += "\"imports\":[";
		int counter = 1;
		int limit = size(loc_blocks[g[0]]);
		for(entry <- loc_blocks[g[0]]){
			result += "\"" + entry.path + "\<" + "<entry.begin.line>" + "," + "<entry.end.line>" + "\>\"";
		}
		break;
		
	}
	iprint(result);
	
	
	
	

	
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

void cloneClassesToFile(list[list[node]] clone_classes, map[node, list[loc]] nodeToLoc){
	list[str] text_blocks = getTextBlocks(clone_classes, nodeToLoc);
	str printstring = "";
	for(n <- text_blocks){
		printstring += n + "\n-------- New Clone Class -------------\n";
	}
	writeFile(|project://SoftwareEvolution/src/clone_classes.text|,printstring);
		println("\nExample Clone:\n <text_blocks[0]>");

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
	for(l <- lst){
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