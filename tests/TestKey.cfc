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

    private numeric function returnTimeZero()
    {
        return 0;
    }

    private numeric function returnTimeKnown()
    {
        return 1000;
    }

    public void function testGetToken ()
    {
        var token = auth.getOneTimeToken("D5NJOIFNXEB4DL7M", 0);
        assertEquals("731217", token);
    }

    public void function testGetGoogleToken ()
    {
        injectMethod(auth, this, "returnTimeZero", "getCurrentTime");
        var token = auth.getGoogleToken("D5NJOIFNXEB4DL7M");
        assertEquals("731217", token);
    }

    public void function testVerifyToken ()
    {
        injectMethod(auth, this, "returnTimeZero", "getCurrentTime");
        assertFalse(auth.verifyGoogleToken("D5NJOIFNXEB4DL7M", "000000", 0), "Expected invalid value to fail");
        assertTrue(auth.verifyGoogleToken("D5NJOIFNXEB4DL7M", "731217", 0), "Expected known value to succeed");
        assertFalse(auth.verifyGoogleToken("D5NJOIFNXEB4DL7M", "434975", 0), "Expected last value to fail with no grace");
        assertTrue(auth.verifyGoogleToken("D5NJOIFNXEB4DL7M", "434975", 1), "Expected last value to succeed with grace");
        assertTrue(auth.verifyGoogleToken("D5NJOIFNXEB4DL7M", "434975", 2), "Expected last value to succeed with excess grace");
    }

    public void function testOTPURL()
    {
        assertEquals("otpauth://totp/test@example.com?secret=D5NJOIFNXEB4DL7M", auth.getOTPURL("test@example.com", "D5NJOIFNXEB4DL7M"));
    }
}
