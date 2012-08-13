//
//  MizoonLocation.m
//  Mizoon
//
//  Created by Daryoush Paknad on 4/2/10.
//  Copyright 2010 Mizoon Inc. All rights reserved.
//

#import "MizoonLocation.h"
#import	"MizEntityConverter.h"
#import	"Mizoon.h"


@interface MizoonLocation (private)
- (MizoonLocation *)initWithDict:(NSDictionary *)placeDict;
- (MizoonLocation *)simpleGeoPlaces:(NSDictionary *)placeDict;
- (MizoonLocation *)copyLocation:(MizoonLocation  *)loc;
@end

@implementation MizoonLocation

@synthesize	name, description, address, image, icon, city, state, zip, phone, website, latitude, longitude, lid, category, review, numVisitors,email,country, guid;
@synthesize subCategory, features, distance, type;
@synthesize listing, coords;



+ (MizoonLocation *) simpleGeoLocDict:(NSDictionary *)placeDict {
	return [[[MizoonLocation alloc] simpleGeoPlaces:placeDict] autorelease];
}


/*
 * { 
 *		geometry = {
 *			coordinates = ( "-122.13295", "37.415919" );
 *			type = Point;
 *		};
 *		id = "SG_3QnSG2hQzhiiU8o9RvoE6Q_37.415919_-122.132950@1294081369";
 *		properties = {
 *			address = "3801 Magnolia Dr";
 *			city = "Palo Alto";
 *			classifiers = ( [
 *					{
 *						category = Professional;
 *						subcategory = "";
 *						type = Services;
 *					},
 *					{
 *						category = Taxi;
 *						subcategory = "Transportation";
 *						type = Services;
 *					}, 
 *			);
 *			country = US;
 *			href = "http://api.simplegeo.com/1.0/features/SG_3QnSG2hQzhiiU8o9RvoE6Q_37.415919_-122.132950@1294081369.json";
 *			name = Tropochem;
 *			owner = simplegeo;
 *			website = "www.foo.com"
 *			phone = "+1 650 856 1255";
 *			postcode = 94306;
 *			province = CA;
 *		};
 *		type = Feature;
 * },
*/ 
- (MizoonLocation *)simpleGeoPlaces:(NSDictionary *)placeDict {
	self = [super init];
	if (self != nil) {
		self.listing = [placeDict objectForKey:@"properties"];
		
		if ([self.listing objectForKey:@"name"] != [NSNull null])
			self.name = [self.listing objectForKey:@"name"];
		
		if ([self.listing objectForKey:@"address"]  != [NSNull null])
			self.address = [self.listing objectForKey:@"address"];

		if ([self.listing objectForKey:@"city"]  != [NSNull null])
			self.city = [self.listing objectForKey:@"city"];

		if ([self.listing objectForKey:@"province"]  != [NSNull null])
			self.state = [self.listing objectForKey:@"province"];

		if ([self.listing objectForKey:@"postcode"]  != [NSNull null])
			self.zip = [self.listing objectForKey:@"postcode"];

		if ([self.listing objectForKey:@"country"]  != [NSNull null])
			self.country = [self.listing objectForKey:@"country"];

		if ([self.listing objectForKey:@"phone"]  != [NSNull null] )
			self.phone = [self.listing objectForKey:@"phone"];
				
		if ((NSNull *)[self.listing objectForKey:@"listing-url"] != [NSNull null])
			self.website = [self.listing objectForKey:@"listing-url"];
	
		if ([placeDict objectForKey:@"id"] != [NSNull null])
			self.guid = [placeDict objectForKey:@"id"];
		
		if ([placeDict objectForKey:@"distance-from-origin"] != [NSNull null])   // XXX don't have this - need to calculate it
			self.distance = (NSString *) [placeDict objectForKey:@"distance-from-origin"];
		
		
		
		NSArray	*verticals = [self.listing objectForKey:@"classifiers"];
		NSDictionary *classifier=nil;

		if ([verticals isKindOfClass:[NSArray class]]) {
			
			if (verticals && [verticals count] >= 1) {
				classifier = [[self.listing objectForKey:@"classifiers"] objectAtIndex:0];
				
				if (classifier) {
					self.category =  [classifier objectForKey:@"category"];
					self.subCategory =  [classifier objectForKey:@"subcategory"];
					self.type =  [classifier objectForKey:@"type"];
				}
			}
			
		} else {
			classifier = [self.listing objectForKey:@"classifiers"];

			if (classifier) {
				self.category =  [classifier objectForKey:@"category"];
				self.subCategory =  [classifier objectForKey:@"subcategory"];
				self.type =  [classifier objectForKey:@"type"];
			}
		}
		
		NSDictionary *geometry = [placeDict objectForKey:@"geometry"];
		NSArray *geomCoords = [geometry objectForKey:@"coordinates"];

		coords.latitude = [[geomCoords objectAtIndex:1] doubleValue];
		coords.longitude = [[geomCoords objectAtIndex:0] doubleValue];   
		self.latitude = self.coords.latitude;
		self.longitude = self.coords.longitude;  
		
		self.icon = [[Mizoon sharedMizoon] getIconForLoction: name catrgory: category subType: subCategory];
		
	}
	return self;
}




