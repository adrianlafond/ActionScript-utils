package com.disbranded.validators {
	
	public class EmailAddress {


	   /**
		* Checks whether an email address is valid.
		* 
		* <p>Based on <a href="http://www.markussipila.info/pub/emailvalidator.php">http://www.markussipila.info/pub/emailvalidator.php</a></p>
		*
		* @param emailToCheck The email address to check for validity.
		* @param checkRare If false, will check an email address as 99% of users would expect.
		* If true, allows for oddball characters that are technically valid but which so rarely
		* used in email addresses that they are more likely to be typos.
		* 
		* @return <code>true</code> if <code>emailToCheck</code> is valid.
		*/
	    public static function getValid(emailToCheck:String, checkRare:Boolean = false):Boolean {
	        var format:RegExp;
	        if (!checkRare) {
	            format = new RegExp("^[a-z0-9_.-]+@[a-z0-9.-]+[.][a-z]{2,4}$", "gi");
	        } else {
	            format = new RegExp("^[a-z0-9,!#$%&'*+/=\?\^_`\|}~-]+([.][a-z0-9,!#$%&'*+/=?^_`{|}~-]+)*@[a-z0-9-]+([.][a-z0-9-]+)*[.]([a-z]{2,})$", "gi");
	        }
	        var result:Array = RegExp.match(format, str);
	        if (result==null || result.length != 1) {
	            return false;
	        }
	        return true;
	    }
	}
}

