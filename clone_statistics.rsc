module clone_statistics

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
import util::Math;

void percentageAstClones(list[list[int]] grouped_list, int total_size, int min_clone_size){
	int clone_size = 0;
	for(g <- grouped_list){
		if(size(g) == 1){
			clone_size += min_clone_size;
		}
		else{
			clone_size += min_clone_size + size(g) - 1; 
		}
	}
	println("Percentage duplicate duplicate AST nodes <clone_size / toReal(total_size) * 100>");
}

void createStatistics(list[list[node]] sumb_classes, list[list[node]] clone_classes){
	int num_clones = size(clone_classes);
	int num_clone_classes = size(sumb_classes);
	int largest_clone = largestFromList(clone_classes);
	int largest_sub = largestFromList(sumb_classes);

	clone_classes += sumb_classes;
	clone_classes = toList(toSet(clone_classes));

	println("Number of clones: <num_clones>");
	println("Number of distinct clone classes (clones that only occur within other clones that are not the same): <num_clone_classes>");
	println("Total number of clone classes (number of clones + number of distinct classes): <size(clone_classes)>");
	println("Largest sub class (in AST nodes): <largest_sub>");
	println("Largest clone (in AST nodes): <largest_clone>");
	
}

int largestFromList(list[list[node]] myList){
	int largest_sub = 0;
	for(c <- myList){
		if(size(c) > largest_sub){
			largest_sub = size(c);
		}
	}
	return largest_sub;

}

