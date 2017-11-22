module count_loc
import lang::java::jdt::m3::Core;
// m = createM3FromEclipseProject(|project://smallsql0.21_src|);
import IO;
import String;

// Loop recursively through the files and count the lines of code within them
public int walkFiles(loc a){
	num_lines = 0;
	for (entry <- listEntries(a)){
		if (/\.java/ := entry){
			str code = readFile(a+entry);
			num_lines += countLOC(code);
		}
		elseif (isDirectory(a+entry))
			num_lines += walkFiles(a+entry);
	}
	return num_lines;
}

// Count the lines of code by first filtering multiline comment strings and then single line comment strings.
// When filtering the newlines, the lines of code are counted
public int countLOC(str code){
	code = filterMultiline(code);
	code = filterSingleline(code);
	//code = removeNewLines(code);
	return filterNewlines(code);
}

// User a regular expression to find the opening of a multiline comment, then exclude everything after this string until the
// closing of the multilines from appending to the result. 
public str filterMultiline(str code){
	str returncode = "";
	first = true;
	
	while(findFirst(code, "/*") != -1){
		str tmpstr = "";
		int positionOpening = findFirst(code, "/*");
		int positionClosing = findFirst(code, "*/");
		if(positionClosing == -1){
			returncode += code[0..positionOpening];
			return returncode;
		}
		returncode += code[0..positionOpening];
		code = code[positionClosing + 2 ..];
	}
	returncode += code;
	return returncode;
}

// Remove a single-line comments by finding a // and excluding everything up to a newline from appending to the returned string
// If the end of a file is found (hence the if statement), return the code.
public str filterSingleline(str code){
	str returncode = "";
	int pos = 0;
	while(findFirst(code, "//") != -1){
		str tmpstr = "";
		int positionOpening = findFirst(code, "//");
		int positionClosing = findFirst(code[positionOpening..], "\n") + positionOpening;
		if(positionClosing == -1){
			return returncode;
		}
		else{
			returncode += code[pos..positionOpening] + "\n";
			code = code[positionClosing + 1 ..];
		}
	}
	returncode += code;
	return returncode;
}

// Remove all of the white spacing from the code (empty lines), if the remaining line is larger then 2, the line
// is counted as a line of code, the reasoning behind this is that we do not believe a trailing }; affects maintainability.
// As these small lines could have been appended to the previous line, depending on style.
public int filterNewlines(str code){
	returncode = "";
	int num_lines = 0;
	for(/<sentence: (.*)>[\r\n]/ := code){
		if (/\S/ := sentence){
			sentence = trim(sentence);
			returncode += sentence + "\n";
			num_lines += 1;
		}
	}
	return num_lines;
}

// Clean a code string, remove multiline comments, single line comments, newlines, and lines smaller than 2 characters 
// (we believe }; is not important for mainainability)
public str cleanCode(str code){
	code = filterMultiline(code);
	code = filterSingleline(code);
	code = removeNewLines(code);
	return code;
}

// remove newlines from a string and lines shorter than 2 characters
public str removeNewLines(str code){
	returncode = "";
	for(/<sentence: (.*)>[\r\n]/ := code){
		if (/\S/ := sentence){
			sentence = trim(sentence);
			returncode += sentence + "\n";
		}
	}
	return returncode;

}

public int countLinesFile(loc a){
	str code = readFile(a);
	return countLOC(code);
}

// debug funtion, count lines of code, and print them
public void countLines(loc a){
	int num_lines = walkFiles(a);
	println(num_lines);
	
}




