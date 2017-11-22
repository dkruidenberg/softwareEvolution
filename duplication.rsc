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


int countDuplication(loc location){
	str all_code = accumulateFiles(location);
	list[str] code_list = split("\n", all_code);
	list[list[str]] blocks = createBlocks(code_list);
	for(n <- blocks){
		println(size(n));
		println(n);
	}

	return 0;
}

public int countDuplicates(list[list[str]] blocks){
	list[list[int]] overall_indexes = [[]]; 
	for(int index <- [0, size(blocks)]){
		cur_block = blocks[index];
		list[list[str]] tmp_blocks = drop(1, blocks);
		int last_index = 0;
		
		while(indexOf(tmp_blocks, cur_block) != -1){
			int duplicate_index = indexOf(tmp_blocks, cur_block);
			tmp_blocks = drop(duplicate_index, tmp_blocks);
		}
	
	}

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