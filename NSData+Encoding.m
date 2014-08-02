//
//  NSData+Encoding.m
//
//  Copyright 2014 Symbiotic Software. All rights reserved.
//

#import "NSData+Encoding.h"

static char *encodeBase64(const void *restrict data, size_t size, size_t *length);
static void *decodeBase64(const char *restrict base64Str, size_t length, size_t *size);

@implementation NSData (Encoding)

- (NSString *)hexString
{
	NSMutableString *hexString;
	const unsigned char *bytes;
	size_t i, length;
	
	length = [self length];
	if(!length)
		return [NSString string];
	
	bytes = [self bytes];
	hexString = [NSMutableString stringWithCapacity:length * 2];
	for(i = 0; i < length; ++i)
		[hexString appendFormat:@"%02x", *(bytes + i)];
	return [NSString stringWithString:hexString];
}

- (NSString *)base64String
{
	size_t length;
	char *base64Str = encodeBase64([self bytes], [self length], &length);
	return [[[NSString alloc] initWithBytesNoCopy:base64Str length:length encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
}

+ (NSData *)dataWithBase64String:(NSString *)base64String
{
	size_t size;
	void *data = decodeBase64([base64String UTF8String], [base64String length], &size);
	return [NSData dataWithBytesNoCopy:data length:size freeWhenDone:YES];
}

@end

#pragma mark - Internal base64 functions

static unsigned char _base64EncodeTable[65] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static char *encodeBase64(const void *restrict data, size_t size, size_t *length)
{
	char *encoded;
	uint32_t decoded;
	size_t i, j;
	
	if(!data || !length)
		return NULL;
	
	// Calculate the length by rounding up to nearest group of 3
	if((size % 3) == 1)
		*length = (size + 2)/3;
	else if((size % 3) == 2)
		*length = (size + 1)/3;
	else
		*length = size/3;
	*length *= 4;

	encoded = (char *)malloc(sizeof(char) * (*length + 1));
	encoded[*length] = 0;
	for(i = 0; (i * 3) < (size - (size % 3)); ++i)
	{
		decoded = ((uint32_t)((uint8_t *)data)[(i * 3)]) << 16;
		decoded |= ((uint32_t)((uint8_t *)data)[(i * 3) + 1]) << 8;
		decoded |= ((uint32_t)((uint8_t *)data)[(i * 3) + 2]);
		for(j = 0; j < 4; ++j)
			encoded[(i * 4) + j] = _base64EncodeTable[(decoded >> (18 - (j * 6))) & 0x3F];
	}
	
	if((size % 3) == 1)
	{
		encoded[*length - 1] = '=';
		encoded[*length - 2] = '=';
		decoded = ((uint8_t *)data)[size - 1];
		encoded[*length - 3] = _base64EncodeTable[(decoded << 4) & 0x3F];
		encoded[*length - 4] = _base64EncodeTable[(decoded >> 2) & 0x3F];
	}
	else if((size % 3) == 2)
	{
		encoded[*length - 1] = '=';
		decoded = ((uint32_t)((uint8_t *)data)[size - 1]);
		decoded |= ((uint32_t)((uint8_t *)data)[size - 2] << 8);
		encoded[*length - 2] = _base64EncodeTable[(decoded << 2) & 0x3F];
		encoded[*length - 3] = _base64EncodeTable[(decoded >> 4) & 0x3F];
		encoded[*length - 4] = _base64EncodeTable[(decoded >> 10) & 0x3F];
	}
	return encoded;
}

// Indices: + - 43, / - 47, 0 - 48, A - 65, a - 97
static uint8_t _base64DecodeTable[123] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,62,0,0,0,63,52,53,54,55,56,57,58,59,60,61,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,0,0,0,0,0,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51};

static void *decodeBase64(const char *restrict base64Str, size_t length, size_t *size)
{
	size_t i, j;
	uint8_t *decodedBytes;
	unsigned char encoded;
	uint32_t decoded;
	
	if(!base64Str || length % 4 || !size)
		return NULL;
	
	// Calculate the decoded size
	*size = (length/4) * 3;
	if(base64Str[length - 2] == '=')
		*size -= 2;
	else if(base64Str[length - 1] == '=')
		*size -= 1;
	
	// Decode
	decodedBytes = (uint8_t *)malloc(*size);
	for(i = 0; (i * 4) < length; ++i)
	{
		decoded = 0;
		for(j = 0; j < 4; ++j)
		{
			encoded = base64Str[(i * 4) + j];
			if(encoded == '=')
				break;
			else if(encoded >= (sizeof(_base64DecodeTable)/sizeof(*_base64DecodeTable)))
			{
				free(decodedBytes);
				return NULL;
			}
			decoded = (decoded << 6) | _base64DecodeTable[encoded];
		}
		if(j == 2)
		{
			decodedBytes[(i * 3)] = (uint8_t)((decoded >> 4) & 0xFF);
		}
		else if(j == 3)
		{
			decodedBytes[(i * 3) + 1] = (uint8_t)((decoded >> 2) & 0xFF);
			decodedBytes[(i * 3)] = (uint8_t)((decoded >> 10) & 0xFF);
		}
		else
		{
			decodedBytes[(i * 3) + 2] = (uint8_t)(decoded & 0xFF);
			decodedBytes[(i * 3) + 1] = (uint8_t)((decoded >> 8) & 0xFF);
			decodedBytes[(i * 3)] = (uint8_t)((decoded >> 16) & 0xFF);
		}
	}
	return decodedBytes;
}
