package test_suite;
import hallo;
public class type1test {
	public void main2() {
		int a = 10;
		if (a > 12) {
			int c = 10;
			int c = 11;
			a = 11;
		}
	}
	public void main3() {
		int a = 10;
		if (a > 10) {
			int b = 10;
			int c = 11;
			a = 11;
		}
		main2();
	}

}
