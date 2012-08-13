//
//  NSString (PercentEscape).m
//  Mizoon
//
//  Created by daryoush paknad on 8/3/12.
//  Copyright (c) 2012 Mizoon. All rights reserved.
//


#import "NSString+PercentEscape.h"


@implementation NSString (PercentEscape)

- (NSString *)stringWithPercentEscape {
    return [(NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                NULL,
                                                                (CFStringRef)[[self mutableCopy] autorelease],
                                                                NULL,
                                                                CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"),
                                                                kCFStringEncodingUTF8) autorelease];
}

@end