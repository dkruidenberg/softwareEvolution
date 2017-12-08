module test_suite::functionTests

import type_1;
import IO;

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