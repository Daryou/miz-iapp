//
//  BlueViewController.m
//  View Switcher
//
//  Created by Daryoush Paknad on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "RootViewController.h"
#import "MizoonServer.h"
#import	"XMLRPCRequest.h"
#import	"XMLRPCResponse.h"
#import	"XMLRPCConnection.h"
#import	"MizoonAppDelegate.h"
#import	"MizDataManager.h"
#import	"MizProgressHUD.h"


@interface MainViewController()  // private methods
//- (id)executeXMLRPCRequest:(XMLRPCRequest *)req byHandlingError:(BOOL)shouldHandleFalg;

@end


@implementation MainViewController
@synthesize rootController;



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	
	rvc.blueViewController = self;
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	MizoonLog(@"---------------> didReceiveMemoryWarning: MainView");
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}





- (void)timeout:(NSTimer*)theTimer {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    MizoonLog(@"Timedout...............................................") ;
	[theTimer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	[[Mizoon sharedMizoon] hideLoadMessage];

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't get your current location" message:@"Can you try again?" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[alert show];
	[alert release];	
	
	[pool release];
}


- (void) failedReguest:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"GEOAPI_Request_Failed" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Places_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Restaurant_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Cafe_Data" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SG_Not_Expected_Return" object:nil];	 


	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Can't connect to server. Can you try again."
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert	release];
	
	[[Mizoon sharedMizoon] hideLoadMessage];

	[pool release];
	
}


- (void) unexpectedReturn:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"GEOAPI_Request_Failed" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Places_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Restaurant_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Cafe_Data" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SG_Not_Expected_Return" object:nil];	 
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
													message:@"Couldn't find the place you were looking for. Please try again in a few minutes."
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert	release];
	
	[[Mizoon sharedMizoon] hideLoadMessage ];
	
	[pool release];
}


-(IBAction) placesButtonPressed:(id) sender 
{
	Mizoon *miz = [Mizoon sharedMizoon];
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];

	miz.clickedView = PLACES_VIEW;
	if (![miz hasNetworkConnection]) {
		[miz networkConnectionAlert];
		return;
	}
	
	[miz showLoadMessage:@"Locating..."];

	if ([miz needToFetchData:PlacesData]) {   

#ifdef MIZOON_DEBUG
		[Mizoon sharedMizoon].methodStart  = [NSDate date];
#endif
		// Register for the notification
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPlaces:) name:@"MZ_Have_Location_Coord" object:nil];
		[miz updateLocation];	
		
		timer = [NSTimer scheduledTimerWithTimeInterval:LOCATION_DETECTION_TIMEOUT 
												 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
		
		//or [self performSelector:@selector(stopUpdatingLocation:) withObject:@"Timed Out" afterDelay:[[setupInfo objectForKey:kSetupInfoKeyTimeout] doubleValue]];

	} else {
		[rvc renderView:PLACES_VIEW fromView: MAIN_VIEW];
	}
}


- (void) getPlaces:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

#ifdef MIZOON_DEBUG
	NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:[Mizoon sharedMizoon].methodStart];
	DebugLog(@"--> loc coord Fetch time=%f", executionTime);
#endif
	[timer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(renderPlaces:) name:@"MZ_Have_Places_Data" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(failedReguest:) name:@"GEOAPI_Request_Failed" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(unexpectedReturn:) name:@"SG_Not_Expected_Return" object:nil];

	[[MizDataManager sharedDataManager] fetchNearbyPlaces:nil];
    
    
	[pool release];
}
	
- (void) renderPlaces:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Places_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"GEOAPI_Request_Failed" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SG_Not_Expected_Return" object:nil];	 

	[[[Mizoon sharedMizoon] getRootViewController] renderView:PLACES_VIEW fromView: MAIN_VIEW];	
	[[Mizoon sharedMizoon] hideLoadMessage];
	
	[pool release];

}
	
	

-(IBAction) peopleNearButtonPressed:(id) sender 
{
	Mizoon *miz = [Mizoon sharedMizoon];
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];

	miz.clickedView = PEOPLE_VIEW;
	if (![miz hasNetworkConnection]) {
		[miz networkConnectionAlert];
		return;
	}
	
	[miz showLoadMessage:@"Locating..."];

	if ([miz needToFetchData:NearbyPeopleData]) {   // if this is the first time
		// Register for the notification
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(havePeopleData:)
													 name:@"MZ_Have_Location_Coord" object:nil];
		
		[miz updateLocation];
		timer = [NSTimer scheduledTimerWithTimeInterval:LOCATION_DETECTION_TIMEOUT
												 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
	} else	{
		[rvc renderView:PEOPLE_VIEW fromView: MAIN_VIEW];
	}
}


- (void) havePeopleData:(NSNotification *)notification 
{
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	MizDataManager *dm = [MizDataManager sharedDataManager];
	
	[timer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	
	MizoonLog(@"\n>>>>>>>>>>>>>>>>>>>> havePeopleData lat=%f lon=%f hAccuracy=%f \n\n", 
		  dm.currentLocation.coordinate.latitude, dm.currentLocation.coordinate.longitude, dm.currentLocation.horizontalAccuracy);

	[rvc renderView:PEOPLE_VIEW fromView: MAIN_VIEW];
//	[[Mizoon sharedMizoon] hideLoadMessage];
}


-(IBAction) postsButtonPressed:(id) sender 
{
	Mizoon *miz = [Mizoon sharedMizoon];
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];

	miz.clickedView = POSTS_VIEW;
	if (![miz hasNetworkConnection]) {
		[miz networkConnectionAlert];
		return;
	}
	
	
	[miz showLoadMessage:@"Locating..."];
	
	if ([miz needToFetchData:NearbyPostsData]) {   // if this is the first time
		// Register for the notification
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(havePostData:)
													 name:@"MZ_Have_Location_Coord" object:nil];
		
		[miz updateLocation];
		timer = [NSTimer scheduledTimerWithTimeInterval:LOCATION_DETECTION_TIMEOUT
												 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
	} else {
		[rvc renderView:POSTS_VIEW fromView: MAIN_VIEW];
	}
}


