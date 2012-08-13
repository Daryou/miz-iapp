//
//  MizXMLParser.m
//  Mizoon
//
//  Created by Daryoush Paknad on 3/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MizXMLParser.h"


@implementation MizXMLParser
@synthesize	message, sessionID;

- (id) init {
	self = [super init];
	
	return self;
}


- (BOOL) parseXMLString: (NSString *) xmlCode {
	
	NSData *resData = [[NSString stringWithFormat:@"%@", xmlCode] dataUsingEncoding:NSUTF8StringEncoding];
	
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:resData];
	[xmlParser setDelegate:self];
	[xmlParser setShouldProcessNamespaces:NO];
	[xmlParser setShouldReportNamespacePrefixes:NO];
	[xmlParser setShouldResolveExternalEntities:NO];
	
	if (xmlParser == nil)
		return FALSE;
	
	
	[xmlParser parse];
	NSError *parseError = [xmlParser parserError];
	if (parseError) 
		return FALSE;
	
	return TRUE;
}



#pragma mark - NSXMLParser

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	NSString * elmValue = [currentValue stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
 	
	if ([elementName isEqualToString:@"name"] && [elmValue isEqualToString:@"sessid"]) {
		sessionID = elmValue;
		currentValue = nil;
		
		return;
	}
	if ([elementName isEqualToString:@"string"] && [sessionID isEqualToString:@"sessid"]) {
		sessionID = currentValue;
		currentValue = nil;
		
		return;
	}
	if ([elementName isEqualToString:@"name"] && [elmValue isEqualToString:@"message"]) {
		message = elmValue;
		currentValue = nil;
		
		return;
	}
	if ([elementName isEqualToString:@"string"] && [message isEqualToString:@"message"]) {
		message = currentValue;
		currentValue = nil;
		
		return;
	}
	[currentValue release];
	currentValue = nil;
	
//	NSLog(@"endElem - elemName=%@  qName=%@ \n\n", elementName, qName);
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"name"]) {
		currentElem = [[NSString alloc] initWithString:elementName];
	}
//	NSLog(@"StartElem - elemName=%@  qName=%@", elementName, qName);
	
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (!currentValue) 
		currentValue = [[NSMutableString alloc] init];
	
	[currentValue appendString:string];
//	NSLog(@"%@", string);
	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	NSLog(@"MizXMLParser - inside parseErrorOccured");
}

- (void) dealloc {
	[super dealloc];
//	[currentValue release];
//	[currentElem release];
}



@end
