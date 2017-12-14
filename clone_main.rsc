module clone_main

import type_1;
import type_2;
import IO;

// TODO add location as argument
void main(){
	int min_clone_size = 6;
	bool type1 = true;
	loc location = |project://smallsql0.21_src|;
	loc location2 = |project://SoftwareEvolution|;
	loc location3 = |project://hsqldb-2.3.1|;
	type_1_statistics(location, min_clone_size, type1);

}

