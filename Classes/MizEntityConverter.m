//
//  MizEntityConverter.m
//  Mizoon
//
//  Created by Daryoush Paknad on 2/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MizEntityConverter.h"
#import	"Constants.h"

@implementation MizEntityConverter
@synthesize resultString;

- (id)init
{
    if([super init]) {
        resultString = [[NSMutableString alloc] init];
    }
    return self;
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)s {
	[self.resultString appendString:s];
}


- (NSString*)convertEntiesInString:(NSString*)s {
    if(s == nil) {
        MizoonLog(@"ERROR : Parameter string is nil");
    }
    NSString* xmlStr = [NSString stringWithFormat:@"<d>%@</d>", s];
    NSData *data = [xmlStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSXMLParser* xmlParse = [[NSXMLParser alloc] initWithData:data];
    [xmlParse setDelegate:self];
    [xmlParse parse];
    NSString* returnStr = [[NSString alloc] initWithFormat:@"%@",resultString];
	
//	[xmlStr	release];
//	[data	release];
	[xmlParse	release];
	
    return returnStr;
}


- (void)dealloc {
//	NSLog(@"ref count entity converter = %d", [resultString retainCount]);
    [resultString release];
//	NSLog(@"ref count entity converter = %d", [resultString retainCount]);

    [super dealloc];
}


@end
