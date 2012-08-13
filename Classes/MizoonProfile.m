//
//  MizoonProfile.m
//  Mizoon
//
//  Created by Daryoush Paknad on 6/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MizoonProfile.h"


@implementation MizoonProfile
@synthesize name, value, type, displayed;



- (id)init {
    self = [super init];
	
    return self;
}

- (void)dealloc {
	[name release];  //XXXX
	[value release]; //XXXX

    [super dealloc];
/*	
	// uid, user name, pic and friend are statically allocated
	if ([name rangeOfString:PERSON_UID options:NSCaseInsensitiveSearch].length == 0 && 
		[name rangeOfString:PERSON_USER_NAME options:NSCaseInsensitiveSearch].length == 0 &&
		[name rangeOfString:PERSON_PICTURE options:NSCaseInsensitiveSearch].length == 0 &&
		[name rangeOfString:PERSON_FRIEND options:NSCaseInsensitiveSearch].length == 0 ) {
		
		[value release];
		[name release];
		
	}
//	[name release];
//	[value release];
 */
}


@end
