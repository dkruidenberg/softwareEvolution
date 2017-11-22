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
	//keep track of duplicates
	//int num_duplicates = 0;
	//int duplicate_lines = 0;
	//
	////used for indicating process
	//int allMethSize = size(code_list);
	//real progress = 0.0;
	//real step = 1.0 / allMethSize * 100;
	//
	//int counter_x = 0;
	////walk through each method
	//for(line <- code_list){		
	//	// progress indicator
	//	progress += step;
	//	println(progress);
	//	findDuplicateLine(code_list, line, counter_x);
	//	counter_x += 1;
	//}
	////println(num_duplicates);
	////println(duplicate_lines);
	return 0;
}

public list[list[str]] createBlocks(list[str] code){
	list[list[str]] blocks = [[]];
	index = 0;
	int code_size = size(code);
	for(int index <- [0 .. code_size - 5]){
		list[str] new_block = slice(code, index, 6);
		blocks += [new_block];
	}
	return blocks;
}

public int findDuplicateLine(list[str] code_list, str line, int starting_index){
	int num_duplicates = 0;
	check_index = starting_index + 7;
	for(check_line <- drop(check_index, code_list)){
		if(check_line == line){
			count_duplicate_lines(code_list);
		}
	}
	return num_duplicates;
}

public int count_duplicate_lines(list[str] code_list){
	int a;
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