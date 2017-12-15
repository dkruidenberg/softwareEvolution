module functionTests

import type_1; 
import IO;
import String;

void executeTestsMain(){
	//testGroupIndices;
	//testCloneType1();
	//testFullFileClonesType1();
	testCloneType2();
	//testFullFileClonesType2();
}

// Unit test for grouping the indices
void testGroupIndices(){
	list[int] test1 = [1, 2, 3, 4, 5];
	list[int] test2 = [1, 3, 4, 6];
	list[int] test3 = [1, 3, 5, 7];
	list[int] test4 = [];
	
	test_passed = 0;
	
	if(groupIndices(test1) == [[1,2,3,4,5]]){
		test_passed += 1;
	}
	if(groupIndices(test2) == [[1], [3,4], [6]]){
		test_passed += 1;
	}
	if(groupIndices(test3) == [[1], [3], [5], [7]]){
		test_passed += 1;
	}
	if(groupIndices(test4) == []){
		test_passed += 1;
	}
	println("Groupindices: <test_passed> / 4 tests passed");
}

// Test the type 1 cloning on the test suite
void testCloneType1(){
	// this should be in the resulting file
	result = "int b = 0;
int c = 0;
int d = 0;
int f = 0;

-------- New Clone Class -------------
int a = 0;
int b = 0;
int c = 0;
int d = 0;

-------- New Clone Class -------------
int b = 0;
int c = 0;
int d = 0;

-------- New Clone Class -------------
";
	// execute the test and read from the output
	countDuplication(|project://SoftwareEvolution/src/type1_test_suite/sub_clones|, 3, true);
	if(readFile(|project://SoftwareEvolution/src/clone_classes.text|) == result){
		println("Passed Clone Test - Detected all clones correctly");
	}
	else{
		println("Failed Clone Test - Detected clones incorrectly");
	}
}

void testFullFileClonesType1(){
	countDuplication(|project://SoftwareEvolution/src/type1_test_suite/full_clones|, 3, true);
	num percentage = toReal(readFile(|project://SoftwareEvolution/src/clone_percentage.text|));
	if(percentage != 100){
		println("Test Failed - Two of the same files are not 100% clones ");
	}
	else{
		println("Test Passed - Two of the same files are 100% clones");
	}
}

void testFullFileClonesType2(){
	countDuplication(|project://SoftwareEvolution/src/type2_test_suite/full_clones|, 3, false);
	num percentage = toReal(readFile(|project://SoftwareEvolution/src/clone_percentage.text|));
	if(percentage != 100){
		println("Test Failed - Two of the same files are not 100% clones ");
	}
	else{
		println("Test Passed - Two of the same files are 100% clones");
	}
}

// Test the type 1 cloning on the test suite
void testCloneType2(){
	// this should be in the resulting file
	result = "int a = 0;
String b = \"1\";
int a = 0;
int a = 0;
int a = 0;

-------- New Clone Class -------------
int a = 0;
String b = \"1\";
int a = 0;
int a = 0;
int a = 0;
int a = 0;

-------- New Clone Class -------------
";
	// execute the test and read from the output
	countDuplication(|project://SoftwareEvolution/src/type2_test_suite/sub_clones|, 3, false);
	if(readFile(|project://SoftwareEvolution/src/clone_classes.text|) == result){
		println("Passed Clone Test Type 2 - Detected all clones correctly");
	}
	else{
		println("Failed Clone Test Type 2 - Detected clones incorrectly");
	}
}



