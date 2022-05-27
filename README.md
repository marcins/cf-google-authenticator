## Updates
I've updated the CFC in a couple of ways

* I've removed the native CF solution in favour of the Apache Commons Codec to implement Base32 encoding/decoding
* Added new function getOTPQRURL() which return the a QR code URL you can put straight in to an image tag

## Intro

This is a ColdFusion native implementation of RFC6238 (TOTP: Time-Based One-Time Password Algorithm)  specifically designed to work with the Google Authenticator app. You can use this for providing Two Factor Authentication for your applications.

It has been tested on Adobe Coldfusion 10 because that's what I run locally. It uses a few Java classes and bit twiddling, so YMMV on Lucee/Railo. It should work on CF9, I don't think I've done anything CF10 specific - but feel free to do a Pull Request if there's a small change required to make this work on CF9 or Lucee/Railo!

## Background

Roughly speaking the Google Authenticator system works by using a shared secret, and a time interval. The time interval is simply the number of 30 second intervals that have passed since the UNIX epoch (1/1/1970).  The shared secret, at least as far as what is required for the Google Authenticator client, is a Base32 encoding of an 80-bit value.

To use the Google Authenticator in your own app you would do something like:

* when a user turns on Two Factor Authentication you generate the secret using the `generateKey` function, you must pass a string that is used as the base for the key, as well as optionally a 16-byte salt. If you omit the salt then Java's `SecureRandom` generator is used to generate one (this is recommended). You would use something unique to the user as the password - ideally you would get them to verify their password and use this, since you're not storing this.
* store the key in the database against the user record - you will need this when you want to verify the One Time Password (OTP) the user has entered
* the Google Authenticator app allows you to enter a new token using either manual entry or a QRCode - there is a function `getOTPURL` that takes an email address (or other user identifier) and the user's secret key and returns a URL you can encode into a QRCode. There's a sample in the project that uses a Javascript based QRCode generator.
* when you want to verify the user's token you get the value from the user and then can use `verifyGoogleToken` - this takes the secret you will have saved in the database, the value the user has entered and a grace period. A boolean will be returned.  The grace period is the number of previous values for the token that are allowed. This is useful when the user enters their token just as it ticks over, or they have a slight clock mismatch compared to your server. Generally you'd only allow a grace of 1 or 2 at most.

The `index.cfm` file mentions a blog post that no longer exists, I've put the [contents of that blog](blog.md) into this repo.

## Implementation notes

This version uses Apache Commons Codec to implement Base32 encoding/decoding which will make it incompativle with ACF10.

## Notes on security

* This should only be used as verification of a user's login, not as a primary authentication mechanism.
* Never display the expected value of the user's token

## Samples

There's a simple sample in the project where you can generate a secret key and then see the token values for that key (and compare to the Authenticator app). This sample is definitely *not* best practice or recommended to be used for anything other than playing around.

## Tests

There are some [mxunit](http://mxunit.org/) based tests that can be run from `/tests/index.cfm`.  They assume that mxunit is mapped at the server level to /mxunit.  If we had Lucee/Railo CLI I could make them not depend on a web server!

## Licence

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
