component extends="mxunit.framework.TestCase" output="false" {

    public void function setUp ()
    {
        variables.auth = new authenticator.GoogleAuthenticator();
    }

    public void function testGenerateKeyBasic ()
    {
        var key = auth.generateKey("blah");
        assertEquals(16, Len(key));
    }

    public void function testGenerateKeyCustomSalt ()
    {
        var badSalt = javaCast("byte[]", [0, 0]);
        try {
            var key = auth.generateKey("blah", badSalt);
            assertFail("Should not get here");
        } catch(any e) {
            assertEquals("GoogleAuthenticator.BadSalt", e.errorCode);
        }

        var goodSalt = charsetDecode("1234567890123456", "utf-8");
        var key = auth.generateKey("password", goodSalt);
        assertEquals("D5NJOIFNXEB4DL7M", key);
    }

    public void function testGetToken ()
    {
        var token = auth.getOneTimeToken("D5NJOIFNXEB4DL7M", 0);
        assertEquals("731217", token);
    }

    public void function testGetGoogleToken ()
    {
        var token = auth.getGoogleToken("D5NJOIFNXEB4DL7M", 0, 0);
        assertEquals("731217", token);
    }
}
