//
//  NSString+Util.h
//  NSString+Util
//
//  Created by Daryoush Paknad on 12/16/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface NSString (Util)

- (bool)isEmpty;
- (NSString *)trim;
- (BOOL) hasWhitespace;

@end
