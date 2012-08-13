//
//  MizoonServer.h
//  Mizoon
//
//  Created by Daryoush Paknad on 12/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJSON.h"



@interface MizoonServer : NSObject  {
	NSMutableData	*receivedData;
	NSString		*name;
	NSString		*password;
}
+ (MizoonServer *)sharedMizoonServer;

@property (nonatomic, retain) NSMutableData	*receivedData;
@property (nonatomic, retain) NSString		*name;
@property (nonatomic, retain) NSString		*password;


- (NSArray *) nearbyPlacesWithLongitude: (double) lon latitude: (double) lat radius: (int) radius atIndex: (int) index numberToRet:(int)num_ret;
- (NSArray *) nearbyPeopleWithLongitude: (double) lon latitude: (double) lat radius: (int) radius atIndex: (int) index numberToRet:(int)num_ret;


@end
