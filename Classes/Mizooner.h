//
//  Mizooner.h
//  Mizoon
//
//  Created by Daryoush Paknad on 10/5/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	"MizoonerProfiles.h"

@interface Mizooner : NSObject {
	NSString			*name;
	MizoonerProfiles	*profile;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) MizoonerProfiles *profile;

- (id) initWithName: (NSString *) userName userProfile: (NSDictionary *)  personDict;
- (BOOL) setMizoonerProfile: (NSDictionary *)  personDict;

@end
