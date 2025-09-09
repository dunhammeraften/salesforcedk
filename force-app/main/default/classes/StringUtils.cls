/**
 * Created by Mujahid on 02/11/2022
 */

public class StringUtils {
	public static String makeRandomStringFromCharacterSet(Integer len, string characterList) {
		String randStr = '';
		while (randStr.length() < len) {
			Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), characterList.length());
			randStr += characterList.substring(idx, idx + 1);
		}
		return randStr;
	}

	public static String makeRandomStringNoNumerics(Integer len) {
		return makeRandomStringFromCharacterSet(len, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz');
	}

	public static String makeRandomInteger(Integer len) {
		return makeRandomStringFromCharacterSet(len, '1234567890');
	}
}