+ (MizoonLocation *)locationFromFactualObj:(FactualRow* )factualPlace {
	return [[[MizoonLocation alloc] initWithFactualObj:factualPlace] autorelease];
}



- (MizoonLocation *)initWithFactualObj:(FactualRow *)factualPlace {
	self = [super init];
	if (self != nil) {
		
		if ([factualPlace valueForName:@"name"] != [NSNull null])
			self.name = [factualPlace valueForName:@"name"];
		
		if ([factualPlace valueForName:@"factual_id"] != [NSNull null])
			self.guid = [factualPlace valueForName:@"factual_id"];
		
//		if ([placeDict objectForKey:@"distance-from-origin"] != [NSNull null])
//			self.distance = (NSString *) [placeDict objectForKey:@"distance-from-origin"];
		
		if ([factualPlace valueForName:@"address"] != [NSNull null])
			self.address = [factualPlace valueForName:@"address"];
	
        if ([factualPlace valueForName:@"locality"] != [NSNull null])
			self.city = [factualPlace valueForName:@"locality"];

        if ([factualPlace valueForName:@"region"] != [NSNull null])
			self.state = [factualPlace valueForName:@"region"];

        if ([factualPlace valueForName:@"postcode"] != [NSNull null])
			self.zip = [factualPlace valueForName:@"postcode"];
    
        if ([factualPlace valueForName:@"tel"] != [NSNull null])
			self.phone = [factualPlace valueForName:@"tel"];
        
        if ([factualPlace valueForName:@"website"] != [NSNull null])
			self.website = [factualPlace valueForName:@"website"];
 
        if ([factualPlace valueForName:@"category"] != [NSNull null])
			self.category = [factualPlace valueForName:@"category"];
        
        
		coords.latitude = [[factualPlace valueForName:@"latitude"]  doubleValue];
		coords.longitude = [[factualPlace valueForName:@"longitude"] doubleValue];   
		self.latitude = self.coords.latitude;
		self.longitude = self.coords.longitude;  
        
		self.icon = [[Mizoon sharedMizoon] getIconForLoction: name catrgory: category subType: subCategory];
        
	}
	return self;
}

+ (MizoonLocation *)locationWithDict:(NSDictionary *)placeDict {
	return [[[MizoonLocation alloc] initWithDict:placeDict] autorelease];
}

- (MizoonLocation *)initWithDict:(NSDictionary *)placeDict {
	self = [super init];
	if (self != nil) {
		self.listing = [placeDict objectForKey:@"view.listing"];
		
		if ([self.listing objectForKey:@"name"] != [NSNull null])
			self.name = [self.listing objectForKey:@"name"];
		
		if ([placeDict objectForKey:@"guid"] != [NSNull null])
			self.guid = [placeDict objectForKey:@"guid"];
		
		if ([placeDict objectForKey:@"distance-from-origin"] != [NSNull null])
			self.distance = (NSString *) [placeDict objectForKey:@"distance-from-origin"];
		
		if ([[self.listing objectForKey:@"address"] objectAtIndex:0] != [NSNull null])
			self.address = [[self.listing objectForKey:@"address"] objectAtIndex:0];
		
		if ([[self.listing objectForKey:@"address"] objectAtIndex:1]  != [NSNull null])
			self.city = [[self.listing objectForKey:@"address"] objectAtIndex:1];
		
		if ([[self.listing objectForKey:@"address"] objectAtIndex:2]  != [NSNull null] )
			self.zip = [[self.listing objectForKey:@"address"] objectAtIndex:2];
		
		// get the state from the guid
		NSArray *guidItems = [self.guid componentsSeparatedByString:@"-"];
		if (guidItems && ([guidItems objectAtIndex:[guidItems count] -2]  != [NSNull null]))
			self.state = [[guidItems objectAtIndex:[guidItems count] -2] retain];
		
		if ([self.listing objectForKey:@"phone"]  != [NSNull null] )
			self.phone = [self.listing objectForKey:@"phone"];
		

		if ((NSNull *)[self.listing objectForKey:@"listing-url"] != [NSNull null])
			self.website = [self.listing objectForKey:@"listing-url"];
		
		
		NSArray	*verticals = [self.listing objectForKey:@"verticals"];
		if ([verticals isKindOfClass:[NSArray class]]) {

			if (verticals && [verticals count] >= 1) {
				NSMutableString *cat = [verticals objectAtIndex:0];
				[cat replaceOccurrencesOfString:@"-" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [cat length])];
			
				//		self.category = [[self.listing objectForKey:@"verticals"] objectAtIndex:0];
				if (cat) 
					self.category = cat;
			
				if ([verticals count] > 1)
					if ([verticals objectAtIndex:1]) 
						self.subCategory = [verticals objectAtIndex:1];
			
			}
		} else {
			if (verticals) 
				self.category = (NSString *) verticals;
		}
		
		NSArray *geomCoords = [[placeDict objectForKey:@"geom"] objectForKey:@"coordinates"];
		coords.latitude = [[geomCoords objectAtIndex:1] doubleValue];
		coords.longitude = [[geomCoords objectAtIndex:0] doubleValue];   
		self.latitude = self.coords.latitude;
		self.longitude = self.coords.longitude;  

		self.icon = [[Mizoon sharedMizoon] getIconForLoction: name catrgory: category subType: subCategory];

	}
	return self;
}



