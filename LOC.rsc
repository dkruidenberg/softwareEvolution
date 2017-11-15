module LOC

import lang::java::jdt::m3::Core;
// m = createM3FromEclipseProject(|project://smallsql0.21_src|);
import IO;
import String;


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

public int countLOC(str code){
	code = filterMultiline(code);
	code = filterSingleline(code);
	return filterNewlines(code);
}

public str filterMultiline(str code){
	str returncode = "";
	while(findFirst(code, "/*") != -1){
		str tmpstr = "";
		int positionOpening = findFirst(code, "/*");
		int positionClosing = findFirst(code, "*/");
		returncode += code[0..positionOpening];
		code = code[positionClosing + 2 ..];
	}
	returncode += code;
	return returncode;
}

public str filterSingleline(str code){
	str returncode = "";
	int pos = 0;
	while(findFirst(code, "//") != -1){
		str tmpstr = "";
		int positionOpening = findFirst(code, "//");
		int positionClosing = findFirst(code[positionOpening..], "\n") + positionOpening;
		returncode += code[pos..positionOpening] + "\n";
		code = code[positionClosing + 1 ..];
	}
	returncode += code;
	return returncode;
}

public int filterNewlines(str code){
	returncode = "";
	int num_lines = 0;
	for(/<sentence: (.*)>[\r\n]/ := code){
		if (/\S/ := sentence){
			if(size(sentence) > 0){
				returncode += sentence + "\n";
				num_lines += 1;
			}
		}
	}
	return num_lines;
}

public void countLines(loc a){
	int num_lines = walkFiles(a);
	println(num_lines);
	
}