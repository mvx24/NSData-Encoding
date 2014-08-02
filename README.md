NSData+Encoding
-------------------------------

NSData categories for hex, base64, and gzip encoding. Both OS X and iOS compatible.

## NSData+Encoding Reference

#### Hex Encoding

`- (NSString *)hexString`

Returns a hex string representation of the data.

##### Base64 Encoding

`- (NSString *)base64String`

Returns a base64 encoded string of the data. The appropriate amount of = padding is also provided.

`+ (NSData *)dataWithBase64String:(NSString *)base64String`

Creates a new NSData object from a base64 encoded string. The correct amount of = padding is expected.

## NSData+gzip

This category is in a separate file from the other functions because it requires linking with zlib.  

`- (NSData *)gzipDeflatedData`

Creates a new NSData object containing the gzip compressed contents of the receiver. This method uses zlib to perform gzip compression optimized for space not speed. It also uses a single call to `deflate` with a bounded buffer that is larger than necessary, since the intention of this function is to create a temporary NSData object that gets immediately saved to disk or uploaded.

## License

The BSD License