+ (MizoonLocation *)initWithLocation:(MizoonLocation *)loc 
{
	return [[[MizoonLocation alloc] copyLocation:loc] autorelease];
}

- (MizoonLocation *)copyLocation:(MizoonLocation  *)loc {
	self = [super init];
	if (self != nil) {
	
		if (loc.name) 
			self.name = [[NSString	alloc] initWithString:loc.name];

		if (loc.address) 
			self.address = [[NSString	alloc] initWithString:loc.address];
		
		if (loc.city) 
			self.city = [[NSString	alloc] initWithString:loc.city];
		
		if (loc.state) 
			self.state = [[NSString	alloc] initWithString:loc.state];
		
		if (loc.zip) 
			self.zip = [[NSString	alloc] initWithString:loc.zip];
		
		if (loc.country) 
			self.country = [[NSString	alloc] initWithString:loc.country];
		
		if (loc.image) 
			self.image = [[NSString	alloc] initWithString:loc.image];

		if (loc.icon) 
			self.icon = [[NSString	alloc] initWithString:loc.icon];

		if (loc.description) 
			self.description = [[NSString	alloc] initWithString:loc.description];
		
		if (loc.phone) 
			self.phone = [[NSString	alloc] initWithString:loc.phone];
		
		if (loc.website) 
			self.website = [[NSString	alloc] initWithString:loc.website];
		
		if (loc.email) 
			self.email = [[NSString	alloc] initWithString:loc.email];
		
		if (loc.category) 
			self.category = [[NSString	alloc] initWithString:loc.category];
		
		if (loc.subCategory) 
			self.subCategory = [[NSString	alloc] initWithString:loc.subCategory];
		
		if (loc.features) 
			self.features = [[NSString	alloc] initWithString:loc.features];
		
		if (loc.review) 
			self.review = [[NSString	alloc] initWithString:loc.review];

		if (loc.distance) 
			self.distance = [[NSString	alloc] initWithString:loc.distance];
		
		if (loc.guid) 
			self.guid = [[NSString	alloc] initWithString:loc.guid];
		
		self.latitude =loc.latitude;
		self.longitude =loc.longitude;
		self.lid =loc.lid;
		self.numVisitors =loc.numVisitors;
		
		
		CLLocationCoordinate2D tmpCoord = loc.coords;
		tmpCoord.latitude = loc.coords.latitude;
		tmpCoord.longitude = loc.coords.longitude;
		self.coords = tmpCoord;
	}
	return self;
}





- (void)dealloc {
	
//	NSLog(@"=================================name ref count=%d", [name retainCount]);
	[name release];
	[address release];
	[city	release];
	[state	release];
	[zip	release];
	[country	release];
	[image	release];
	[description	release];
	[phone	release];
	[email	release];
	[website	release];
	[category	release];
	[subCategory release];
	[distance	release];
	[guid release];
	[features release];
	[review	release];
	[listing release];

	[super dealloc];
}



