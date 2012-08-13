//
//  NSString+Util.m
//  NSString+Util
//
//  Created by Daryoush Paknad on 12/16/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "NSString+Util.h"


@implementation NSString (Util)

- (bool)isEmpty {
    return self.length == 0;
}

- (NSString *)trim {
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}


- (BOOL) hasWhitespace
{
	//  Return whether I contain any whitespace.
	NSCharacterSet *    wsSet =
	[NSCharacterSet whitespaceCharacterSet] ;
	unsigned            i, iLimit = [ self length] ;
	for (i = 0; i < iLimit; i++)
		if ([wsSet characterIsMember:
			 [self characterAtIndex: i] ] )
			return YES;
	return NO;
}

@end
