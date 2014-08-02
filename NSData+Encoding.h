//
//  NSData+Encoding.h
//
//  Copyright 2014 Symbiotic Software. All rights reserved.
//

@interface NSData (Encoding)

- (NSString *)hexString;
- (NSString *)base64String;
+ (NSData *)dataWithBase64String:(NSString *)base64String;

@end
