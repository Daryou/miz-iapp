//
//  location.h
//  Mizoon
//
//  Created by Daryoush Paknad on 4/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>



#import <FactualSDK/FactualAPI.h>
#import <FactualSDK/FactualQuery.h>


#define	LOCATION_DICTIONARY_TYPE_YAHOO	1	// YAHOO


@interface MizoonLocation : NSObject {
	NSString	*name;
	NSString	*description;
	NSString	*image;
	NSString	*icon;
	NSString	*address;
	NSString	*city;
	NSString	*state;
	NSString	*zip;
	NSString	*country;
	NSString	*phone;
	NSString	*email;
	NSString	*website;
	NSString	*category;
	NSString	*subCategory;
	NSString	*type;
	NSString	*features;

	NSString	*review;
	NSString	*distance;			// distance from the user 

	NSString	*guid;				// geoAPI

	float		latitude;
	float		longitude;
	NSUInteger	lid;
	NSUInteger	numVisitors;
	
	CLLocationCoordinate2D coords;
	NSDictionary *listing;
}
- (MizoonLocation *) initLocation: (NSDictionary *) feed;
+ (MizoonLocation *) simpleGeoLocDict:(NSDictionary *)placeDict;
+ (MizoonLocation *)locationWithDict:(NSDictionary *)placeDict;
+ (MizoonLocation *)initWithLocation:(MizoonLocation *)loc;
+ (MizoonLocation *)locationFromFactualObj:(FactualRow * )factualPlace;
- (MizoonLocation *)initWithFactualObj:(FactualRow *)factualPlace;


@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *zip;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *website;
@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString *subCategory;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *review;
@property (nonatomic, retain) NSString *distance;
@property (nonatomic, retain) NSString *features;
@property (nonatomic, retain) NSString *guid;
@property (nonatomic) CLLocationCoordinate2D coords;
@property (nonatomic, retain) NSDictionary *listing;

@property float latitude;
@property float longitude;
@property NSUInteger lid;
@property NSUInteger numVisitors;

@end
