//
//  Utilities.h
//  Mizoon
//
//  Created by Daryoush Paknad on 6/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	<UIKit/UIKit.h>
#import "MizoonProfile.h"

MizoonProfile * getNextProfile( NSArray * profiles, int profileType);
MizoonProfile * getProfile( NSArray *profiles, NSString *attr);

void printProfiles(NSArray *profiles);
