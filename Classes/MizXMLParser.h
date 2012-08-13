//
//  MizXMLParser.h
//  Mizoon
//
//  Created by Daryoush Paknad on 3/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000 
@interface MizXMLParser : NSObject <NSXMLParserDelegate> 
#else
@interface MizXMLParser: NSObject
#endif
{
	NSString		*currentElem;
	NSMutableString	*currentValue;

	NSString		*sessionID;
	NSString		*message;
}

@property (nonatomic, retain) NSString *sessionID;
@property (nonatomic, retain) NSString *message;

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (BOOL) parseXMLString: (NSString *) xmlCode;

@end
