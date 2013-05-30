<!---
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
--->
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