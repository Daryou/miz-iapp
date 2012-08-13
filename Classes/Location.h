//
//  Location.h
//  Mizoon1
//
//  Created by Daryoush Paknad on 6/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Location : NSObject {
	NSString	*name;
	NSString	*address;
	NSString	*city;
	NSString	*state;
	NSString	*zip;
	NSString	*country;
	NSString	*phone;
	NSString	*email;
	NSString	*website;
	NSString	*category;
	NSString	*lat;
	NSString	*lon;
	
	NSString	*lid;
	NSString	*guid;
	NSUInteger	type;
}


- (id) initWithDictionary:(NSDictionary *) locationDict;



@property (nonatomic, retain) NSString	*name;
@property (nonatomic, retain) NSString	*address;
@property (nonatomic, retain) NSString	*city;
@property (nonatomic, retain) NSString	*state;
@property (nonatomic, retain) NSString	*zip;
@property (nonatomic, retain) NSString	*country;
@property (nonatomic, retain) NSString	*phone;
@property (nonatomic, retain) NSString	*email;
@property (nonatomic, retain) NSString	*website;
@property (nonatomic, retain) NSString	*category;
@property (nonatomic, retain) NSString	*lat;
@property (nonatomic, retain) NSString	*lon;

@property (nonatomic, retain) NSString	*guid;
@property (nonatomic, retain) NSString	*lid;

@property NSUInteger type;

@end
