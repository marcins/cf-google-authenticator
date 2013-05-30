<cfparam name="url.secret" default="">
<p><strong>Warning! You would never expose the user's secret value like this, nor would you ever display the "expected" value of the token. This is purely an example so you can see your Google Authenticator is returning the same value for the secret.</strong></p>
<cfif secret EQ "">
    <form action="" method="GET">
        <label for="secret"><input type="text" name="secret" value="" />
        <input type="submit" value="Check Secret" />
    </form>
<cfelse>
    <cfscript>
    auth = new authenticator.GoogleAuthenticator();
    value = auth.getGoogleToken(url.secret);
    lastValue = auth.getGoogleToken(url.secret, -1);
    </cfscript>
    <cfoutput>
    <p>Current value: #value#</p>
    <p>Last value: #lastValue#</p>
    </cfoutput>
</cfif>