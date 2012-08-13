//
//  Location.m
//  Mizoon1
//
//  Created by Daryoush Paknad on 6/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Location.h"
#define	LOCATION_DICTIONARY_TYPE_YAHOO	1	// YAHOO


@implementation Location
@synthesize	name, address, city, state, zip, country, phone, email, website, category, lat, lon, guid, lid, type;




- (id)initWithDictionary:(NSDictionary *) locationDict {
	
	if (self = [super init]) {

#ifdef(LOCATION_DICTIONARY_TYPE == 1)
		name = [[locationDict valueForKey:@"meta"] valueForKey:@"name"];
		category = [[locationDict valueForKey:@"meta"] valueForKey:@"type"];
		guid = [locationDict valueForKey:@"guid"];

		lon = [[[[locationDict valueForKey:@"meta"] valueForKey:@"geom"] valueForKey:@"coordinates"] objectAtIndex:0];
		lat = [[[[locationDict valueForKey:@"meta"] valueForKey:@"geom"] valueForKey:@"coordinates"] objectAtIndex:1];
#else
		name = [[locationDict valueForKey:@"meta"] valueForKey:@"name"];
		category = [[locationDict valueForKey:@"meta"] valueForKey:@"type"];
		guid = [locationDict valueForKey:@"guid"];
		
		lon = [[[[locationDict valueForKey:@"meta"] valueForKey:@"geom"] valueForKey:@"coordinates"] objectAtIndex:0];
		lat = [[[[locationDict valueForKey:@"meta"] valueForKey:@"geom"] valueForKey:@"coordinates"] objectAtIndex:1];	
#endif

    }
	
    return self;
}



@end
