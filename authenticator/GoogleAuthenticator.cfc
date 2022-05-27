/*
The MIT License (MIT)

Copyright (c) 2013 Marcin Szczepanski

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
component output="false" {

    public function init(){
        return this;
    }

    /**
    * Verifies the submitted value from the user against the user secret, with optional grace for the last few
    * token values
    *
    * @param base32secret the Base32 encoded shared secret key
    * @param userValue the value that the user submitted
    * @param grace the amount of previous tokens to allow (1 means allow the current and last token value)
    * @return a boolean whether the token was valid or not
    */
    public boolean function verifyGoogleToken (required string base32Secret, required string userValue, numeric grace = 0)
    {
        for (var i = 0; i <= grace; i++)
        {
            var expectedToken = getGoogleToken(base32Secret, -i, getCurrentTime());
            if (expectedToken == userValue) {
                return true;
            }
        }
        return false;
    }

    /**
    * Gets the value of the token for a particular offset from the current time interval
    *
    * @param base32secret the Base32 encoded shared secret key
    * @param offset the number of intervals from the current one to use (defaults to the current time interval)
    * @return a string containing the token for the specified offset interval
    */
    public string function getGoogleToken (required string base32Secret, numeric offset = 0)
    {
        var intervals = JavaCast("long", Int((getCurrentTime() / 1000) / 30) + arguments.offset);
        return getOneTimeToken(arguments.base32Secret, intervals);
    }

    /**
    * Returns a URL that can be used in a QR code with the Google Authenticator app
    *
    * @param email the email address of the user account
    * @param key the Base32 encoded secret key to use in the code
    */
    public string function getOTPURL(required string email, required string key)
    {
        return 'otpauth://totp/#arguments.email#?secret=#arguments.key#';
    }

    public string function getOTPQRURL(required string OTPURL){
      local.qrURL = "https://chart.googleapis.com/chart?chs=200x200&cht=qr&chl=200x200&chld=M|0&cht=qr&chl=";
      return local.qrURL & arguments.OTPURL;
    }

    /**
    * The core TOTP function that gets the current value of the token for a particular secret key and numeric counter
    *
    * @param base32secret the Base32 encoded secret key
    * @param counter the counter value to use
    * @return a string representing the current token value
    */
    public string function getOneTimeToken (required string base32Secret, required numeric counter)
    {
        var key = base32decode(arguments.base32Secret);
        var secretKeySpec = createObject("java", "javax.crypto.spec.SecretKeySpec" ).init(key, "HmacSHA1");
        var mac = createObject("java", "javax.crypto.Mac").getInstance(secretKeySpec.getAlgorithm());
        mac.init(secretKeySpec);
        var buffer = createObject("java", "java.nio.ByteBuffer").allocate(8);
        buffer.putLong(arguments.counter);
        var h = mac.doFinal(buffer.array());
        var t = h[20];
        if (t < 0) t += 256;
        var o = bitAnd(t, 15) + 1;

        t = h[o + 3];

        if (t < 0) t += 256;
        var num = t;
        t = h[o + 2];
        if (t < 0) t += 256;
        num = bitOr(num, bitSHLN(t, 8));

        t = h[o + 1];
        if (t < 0) t += 256;
        num = bitOr(num, bitSHLN(t, 16));

        t = h[o];
        if (t < 0) t += 256;
        num = bitOr(num, bitSHLN(t, 24));

        num = bitAnd(num, 2147483647) % 1000000;

        return numberFormat(num, "000000");
    }

    /**
    * Generates a Base32 encoded secret key for use with the token functions
    *
    * @param password a password to be used as the seed for the secret key
    * @param salt a Java byte[16] array containing a salt - if left blank a random salt will be generated (recommended)
    * @return the Base32 encoded secret key
    */
    public string function generateKey (required string password, array salt = [])
    {
        if (arrayLen(salt) == 0)
        {
            var secureRandom = createObject("java", "java.security.SecureRandom").init();
            var buffer = createObject("java", "java.nio.ByteBuffer").allocate(16);
            arguments.salt = buffer.array();
            secureRandom.nextBytes(arguments.salt);
        }
        else if(arrayLen(salt) != 16)
        {
            throw(message="Salt must be byte[16]", errorcode="GoogleAuthenticator.BadSalt");
        }

        var keyFactory = createObject("java", "javax.crypto.SecretKeyFactory").getInstance("PBKDF2WithHmacSHA1");
        var keySpec = createObject("java", "javax.crypto.spec.PBEKeySpec").init(arguments.password.toCharArray(), salt, 128, 80);
        var secretKey = keyFactory.generateSecret(keySpec);
        return Base32encode(secretKey.getEncoded());
    }

    /**
    * A native Base32 encoder (see RFC4648 http://tools.ietf.org/html/rfc4648)
    *
    * Might not be the most efficient implementation. There is a version available
    * via the Apache Commons Codec, however this was only added in v1.5 and CF10 includes v1.3.
    *
    * I didn't want to create a dependency on JavaLoader or similar just for one simple(ish) encoder.
    *
    * @param array of Java byte[] to be encoded
    * @return a Base32 encoded string
    *
    */
    public string function Base32encode (required any inputBytes)
    {
      return createObject("java", "org.apache.commons.codec.binary.Base32").encodeToString( arguments.inputBytes );

    }

    /**
    * Convenience function for creating a Base32 encoding of a string
    */
    public string function Base32encodeString (required any string)
    {
        return base32encode(string.getBytes());
    }
    /**
    * Decodes a Base32 encoded string
    * @param encoded the encoded string to decode
    * @return a byte[] array of decoded values
    */
    public any function base32decode (required string encoded)
    {
      return createObject("java", "org.apache.commons.codec.binary.Base32").decode( arguments.encoded );
    }

    /**
    * Convenience function for decoding a Base32 string to a string
    */
    public string function Base32decodeString (required any string, string encoding = "utf-8")
    {
        return charsetEncode(base32decode(string), encoding);
    }

    private numeric function getCurrentTime()
    {
        return createObject("java", "java.lang.System").currentTimeMillis();
    }
}