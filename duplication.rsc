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
	map[list[str], set[int]] mapping = toMap(zip(blocks, index(blocks)));;
	set[int] result = {*n |n<-range(mapping), size(n)>1};
	list[int] tmplist = sort(result);
	return accumulateSet(tmplist);
	
}

public int accumulateSet(list[int] myList){
	num_duplicates = 0;
	int elemIndex = 0;
	list[int] visited = [];
	iprint(myList);
	for(elem <- myList){
		if(!(elem in visited)){
			num_duplicates += 6;
			visited += elem;
			int tmpElem = elem + 1;
			while(tmpElem in myList){
				println(tmpElem);
				visited += tmpElem;
				num_duplicates += 1;
				tmpElem += 1;
			}
		}
		
	}
	return num_duplicates;

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

public void printList(list[str] entry){
	for(n <- entry){
		println(n);
	}
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

