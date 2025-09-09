public class randomNameGenerator {
    public static String firstName(){
		final String chars = 'abcdefghijklmnopqrstuvwxyzcdefghababcdefghijklmnopqrstuvwxyz';
		String firstNameSelected;
		String firstName = '';
		integer len = 5;
		while (firstName.length() < len) {
		   Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
		   firstName += chars.substring(idx, idx+1);
		   firstNameSelected = firstName.substring(0,1).toUpperCase() + firstName.substring(1,firstName.length());
		}
	return firstNameSelected;
    }
    
    public static String lastName(){
		final String chars = 'abcdefghijklmnopqrstuvwxyzcdefghababcdefghijklmnopqrstuvwxyz';
		String lastNameSelected;
		String lastName = '';
		integer len = 6;
		while (lastName.length() < len) {
		   Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
		   lastName += chars.substring(idx, idx+1);
		   lastNameSelected = lastName.substring(0,1).toUpperCase() + lastName.substring(1,lastName.length());
			system.System.debug('this is name');
		}
	return lastNameSelected;
    }
}