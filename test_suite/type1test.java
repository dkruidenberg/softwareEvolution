package test_suite;
import hallo;
public class type1test {
	public void main2() {
		int a = 10;
		if (a > 10) {
			a = 11;
		}
		if (a > 10) {
			a = 11;
		}
		
	}
	public void main3() {
		int a = 10;
		if (a > 10) {
			a = 11;
		}
		if (a > 10) {
			a = 11;
		}
		main2();
		main2();
	}

}
