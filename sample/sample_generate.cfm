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
<cfif CGI.REQUEST_METHOD EQ "POST">
    <cfscript>
    auth = new authenticator.GoogleAuthenticator();
    key = auth.generateKey(form.password);
    otpurl = auth.getOTPURL(required string email, required string key);
    otpqrurl = auth.getOTPQRURL( otpurl );
    </cfscript>
</cfif>
<form action="" method="POST">
    <label for="email">Email: <input type="text" name="email" id="email" /></label>
    <label for="password">Password: <input type="password" name="password" id="password" /></label>
    <input type="submit" value="Generate" />
</form>

<cfif isDefined("key")>
    <cfset >
    <cfoutput><p>Your secret key is: #key#</p></cfoutput>
    <cfoutput><img src="#otpqrurl#" alt=""></cfoutput>
    <p><a href="sample_check.cfm?secret=<cfoutput>#key#</cfoutput>">Check token</p>
    <p><a href="sample_verify.cfm?secret=<cfoutput>#key#</cfoutput>">Verify token</p>
</cfif>