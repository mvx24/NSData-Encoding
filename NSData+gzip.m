//
//  NSData+gzip.m
//
//  Copyright 2014 Symbiotic Software. All rights reserved.
//

#import "NSData+gzip.h"
#include <zlib.h>

@implementation NSData (gzip)

- (NSData *)gzipDeflatedData
{
	z_stream stream;
	size_t size;
	unsigned char *output;
	int res;

	if(![self length])
		return self;

	stream = (z_stream){.next_in = (Bytef *)[self bytes], .avail_in = [self length]};
	// 15 for high compression, +16 for gzip
	if(deflateInit2(&stream, Z_BEST_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK)
		return nil;
	size = deflateBound(&stream, [self length]);
	output = malloc(size);
	stream.next_out = output;
	stream.avail_out = size;
	res = deflate(&stream, Z_FINISH);
	deflateEnd(&stream);
	if(res == Z_STREAM_END)
		return [NSData dataWithBytesNoCopy:output length:stream.total_out freeWhenDone:YES];
	else
		free(output);
	return nil;
}

@end
