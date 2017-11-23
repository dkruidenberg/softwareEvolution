/* 	Jordy Bottelier 10747338
	Dennis kruidenberg 10780998
	
	time it takes to run large project: 17:07
	Important decisions:
	
	1. We only count lines of code that have more than 2 characters (excluding whitespaces), we did this because
	we believe trailing accolades or brackets }/) do not impact the maintainability of a piece of code.
	
	2. We did not include constructors in the counting of the unit complexity since we believe constructors should not be used to
	make long methods (even though it is possible).

	3. optimalizations for the duplication: 
			- Only look at methods with # of lines > 6
			- Don't look at the last 5 lines for the beginning of a duplication
			- In the second loop (where we compare the lines with lines of other methods)
			  we only loop at lines that have not been analysed yet. So that the method with index 10 
			  does not get checked against number 8. This because 10 was already checked when we looked at 8.
			  
Duplications: -1
Complexity: -2
unit size Score: -2
volume size score: 1
-------------------------------

analyzability = -2
changeability = -2
testability = -2
-------------------------------

Maintainability = -2
	
*/

module main
import IO;
import unitComplexity;
import count_loc;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::ValueUI;
import List;
import util::Math;
import duplication;
import count_loc;
import util::Benchmark;
import Type;


void main(loc location){
	int startVolume = realTime();
	int volume = walkFiles(location);
	println("Volume : <volume>");
	int volumeScore = mapVolume(volume);
	int volumetime = realTime() - startVolume;

	int startComp = realTime();
	list[list[int]] tmp = calculateComplexityUnitSize(location);
	list[int] comps = tmp[0];
	list[int] locs = tmp[1];
	int cScore = mapCyclom(comps, locs);
	int unitScore =  mapUnitSize(locs);
	int compTime = realTime() - startComp;

	int startDup = realTime();
	int tmp2 = countDuplication(location);
	int dupTime = realTime() - startDup;
	println("Number of duplications: <tmp2>");
	println("Duplication percentage: <tmp2/toReal(sum(locs)) * 100>");
	int dupScore = mapDuplication(toInt(round(toReal(countDuplication(location)) / volume * 100)));
	println("Duplications: <dupScore>");
	println("Complexity: <cScore>");
	println("unit size Score: <unitScore>");
	println("volume size score: <volumeScore>");
	println("-------------------------------\n");
	println("Time per function (seconds):");
	println("Volume time: <volumetime/1000.0>");
	println("Cyclomatic complexity + unit size: <compTime/1000.0>");
	println("Duplication time: <dupTime/1000.0>");
	
	println("-------------------------------\n");
	
	overallMap(volumeScore, cScore, dupScore, unitScore);
}


// Map the duplication scores
int mapDuplication(int score){
	if(score <= 3){ return 2; }
	if(score <= 5){ return 1; }
	if(score <= 10){ return 0; }
	if(score <= 20) { return -1; }
	else { return -2; }
}

// Map all of the score to the maintainability metrics
void overallMap(int volumeScore, int cScore, int dupScore, int unitScore){
	int anal = capValue(volumeScore + dupScore + unitScore);
	int change = capValue(cScore + dupScore);
	int testr = capValue(cScore + unitScore);
	real tot = 3.0;
	int maintain = round((anal + change + testr) / tot);
	println("analyzability = <anal>");
	println("changeability = <change>");
	println("testability = <testr>");
	println("-------------------------------\n");
	println("Maintainability = <maintain>");
}

// Cap the values to -- and ++ (-2 or 2) in case these values are exceeded, since this is possible
int capValue(int val){
	if(val < -2){
		return -2;
	}
	if(val > 2){
		return 2;
	}
	else{
		return val;
	}
}

// Map the total volume of the program to the SIG model score
int mapVolume(int volume){
	if(volume <= 66000){ return 2; }
	if(volume <= 246000){ return 1; }
	if(volume <= 655000){ return 0; }
	if(volume <= 1310000) { return -1; }
	else { return -2; }
}

// Map the unit sizes to their score within the SIG model
int mapUnitSize(list[int] sizes){
	real mod_size = 0.0;
	real high_size = 0.0;
	real insane_size = 0.0;
	real total_loc = 0.0;
	
	for(n <- sizes){
		if(n > 30 && n < 44){
			mod_size += n;
		}
		if(n >= 44 && n <= 74){
			high_size += n;
		}
		if(n > 74){
			insane_size += n;
		}
		total_loc += n;
	}
	mod_size = mod_size / total_loc * 100;
	high_size = high_size / total_loc * 100;
	insane_size = insane_size / total_loc * 100;
	println("\n------------------------------------");
	println("Medium unit size <mod_size>%");
	println("High unit size <high_size>%");
	println("Super High unit size <insane_size>%");
	println("Other: <100 - high_size - mod_size - insane_size>%");
	println("\n------------------------------------");
	return mapUnitSizeHelper(mod_size, high_size, insane_size);
}

// map the unit size value to its score defined in the sig model:
//tresholds from http://www.cs.uu.nl/docs/vakken/apa/20140617-measuringsoftwareproductquality.pdf
int mapUnitSizeHelper(real modr, real high, real insane){
	if(modr <= 19.5 && high <= 10.9 && insane <= 3.9){
		return 2;
	}
	if(modr <= 26.0 && high <= 15.5 && insane <= 6.5){
		return 1;
	}
	if(modr <= 34.1 && high <= 22.2 && insane <= 11.0){
		return -1;
	}
	else{
		return -2;
	}
}

// compute the cyclomatic complexity score and return its mapped values
int mapCyclom(list[int] comps, list[int] locs){
	real mod_risk = 0.0;
	real high_risk = 0.0;
	real insane_risk = 0.0;
	
	real loc_mod = 0.0;
	real loc_high = 0.0;
	real loc_insane = 0.0;
	int total_loc = 0;
	
	for(int n <- [0..(size(comps))]){
		int cur_comp = comps[n];
		int cur_loc = locs[n];
		
		if(cur_comp > 10 && cur_comp < 21){
			loc_mod += cur_loc;
		}
		if(cur_comp > 20 && cur_comp < 51){
			loc_high += cur_loc;
		}
		if(cur_comp > 50){
			loc_insane += cur_loc;
		}
		total_loc += cur_loc;
	}
	mod_risk = loc_mod / total_loc * 100;
	high_risk = loc_high / total_loc * 100;
	insane_risk = loc_insane / total_loc * 100;
	return mapComplexityValues(mod_risk, high_risk, insane_risk);
}

// Map the values for the cyclomatic complexity to their respective scores
// as defined in the paper http://www4.di.uminho.pt/~joost/publications/HeitlagerKuipersVisser-Quatic2007.pdf
int mapComplexityValues(real modr, real high, real insane){
	if(modr <= 25 && high == 0 && insane == 0){
		return 2;
	}
	if(modr <= 30 && high <= 5 && insane == 0){
		return 1;
	}
	if(modr <= 40 && high <= 10 && insane == 0){
		return 0;
	}
	if(modr <= 50 && high <= 15 && insane <= 5){
		return -1;
	}
	else{
		return -2;
	}
}