- (MizoonLocation *) initLocation: (NSDictionary *) feed {

    if (self = [super init]) {
		
#ifdef LOCATION_DICTIONARY_TYPE_YAHOO

		if ([feed valueForKey:@"loc_name"])
			name =		[[NSString alloc] initWithString:[feed valueForKey:@"loc_name"]];
		
		if ([feed valueForKey:@"address"])
			address =	[[NSString alloc] initWithString:[feed valueForKey:@"address"]];
		
		if ([feed valueForKey:@"city"])
			city =		[[NSString alloc] initWithString:[feed valueForKey:@"city"]];
		
		if ([feed valueForKey:@"state"])
			state =		[[NSString alloc] initWithString:[feed valueForKey:@"state"]];
		
		if ([feed valueForKey:@"zip"])
			zip =		[[NSString alloc] initWithString:[feed valueForKey:@"zip"]];
		
		if ([feed valueForKey:@"country"])
			country	=	[[NSString alloc] initWithString:[feed valueForKey:@"country"]];
		
		if ([feed valueForKey:@"image"])
			image =		[[NSString alloc] initWithString:[feed valueForKey:@"image"]];
		
		if ([feed valueForKey:@"description"]) {
			MizEntityConverter *entityCnvt = [[MizEntityConverter alloc] init];
			NSString *cleanTxt = [entityCnvt convertEntiesInString:[feed valueForKey:@"description"]];
			description = [[NSString alloc] initWithString:cleanTxt];
			[cleanTxt release];
			[entityCnvt release];
		}
		
		if ([feed valueForKey:@"phone"])
			phone =		[[NSString alloc] initWithString:[feed valueForKey:@"phone"]];
		
		if ([feed valueForKey:@"email"])
			email =		[[NSString alloc] initWithString:[feed valueForKey:@"email"]];
		
		if ([feed valueForKey:@"website"])
			website =	[[NSString alloc] initWithString:[feed valueForKey:@"website"]];

		if ([feed valueForKey:@"features"])
			features =	[[NSString alloc] initWithString:[feed valueForKey:@"features"]];

		if ([feed valueForKey:@"guid"])
			guid =	[[NSString alloc] initWithString:[feed valueForKey:@"guid"]];

		if ([feed valueForKey:@"distance"]) {
			NSMutableString *buffer = [[NSMutableString alloc] initWithString:[feed valueForKey:@"distance"]];
			[buffer replaceOccurrencesOfString:@"m" withString:@" meters" options:0 range:NSMakeRange(0, [buffer length])];
			distance =	[[NSString alloc] initWithString:buffer];

//			distance =	[[NSString alloc] initWithString:[feed valueForKey:@"distance"]];
			[buffer release];
		}
		
		if ([feed valueForKey:@"type"]) {
			MizEntityConverter *entityCnvt = [[MizEntityConverter alloc] init];
			NSString *cleanTxt = [entityCnvt convertEntiesInString:[feed valueForKey:@"type"]];
			category =	[[NSString alloc] initWithString:cleanTxt];
			[cleanTxt release];
			[entityCnvt release];
		}
		
		if ([feed valueForKey:@"type2"]) {
			MizEntityConverter *entityCnvt = [[MizEntityConverter alloc] init];
			NSString *cleanTxt = [entityCnvt convertEntiesInString:[feed valueForKey:@"type2"]];
			subCategory =	[[NSString alloc] initWithString:cleanTxt];
			[cleanTxt release];
			[entityCnvt release];
		}

		
		if ([feed valueForKey:@"review"]) {
			MizEntityConverter *entityCnvt = [[MizEntityConverter alloc] init];
			NSString *cleanTxt = [entityCnvt convertEntiesInString:[feed valueForKey:@"review"]];
			review =	[[NSString alloc] initWithString:cleanTxt];
			[cleanTxt release];
			[entityCnvt release];
		}
		
		if ([feed valueForKey:@"lid"])
			lid = [[feed valueForKey:@"lid"] intValue];
		
		if ([feed valueForKey:@"lat"])
			latitude = [[feed valueForKey:@"lat"] floatValue];
		
		if ([feed valueForKey:@"lon"])
			longitude = [[feed valueForKey:@"lon"] floatValue];
		
		if ([feed valueForKey:@"num_visitors"])
			numVisitors = [[feed valueForKey:@"num_visitors"] intValue];
		
		coords.latitude = latitude;
		coords.longitude = longitude;   

		self.icon = [[Mizoon sharedMizoon] getIconForLoction: name catrgory: category subType: subCategory];

#else
		name = [[feed valueForKey:@"meta"] valueForKey:@"name"];
		category = [[feed valueForKey:@"meta"] valueForKey:@"type"];
		guid = [feed valueForKey:@"guid"];
		
		longitude = [[[[[feed valueForKey:@"meta"] valueForKey:@"geom"] valueForKey:@"coordinates"] objectAtIndex:0] floatValue];
		latitude = [[[[[feed valueForKey:@"meta"] valueForKey:@"geom"] valueForKey:@"coordinates"] objectAtIndex:1] floatValue];		
#endif
		
	}
	
	return self;
}


@end
