//
//  NSData+Base64.h
//  Mizoon
//
//  Created by Daryoush Paknad on 2/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

void *NewBase64Decode(
	const char *inputBuffer,
	size_t length,
	size_t *outputLength);

char *NewBase64Encode(
	const void *inputBuffer,
	size_t length,
	bool separateLines,
	size_t *outputLength);
	
@interface NSData (Base64)
	
+ (NSData *)dataFromBase64String:(NSString *)aString;
- (NSString *)base64EncodedString;
	
@end