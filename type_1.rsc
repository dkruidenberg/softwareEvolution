module type_1

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import count_loc;
import String;
import List;
import Set;
import Map;
import IO;


// TODO return an array with clone line numbers with their files? 
void type_1_statistics(loc location){
	int x = countDuplication(location);
	println(x);
}

//main function
void countDuplication(loc location){
	ast = createAstFromFile(|project://SoftwareEvolution/src/test_suite/type1test.java|, true);
	println(ast);
}








