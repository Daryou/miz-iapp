//
//  MizoonUser.m
//  Mizoon
//
//  Created by Daryoush Paknad on 4/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MizoonUser.h"




@implementation MizoonUser
@synthesize userId, checkedin, at, points;

static MizoonUser *sharedMizooner;


- (id)init {
    self = [super init];

    return self;
}

- (void)dealloc {
    [super dealloc];
}


+ (id)alloc {
	//	@synchronized(self)
    {
        NSAssert(sharedMizooner == nil, @"Attempted to allocate a second instance of a singleton.");
        sharedMizooner = [super alloc];
        return sharedMizooner;
    }
}

+ (id)copy {
	//	@synchronized(self)
    {
        NSAssert(sharedMizooner == nil, @"Attempted to copy the singleton.");
        return sharedMizooner;
    }
}



+ (MizoonUser *)sharedMizooner {
    if (!sharedMizooner) {
        sharedMizooner = [[MizoonUser alloc] init];
    }
	
    return sharedMizooner;
}

@end
