
<cfif CGI.REQUEST_METHOD EQ "POST">
    <cfscript>
    auth = new authenticator.GoogleAuthenticator();
    key = auth.generateKey(form.password);
    </cfscript>
</cfif>
<form action="" method="POST">
    <label for="email">Email: <input type="text" name="email" id="email" /></label>
    <label for="password">Password: <input type="password" name="password" id="password" /></label>
    <input type="submit" value="Generate" />
</form>

<cfif isDefined("key")>
    <cfoutput><p>Your secret key is: #key#</p></cfoutput>
    <div id="qrcode"></div>
    <script src="qrcode.min.js"></script>
    <cfoutput><script>new QRCode(document.getElementById('qrcode'), #auth.getOTPURLForKey(form.email, key)#);</script></cfoutput>
    <p><a href="sample_check.cfm?secret=<cfoutput>#key#</cfoutput>">Check token</p>
</cfif>