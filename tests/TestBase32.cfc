component extends="mxunit.framework.TestCase" output="false" {

    public void function setUp ()
    {
        variables.auth = new authenticator.GoogleAuthenticator();
    }

    public void function testBase32Deccode ()
    {
        assertEquals("", auth.base32decodeString(""));
        assertEquals("f", auth.base32decodeString("MY======"));
        assertEquals("fo", auth.base32decodeString("MZXQ===="));
        assertEquals("foo", auth.base32decodeString("MZXW6==="));
        assertEquals("foob", auth.base32decodeString("MZXW6YQ="));
        assertEquals("fooba", auth.base32decodeString("MZXW6YTB"));
        assertEquals("foobar", auth.base32decodeString("MZXW6YTBOI======"));
    }

    public void function testBase32Encode ()
    {
        assertEquals("", auth.base32encodeString(""));
        assertEquals("MY======", auth.base32encodeString("f"));
        assertEquals("MZXQ====", auth.base32encodeString("fo"));
        assertEquals("MZXW6===", auth.base32encodeString("foo"));
        assertEquals("MZXW6YQ=", auth.base32encodeString("foob"));
        assertEquals("MZXW6YTB", auth.base32encodeString("fooba"));
        assertEquals("MZXW6YTBOI======", auth.base32encodeString("foobar"));
    }

    public void function testBase32EncodeEdge ()
    {
        var bytes = javaCast("byte[]", [0, 0, 0, 0, 0]);
        assertEquals("AAAAAAAA", auth.base32encode(bytes));
    }

    public void function testBase32DecodeEdge ()
    {
        var dec = auth.base32decode("AAAAAAAA");
        assertEquals(5, arrayLen(dec));
        for (var i = 1; i <= 5; i++)
        {
            assertEquals(0, dec[i]);
        }

    }

}