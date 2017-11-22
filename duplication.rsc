module duplication

import IO;
import count_loc;
import String;
import List;
import Set;
import Map;

//main function
int countDuplication(loc location){
	//Get a string with all the lines of all files
	str all_code = accumulateFiles(location);
	//Split the lines
	list[str] code_list = split("\n", all_code);
	//Generate blocks of six
	//example: 10 lines get split into 1-6, 2-7, 3-8, 4-9, 5-10
	list[list[str]] blocks = createBlocks(code_list);
	//Get the occurrences (indexes) of every block
	map[list[str], set[int]] mapping = toMap(zip(blocks, index(blocks)));;
	//Filter out the lines that have only one index: themself
	set[int] result = {*n |n<-range(mapping), size(n)>1};
	//Sort the list
	list[int] tmplist = sort(result);
	num_duplicates = countIndexes(tmplist);	
	return num_duplicates;
}

public int countIndexes(list[int] myList){
	num_duplicates = 0;
	int elemIndex = 0;
	//keep track of which indexes we have visited
	list[int] visited = [];
	//loop accross every element
	for(elem <- myList){
		if(!(elem in visited)){
			//First block of the duplication, so add 6
			num_duplicates += 6;
			visited += elem;
			int tmpElem = elem + 1;
			//Check for concequetive blocks, so add 1
			while(tmpElem in myList){
				visited += tmpElem;
				num_duplicates += 1;
				tmpElem += 1;
			}
		}
	}
	return num_duplicates;

}

//Create blocks of 6 
//example: 10 lines get split into 1-6, 2-7, 3-8, 4-9, 5-10
public list[list[str]] createBlocks(list[str] code){
	list[list[str]] blocks = [[]];
	int code_size = size(code);
	//loop through every line and create a block of 6 starting from that index
	for(int index <- [0 .. code_size - 5]){
		list[str] new_block = slice(code, index, 6);
		blocks += [new_block];
	}
	return blocks;
}

// debug function to print a block
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

