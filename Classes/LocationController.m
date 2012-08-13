//
//  LocationController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 2/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocationController.h"
#import	"MizDataManager.h"

#define	MAX_ATTEMPTS		4
#define	MAX_LOCATION_AGE	20	// sec


@interface  LocationController(Private)
- (void) testCoord;
@end

@implementation LocationController

@synthesize locationManager, delegate, haveNewLocation, locationChanged;

- (id) init {
    self = [super init];
    if (self != nil) {
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; //kCLLocationAccuracyBest;
		self.locationManager.distanceFilter = kCLDistanceFilterNone;	// get updates if user has moved more than a mile
		self.locationManager.delegate = self;			// Always send location updates to myself.
		
		haveNewLocation = NO;
		[self setHaveLocation:NO];
    }
    return self;
}

- (BOOL)haveLocation {
	return haveLocation;
}

- (void)setHaveLocation:(BOOL)input {
	haveLocation = input;
}


- (void) alertUserNoLocation
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location" message:@"Please set your location preference to yes" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[alert show];
	[alert release];
}


- (void) testCoord
{
	MizDataManager *dm = [MizDataManager sharedDataManager];

	if (dm.currentLocation != nil)
		[dm.currentLocation release];
	
//	CLLocation *tmpLocation = [[CLLocation alloc] initWithLatitude:37.447231543895796 longitude:-122.16552257537842];  // Downtown palo alto
//	CLLocation *tmpLocation = [[CLLocation alloc] initWithLatitude:39.49132430037711 longitude:-100.2008056640625];  // some where in Idaho
//	CLLocation *tmpLocation = [[CLLocation alloc] initWithLatitude:37.453592 longitude:-122.182505];  // Cafe Barrone
	CLLocation *tmpLocation = [[CLLocation alloc] initWithLatitude:37.36722 longitude:-121.92597];  // San jose airport
	
	
	[MizDataManager sharedDataManager].currentLocation = [tmpLocation retain];	
	
	haveNewLocation = YES;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Location_Coord" object:(id)dm];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	
	
#if 0
	[self	testCoord];
	return;
#endif

	
	// Called whenever we receive a GPS location update.
	[self setHaveLocation:YES];
	
	MizDataManager *dm = [MizDataManager sharedDataManager];
	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];

	attempts++;    
	
#if 1
	if (dm.currentLocation) {
		MizoonLog(@"Loc Update- New Lat=%f lon=%f Accu=%f\nCurLat=%f CurLon=%f Acc=%f age=%f atmp=%d\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude, 
			  newLocation.horizontalAccuracy, dm.currentLocation.coordinate.latitude, dm.currentLocation.coordinate.longitude, 
			  dm.currentLocation.horizontalAccuracy, locationAge, attempts);
	} else {
		MizoonLog(@"-->Loc Update- New lat=%f lon=%f acu=%f age=%f atmp=%d\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude, 
			  newLocation.horizontalAccuracy, locationAge, attempts);
	}	
#endif
	
//	// If the current location data we have is a less than a minute old, return it
//	MizoonLog(@"---------Current coord Age=%f  Accuracy=%f", [dm.currentLocation.timestamp timeIntervalSinceNow],dm.currentLocation.horizontalAccuracy );
//
//	if (dm.currentLocation && (-[dm.currentLocation.timestamp timeIntervalSinceNow] < 60) && (dm.currentLocation.horizontalAccuracy < HORIZONTAL_ACCURACY)) {
//		MizoonLog(@"CURRENT LOCATION IS GOOD.  < a minute");
//		attempts = 0;
//		[manager stopUpdatingLocation];
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Location_Coord" object:(id)dm];
//		return;
//	}
	
	
	if ( signbit(newLocation.horizontalAccuracy) || !newLocation ) // bad location data. horizontalAccuracy is negative!
	{
		MizoonLog(@"ERROR- IPHONE LOCATION UNAVAILABLE");
		return;
	} 
	
	dm.currentLocation = nil;
	
	if (locationAge > MAX_LOCATION_AGE) 
	{

		if (attempts >=3) {
			attempts = 0;
			
			if (dm.currentLocation != nil)
				[dm.currentLocation release];
			
			dm.currentLocation = [newLocation retain];
			haveNewLocation = YES;
			
			//		if (newLocation.horizontalAccuracy < 50.0) 
			[manager stopUpdatingLocation];
			
			MizoonLog(@"USING OLD LOC DATA- Lat=%f lon=%f Accu=%f Acc=%f age=%f atmp=%d\n", dm.currentLocation.coordinate.latitude, 
				  dm.currentLocation.coordinate.longitude,  dm.currentLocation.horizontalAccuracy, locationAge, attempts);

			[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Location_Coord" object:(id)dm];
		}
		return;
	}

	
	if ( (dm.currentLocation == nil || (dm.currentLocation.horizontalAccuracy > newLocation.horizontalAccuracy)) ) {
	
		if (newLocation.horizontalAccuracy > HORIZONTAL_ACCURACY) {
			if (attempts < MAX_ATTEMPTS) {
				MizoonLog(@"\n\n\t ------------------BAD ACCURACY = %f number of tries=%d---------------",newLocation.horizontalAccuracy, attempts );
				return;
			}
		}
		MizoonLog(@"====> NEW LOC DATA - lat=%f lon=%f hAccuracy=%f Num Tries=%d\n", 
			  newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.horizontalAccuracy, attempts);
		
		
		attempts = 0;
		
		if (dm.currentLocation != nil)
			[dm.currentLocation release];
		
		dm.currentLocation = [newLocation retain];
		haveNewLocation = YES;

//		if (newLocation.horizontalAccuracy < 50.0) 
			[manager stopUpdatingLocation];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Location_Coord" object:(id)dm];
		return;
	}
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	
	// Called whenever we receive a GPS location failure.
	[self setHaveLocation:NO];
	
#ifdef MIZOON_DEBUG
	UIAlertView *alert;

	NSString *errorType = (error.code == kCLErrorDenied) ? @"Access Denied" : @"Unknown Error";
	MizoonLog(@"+++++++++++++++++++++++++++++++++++++++++++++++locationManager: %@  error code=%d", errorType, error.code );

//	[manager stopUpdatingLocation];
	MizoonLog(@"error%@",error);
	switch([error code])
	{
		case kCLErrorNetwork: // general, network-related error
			alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please check your network connection or that you are not in airplane mode" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
			break;
			
		case kCLErrorDenied:
			alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"User has denied to use current Location " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
			break;
		case kCLErrorHeadingFailure:
			alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Location heading could not be determined" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
			break;
		case kCLErrorLocationUnknown:
			alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"location is currently unknown, but CL will keep trying" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
			break;			break;

		default: 
			alert = [[UIAlertView alloc] initWithTitle:@"Location Error"
								  message:@"There was a problem updating your location. Please try again."
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
	}
#endif
}


- (void)getLocation 
{
	// Tell LocationController to start updating its location
	[self.locationManager startUpdatingLocation];
//	[self.locationManager startUpdatingHeading];
//	[self.locationManager startMonitoringSignificantLocationChanges];
}


- (void)dealloc {
    [self.locationManager release];
    [super dealloc];
}

@end