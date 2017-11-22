module duplication

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::Core;
import util::ValueUI;
import IO;
import Set;
import Type;
import lang::java::\syntax::Java15;
import count_loc;
import String;
import List;
import Type;
import Set;
import Map;
import util::Benchmark;

int countDuplication(loc location){
	str all_code = accumulateFiles(location);
	list[str] code_list = split("\n", all_code);
	list[list[str]] blocks = createBlocks(code_list);
	map[list[str], set[int]] mapping = countDuplicates(blocks);
	set[int] result = {*n |n<-range(mapping), size(n)>1};
	
	int num_duplicates = 0;
	int elemIndex = 0;
	list[int] visited = [];
	for(elem <- result){
		if(!(elem in visited)){
			num_duplicates += 6;
			visited += elem;
			int tmpElem = elem + 1;
			while(tmpElem in result){
				visited += tmpElem;
				num_duplicates += 1;
				tmpElem += 1;
			}
		}
		
	}
	return num_duplicates;
}

public map[list[str], set[int]] countDuplicates(list[list[str]] blocks){
	return toMap(zip(blocks, index(blocks)));
}

public list[list[str]] createBlocks(list[str] code){
	list[list[str]] blocks = [[]];
	int code_size = size(code);
	for(int index <- [0 .. code_size - 5]){
		list[str] new_block = slice(code, index, 6);
		blocks += [new_block];
	}
	return blocks;
}


// Loop recursively through the files and add the lines of code within them to the result
public str accumulateFiles(loc a){
	returncode = "";
	for (entry <- listEntries(a)){
		if (/\.java/ := entry){
			str code = readFile(a+entry);
			returncode += cleanCode(code);
		}
		elseif (isDirectory(a+entry))
			returncode += accumulateFiles(a+entry);
	}
	return returncode;
}

// Function for printing the duplicates to check if they were the same
void printSection(list[str] myList, int startAt, int endAt){
	printString = "";
	for(n <- slice(myList, startAt, (endAt - startAt))){
		printString += n + "\n";
	}
	println(printString);
}