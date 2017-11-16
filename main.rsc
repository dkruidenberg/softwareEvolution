module main
import IO;
import unitComplexity;
import count_loc;

void main(){
	loc location = |project://smallsql0.21_src|;
	int volume = walkFiles(location);
	int volumeScore = mapVolume(volume);
	
}


int mapVolume(int volume){
	if(volume <= 66000){ return 2; }
	if(volume <= 246000){ return 1; }
	if(volume <= 655000){ return 0; }
	if(volume <= 1310000) { return -1; }
	else { return -2; }
}

int mapUnitSize(){}


int mapCyclom(int volume, list[int] comps, list[int] locs){
	int mod_risk = 0;
	int high_risk = 0;
	int insane_risk = 0;
	
	int loc_mod = 0;
	int loc_high = 0;
	int loc_insane = 0;
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
	mod_risk = loc_mod / total_loc;
	high_risk = loc_high / total_loc;
	insane_risk = loc_insane / total_loc;
	return mapComplexityValues(mod_risk, high_risk, insane_risk);
}

int mapComplexityValues(int modr, int high, int insane){
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




