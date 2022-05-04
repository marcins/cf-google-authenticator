I use the [Google Authenticator](https://support.google.com/accounts/answer/1066447?hl=en) app as an additional security measure for my Google account. When Dropbox added support I realised it wasn't just a Google thing. I finally thought I'd look at what it takes to implement a Google Authenticator "compliant" service.  Turns out it's not too hard, and it's all standards based.

For the impatient, here's the [CF Google Authenticator](https://github.com/marcins/cf-google-authenticator) Github repo.

So for the details: These 2 standards are involved in the Google Authenticator implementation:

* [RFC-6238](http://tools.ietf.org/html/rfc6238) *TOTP: Time-Based One-Time Password Algorithm*
* [RFC-4226](http://tools.ietf.org/html/rfc4226) *HOTP: An HMAC-Based One-Time Password Algorithm*

The first is actually a specific implementation of the second, and what Google Authenticator tokens are based on.

HOTP is conceptually simple - you take the HMAC-SHA-1 of a shared secret key, and a counter. You then do some bit twiddling with the resulting 160-bit (20 byte) hash to get it down to a 4-byte number, from which you then extract a 6-digit number which is your token.

TOTP is a particular implementation of HOTP, where the counter is based on the number of seconds since the UNIX Epoch. Specifically it's how many X second periods have there been since the epoch, where X is 30 seconds in Google's case. This is why the number changes every 30 seconds.

So anyway, the actual derivation of the current token value from the secret is only a few lines of code, but there was some additional complexity to implementing this in ColdFusion.
<!-- More -->
## Base32

The Secret Key that is required for the Google Authenticator app is encoded in Base32. This is a less common relation of Base64, but it's a lot easier to type in manually as it only includes uppercase letters and numbers. Base32 is defined in [RFC-4648](http://tools.ietf.org/html/rfc4648) *The Base16, Base32, and Base64 Data Encodings*.

There is a Java based Base32 implementation in [Apache Commons Codec](http://commons.apache.org/proper/commons-codec/), however it was only added in v1.5.  Adobe ColdFusion 10 bundles Apache Commons Codec, but unforutnately it's only v1.3.  So if I wanted to use the library I'd have to include it and use a JavaLoader. In fact my first implementation did this, but I deicded to go for the extra challenge of implementing Base32 myself.

## Java Crypto

This code also makes heavy use of [Java Crypto](http://docs.oracle.com/javase/6/docs/api/javax/crypto/package-summary.html), and so needs to put stuff into byte arrays and other native Java types.  In retrospect the whole project might've been better implemented as a Java library that could just be loaded, in fact there probably already is one. However I treated this as more of a learning exercise, and challenged myself to do it entirely in native CF. It's definitely easier to implement being a single CFC without any dependencies on external JARs.

## QR Codes

The Google Authenticator app allows you to add your account by scanning a QR Code. I wanted to do this for my Proof of Concept / Demo, and it turns out there's a neat little Javascript library for doing it called (funnily enough) [qrcode.js](http://davidshimjs.github.io/qrcodejs/). It's got wide browser support by using canvas where available, and HTML tables where it's not.

## ColdFusion quirks

ColdFusion isn't really designed for bit twiddling - even in cfscript there aren't the usual bitwise operators and shifts, you have to use functions. There's also no hex constants, so you need to convert stuff to decimal. Still, I guess CF isn't really a general purpose language but web specific, so the demand for these types of operations is probably fairly low.

An example, it means you tend to be a bit more verbose:

```cfm
byte = bitSHLN(bitAnd(this.DECODE_TABLE[encodedBytes[i + 4]], 1), 7);
byte2 = bitSHLN(this.DECODE_TABLE[encodedBytes[i + 5]], 2);
byte3 = bitSHRN(this.DECODE_TABLE[encodedBytes[i + 6]], 3);
decodedBytes.write(bitOr(bitOr(byte, byte2), byte3));
```

instead of being able to do the more typical:

```java
decodedBytes.write(
    (this.DECODE_TABLE[encodedBytes[i + 4]] & 0x1) << 7 |
    (this.DECODE_TABLE[encodedBytes[i + 5]] << 2) |
    (this.DECODE_TABLE[encodedBytes[i + 6]] >> 3));
```

There was also a fair bit of casting, and using Java classes in order to get things into (mainly) native `byte[]` arrays.

As I said though, as a learning exercise it was definitely interesting to explore some of the lesser used parts of CF, and refresh my bitwise operator math. There was even a piece of paper and pen involved in working some of it out!