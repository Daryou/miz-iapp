//
//  MizoonerProfiles.h
//  Mizoon
//
//  Created by Daryoush Paknad on 6/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	"MizoonProfile.h"

@interface MizoonerProfiles : NSObject {
	NSMutableArray *profiles;
}

- (id)initWithDictionary:(NSDictionary *) profilesDict;
- (MizoonProfile *) getNextProfileOfType: (int) profileType;
- (MizoonProfile *) getProfileValue: (NSString *) attr;
- (NSString *) getProfileAttrValue: (NSString *) attr;
- (BOOL) hasPersonalAttributes;

- (void) printProfiles;

@end
