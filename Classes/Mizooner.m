//
//  Mizooner.m
//  Mizoon
//
//  Created by Daryoush Paknad on 10/5/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import "Mizooner.h"


@implementation Mizooner

@synthesize name, profile;



- (id)init {
    self = [super init];
	
    return self;
}

- (void)dealloc {
	[name release];
	[profile release];
    [super dealloc];
}

- (id) initWithName: (NSString *) userName userProfile: (NSDictionary *)  personDict
{
	if (self = [super init]) {
		name = [[NSString alloc] initWithString: userName];
		profile = [[MizoonerProfiles alloc] initWithDictionary:personDict];	
	}
	return self;
}


- (BOOL) setMizoonerProfile: (NSDictionary *)  personDict
{
	profile = [[MizoonerProfiles alloc] initWithDictionary:personDict];	
	
	return TRUE;
}

@end
