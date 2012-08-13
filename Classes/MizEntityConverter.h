//
//  MizEntityConverter.h
//  Mizoon
//
//  Created by Daryoush Paknad on 2/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000 
@interface MizEntityConverter : NSObject <NSXMLParserDelegate> 
#else
@interface MizEntityConverter: NSObject
#endif
{
	NSMutableString* resultString;
}
@property (nonatomic, retain) NSMutableString* resultString;
- (NSString*)convertEntiesInString:(NSString*)s;



//@interface MizEntityConverter : NSObject <NSXMLParserDelegate> {
//	NSMutableString* resultString;
//}
//@property (nonatomic, retain) NSMutableString* resultString;
//- (NSString*)convertEntiesInString:(NSString*)s;


@end

