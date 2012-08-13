//
//  MainView2Controller.m
//  Mizoon
//
//  Created by Daryoush Paknad on 8/6/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import "MainView2Controller.h"
#import	"Mizoon.h"

@implementation MainView2Controller



/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	MizoonLog(@"---------------> didReceiveMemoryWarning: MainView2");
	
    // Release any cached data, images, etc that aren't in use.
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
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Shopping_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Lodging_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_NL_Data" object:nil];	 
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



-(IBAction) settingButtonPressed:(id) sender 
{	
	[[[Mizoon sharedMizoon] getRootViewController] renderView:SETTINGS_VIEW fromView: MAIN_VIEW];
}





-(IBAction) shoppingPressed:(id) sender 
{
	Mizoon *miz = [Mizoon sharedMizoon];
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	
	miz.clickedView = SHOPPING_VIEW;
	if (![miz hasNetworkConnection]) {
		[miz networkConnectionAlert];
		return;
	}
	[miz showLoadMessage:@"Locating..."];
	
	if ([miz needToFetchData:NearbyShoppingData]) {   // if this is the first time

		// Register for the notification
		[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(getShoppingData:)
														 name:@"MZ_Have_Location_Coord" object:nil];
		[miz updateLocation];	
			
		timer = [NSTimer scheduledTimerWithTimeInterval:LOCATION_DETECTION_TIMEOUT 
													 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
	} else {
		[rvc renderView:SHOPPING_VIEW fromView: MAIN_VIEW];
	}
}
	


- (void) getShoppingData:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[timer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(failedReguest:) name:@"GEOAPI_Request_Failed" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(renderShops:) name:@"MZ_Have_Shopping_Data" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(unexpectedReturn:) name:@"SG_Not_Expected_Return" object:nil];

	[[MizDataManager sharedDataManager] fetchNearbyShopping:nil];

	[pool release];
	
}

- (void) renderShops:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"GEOAPI_Request_Failed" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Shopping_Data" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SG_Not_Expected_Return" object:nil];	 

	[[[Mizoon sharedMizoon] getRootViewController] renderView:SHOPPING_VIEW fromView: MAIN_VIEW];	
	[[Mizoon sharedMizoon] hideLoadMessage];
	
	[pool release];
}





-(IBAction) lodgingPressed:(id) sender 
{
	Mizoon *miz = [Mizoon sharedMizoon];
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	
	miz.clickedView = LODGING_VIEW;
	if (![miz hasNetworkConnection]) {
		[miz networkConnectionAlert];
		return;
	}
	[miz showLoadMessage:@"Locating..."];
	
	if ([miz needToFetchData:NearbyLodgingData]) {   // if this is the first time
		
		// Register for the notification
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getLodgingData:)
													 name:@"MZ_Have_Location_Coord" object:nil];
		[miz updateLocation];	
		
		timer = [NSTimer scheduledTimerWithTimeInterval:LOCATION_DETECTION_TIMEOUT 
												 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
	} else {
		[rvc renderView:LODGING_VIEW fromView: MAIN_VIEW];
	}
}


- (void) getLodgingData:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[timer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(failedReguest:) name:@"GEOAPI_Request_Failed" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(renderLodges:) name:@"MZ_Have_Lodging_Data" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(unexpectedReturn:) name:@"SG_Not_Expected_Return" object:nil];

	[[MizDataManager sharedDataManager] fetchNearbyLodging:nil];

	[pool release];
	
}

- (void) renderLodges:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"GEOAPI_Request_Failed" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Lodging_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SG_Not_Expected_Return" object:nil];	 

	[[[Mizoon sharedMizoon] getRootViewController] renderView:LODGING_VIEW fromView: MAIN_VIEW];	
	[[Mizoon sharedMizoon] hideLoadMessage];
	
	[pool release];
}



	
	
-(IBAction) nightLButtonPressed:(id) sender 
{
	Mizoon *miz = [Mizoon sharedMizoon];
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	
	miz.clickedView = NIGHTLIFE_VIEW;
	if (![miz hasNetworkConnection]) {
		[miz networkConnectionAlert];
		return;
	}
	
	[miz showLoadMessage:@"Locating..."];
	
	if ([miz needToFetchData:NearbyNLData]) {   // if this is the first time

		// Register for the notification
		[[NSNotificationCenter defaultCenter] addObserver:self
													selector:@selector(getNightLifeData:)
													name:@"MZ_Have_Location_Coord" object:nil];
			
		[miz updateLocation];	
			
		timer = [NSTimer scheduledTimerWithTimeInterval:LOCATION_DETECTION_TIMEOUT 
													 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
	} else {
		[rvc renderView:NIGHTLIFE_VIEW fromView: MAIN_VIEW];
	}
}

- (void) getNightLifeData:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[timer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(failedReguest:) name:@"GEOAPI_Request_Failed" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(renderNightlife:) name:@"MZ_Have_NL_Data" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(unexpectedReturn:) name:@"SG_Not_Expected_Return" object:nil];

	[[MizDataManager sharedDataManager] fetchNearbyNightLife:nil];
	
	[pool release];
	
}

- (void) renderNightlife:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"GEOAPI_Request_Failed" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_NL_Data" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SG_Not_Expected_Return" object:nil];	 

	[[[Mizoon sharedMizoon] getRootViewController] renderView:NIGHTLIFE_VIEW fromView: MAIN_VIEW];	
	[[Mizoon sharedMizoon] hideLoadMessage];
	
	[pool release];
}



@end
