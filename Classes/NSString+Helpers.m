//
//  NSString+Helpers.m
//  WordPress
//
//  Created by John Bickerstaff on 9/9/09.
//  
//

#import "NSString+Helpers.h"
#import "NSData+Base64.h"

@implementation NSString (Helpers)

#pragma mark Helpers
- (NSString *) stringByUrlEncoding
{
	return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)self,  NULL,  (CFStringRef)@"!*'();:@&=+$,/?%#[]",  kCFStringEncodingUTF8);
}

- (NSString *)base64Encoding
{
	NSData *stringData = [self dataUsingEncoding:NSUTF8StringEncoding];
	NSString *encodedString = [stringData base64EncodedString];

	return encodedString;
}


-(NSString*) unescape:(NSString*)string
{
    NSMutableString *unescapedString = [[NSMutableString alloc] initWithString:string];
    [unescapedString replaceOccurrencesOfString:@"&apos;" withString:@"'" options:0 range:NSMakeRange(0, [unescapedString length])];
    [unescapedString replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, [unescapedString length])];
    [unescapedString replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:0 range:NSMakeRange(0, [unescapedString length])];
    [unescapedString replaceOccurrencesOfString:@"&gt;" withString:@">" options:0 range:NSMakeRange(0, [unescapedString length])];
    [unescapedString replaceOccurrencesOfString:@"&lt;" withString:@"<" options:0 range:NSMakeRange(0, [unescapedString length])];
    return [unescapedString autorelease];
}


@end