- (void) havePostData:(NSNotification *)notification 
{
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	[timer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	[rvc renderView:POSTS_VIEW fromView: MAIN_VIEW];
}


-(IBAction) promoButtonPressed:(id) sender 
{
	Mizoon *miz = [Mizoon sharedMizoon];
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	
	miz.clickedView = LOCATIONS_WITH_PROMOTIONS_VIEW;
	if (![miz hasNetworkConnection]) {
		[miz networkConnectionAlert];
		return;
	}
	
	[miz showLoadMessage:@"Locating..."];
	
	if ([miz needToFetchData:LocationsWithPromoData]) {   // if this is the first time
		// Register for the notification
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(havePromoData:)
													 name:@"MZ_Have_Location_Coord" object:nil];
		
		[miz updateLocation];
		timer = [NSTimer scheduledTimerWithTimeInterval:LOCATION_DETECTION_TIMEOUT
												 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
	} else {		
		[rvc renderView:LOCATIONS_WITH_PROMOTIONS_VIEW fromView: MAIN_VIEW];
	}
}

- (void) havePromoData:(NSNotification *)notification 
{
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	[timer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	[rvc renderView:LOCATIONS_WITH_PROMOTIONS_VIEW fromView: MAIN_VIEW];
}




- (IBAction) cafeNearButtonPressed:(id) sender
{
	Mizoon *miz = [Mizoon sharedMizoon];
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	
	miz.clickedView = CAFE_VIEW;
	if (![miz hasNetworkConnection]) {
		[miz networkConnectionAlert];
		return;
	}
	
	[miz showLoadMessage:@"Locating..."];
	
	if ([miz needToFetchData:NearbyCafeData]) {   // if this is the first time
		
#ifdef MIZOON_DEBUG
		[Mizoon sharedMizoon].methodStart  = [NSDate date];
#endif
		// Register for the notification
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getCafeData:)
													 name:@"MZ_Have_Location_Coord" object:nil];
		
		[miz updateLocation];
		timer = [NSTimer scheduledTimerWithTimeInterval:LOCATION_DETECTION_TIMEOUT
												 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
	} else {		
		[rvc renderView:CAFE_VIEW fromView: MAIN_VIEW];
	}
}

- (void) getCafeData:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

#ifdef MIZOON_DEBUG
	NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:[Mizoon sharedMizoon].methodStart];
	DebugLog(@"--> loc coord Fetch time=%f", executionTime);
#endif
	
	[timer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(failedReguest:) name:@"GEOAPI_Request_Failed" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(renderCafes:) name:@"MZ_Have_Cafe_Data" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(unexpectedReturn:) name:@"SG_Not_Expected_Return" object:nil];

	[[MizDataManager sharedDataManager] fetchNearbyCafe:nil];
	
	[pool release];
}

- (void) renderCafes:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"GEOAPI_Request_Failed" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Cafe_Data" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SG_Not_Expected_Return" object:nil];	 

	[[[Mizoon sharedMizoon] getRootViewController] renderView:CAFE_VIEW fromView: MAIN_VIEW];	
	[[Mizoon sharedMizoon] hideLoadMessage];
	
	[pool release];
}


- (IBAction) restaurantButtonPressed:(id) sender
{
	Mizoon *miz = [Mizoon sharedMizoon];
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	
	miz.clickedView = RESTAURANT_VIEW;
	if (![miz hasNetworkConnection]) {
		[miz networkConnectionAlert];
		return;
	}
	
	[miz showLoadMessage:@"Locating..."];
	
	if ([miz needToFetchData:NearbyRestaurantData]) {   // if this is the first time
		
#ifdef MIZOON_DEBUG
		[Mizoon sharedMizoon].methodStart  = [NSDate date];
#endif
		// Register for the notification
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getRestaurantData:)
													 name:@"MZ_Have_Location_Coord" object:nil];
		
		[miz updateLocation];
		timer = [NSTimer scheduledTimerWithTimeInterval:LOCATION_DETECTION_TIMEOUT
												 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
	} else {		
		[rvc renderView:RESTAURANT_VIEW fromView: MAIN_VIEW];
	}
}


- (void) getRestaurantData:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
#ifdef MIZOON_DEBUG
	NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:[Mizoon sharedMizoon].methodStart];
	DebugLog(@"--> loc coord Fetch time=%f", executionTime);
#endif
	
	[timer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(failedReguest:) name:@"GEOAPI_Request_Failed" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(renderRestaurnats:) name:@"MZ_Have_Restaurant_Data" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(unexpectedReturn:) name:@"SG_Not_Expected_Return" object:nil];

	[[MizDataManager sharedDataManager] fetchNearbyRestaurants:nil];
	
	[pool release];
	
}



- (void) renderRestaurnats:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"GEOAPI_Request_Failed" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Restaurant_Data" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SG_Not_Expected_Return" object:nil];	 

	[[[Mizoon sharedMizoon] getRootViewController] renderView:RESTAURANT_VIEW fromView: MAIN_VIEW];	
	[[Mizoon sharedMizoon] hideLoadMessage];
	
	[pool release];
}








-(IBAction) testButtonPressed:(id) sender {
}


-(IBAction) blueButtonPressed:(id) sender {
}
	
@end
