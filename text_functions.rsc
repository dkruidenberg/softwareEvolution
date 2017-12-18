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

tuple[int,int] getNumbers(list[loc] lst){
	int begin = 100000000;
	int end = 0;
	for(location <- lst){
		if(location.begin.line < begin){
			begin = location.begin.line;
		}
		if(location.end.line > end){
			end = location.end.line;
		}
	}
	return <begin,end>;
}


void json(list[list[list[node]]] clone_list, list[list[list[loc]]] location_list, map[node, list[loc]] nodeToLoc){
	str result = "[";
	int counterOuter = 0;
	int limitOuter = size(location_list);
	int index_counter = 0;
	//first string needs to be added also
	for(locations <- location_list){
		counterOuter += 1;
		if(size(locations)<2){
			continue;
		}
		tuple[int,int] first = getNumbers(locations[0]);
		result += "\n{\"name\":";
		result += "\"" + locations[0][0].path + "\", ";
		result += "\"imports\":[";
		
		int counter = 1;
		int limit = size(locations) ;
		str sourceString = "\"source\": [";
		for(location <- drop(0,locations)){
			
			tuple[int,int] endings = getNumbers(location);
			result += "\"" + location[0].path + "\"";
			sourceString += "\"" + location[0].path + "\<" + "<endings[0]>" + "," + "<endings[1]>" + "\>\"";
			if(counter < limit){
				result += ",";
				sourceString += ",";
			}
			counter += 1;
		}
		result += "], ";
		sourceString += "]";
		result += sourceString;
		result += ", \"code\": [";
		result += "\"" + getText(clone_list[index_counter][0], nodeToLoc) + "\"";
		result += "]}";

		index_counter += 1;
		
		if(counterOuter < limitOuter){
			result += ",";
		}
		
		
	}
	result += "]";
	writeFile(|project://SoftwareEvolution/src/data.json|,result);
	return;
	
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
			result += escape(line, ("\"": "\\\"","\t":" "));
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