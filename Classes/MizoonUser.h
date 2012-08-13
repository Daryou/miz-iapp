//
//  MizoonUser.h
//  Mizoon
//
//  Created by Daryoush Paknad on 4/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	"MizoonLocation.h"
	

@interface MizoonUser : NSObject {
	BOOL			checkedin;
	NSString		*userId;
	NSUInteger		points;
	MizoonLocation	*at;
}

+ (MizoonUser *)sharedMizooner;

@property  NSUInteger points;
@property  BOOL checkedin;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) MizoonLocation *at;

@end
