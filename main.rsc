module main
import IO;
import unitComplexity;
import unitSize;
import count_loc;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::ValueUI;
import List;

void main(){
	loc location = |project://smallsql0.21_src|;
	int volume = walkFiles(location);
	int volumeScore = mapVolume(volume);
	list[list[int]] tmp = calculateComplexityUnitSize(location);
	list[int] comps = tmp[0];
	list[int] locs = tmp[1];
	int cyclom = mapCyclom(comps, locs);
	
}


int mapVolume(int volume){
	if(volume <= 66000){ return 2; }
	if(volume <= 246000){ return 1; }
	if(volume <= 655000){ return 0; }
	if(volume <= 1310000) { return -1; }
	else { return -2; }
}

int mapUnitSize(){
	


}
//tresholds from http://www.cs.uu.nl/docs/vakken/apa/20140617-measuringsoftwareproductquality.pdf
int mapUnitSizeHelper(real modr, real high, real insane){
	if(modr <= 19.5 && high == 10.9 && insane == 3.9){
		return 2;
	}
	if(modr <= 26.0 && high <= 15.5 && insane == 6.5){
		return 1;
	}
	if(modr <= 34.1 && high <= 22.2 && insane == 11.0){
		return 0;
	}
	if(modr <= 45.9 && high <= 31.3 && insane <= 18.1){
		return -1;
	}
	else{
		return -2;
	}
}

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




