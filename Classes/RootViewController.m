//
//  SwitchViewController.m
//  View Switcher
//
//  Created by Daryoush Paknad on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#include <stdio.h>
#import	<QuartzCore/QuartzCore.h>

#import	"TestViewController.h"

#import	"MainScrollViewController.h"
#import "RootViewController.h"
#import "YellowViewController.h"
#import "PlacesViewController.h"
#import "NearbyPeopleController.h"
#import	"LoginViewController.h"
#import	"ALocationViewController.h"
#import "MainViewController.h"
#import "RegLoginViewController.h"
#import	"SigninViewController.h"
#import	"RegisterViewController.h"
#import	"SettingsViewController.h"
#import	"PostsViewController.h"
#import	"APostViewController.h"
#import	"NewPostViewController.h"
#import	"ConfirmCheckinViewController.h"
#import	"CheckedinViewController.h"
#import	"LocationPromoController.h"
#import	"PromosController.h"
//#import	"APromoController.h"
#import	"APromotionController.h"
#import	"RedeemedCPController.h"
#import	"APersonViewController.h"
#import	"MessageViewController.h"
#import "MizoonServer.h"
#import	"MizProgressHUD.h"
#import	"MizDataManager.h"
#import	"LocationController.h"
#import	"MainScrollViewController.h"
#import	"NewLocationViewController.h"
#import	"MizoonRootControllerDelegate.h"
#import	"PlaceMapViewController.h"
#import	"CafeViewController.h"
#import	"RestaurantViewController.h"
#import	"NightLifeViewController.h"
#import	"ShoppingViewController.h"
#import	"LodgingViewController.h"


@interface RootViewController()  // private methods

- (void) prepareToDisplay: (int) viewID;
- (void) renderNearbyPeopleView;
- (void) renderPlacesView;
- (void) renderRegLoginView;
- (void) renderLoginView;
- (void) renderRegistrationView;
- (void) renderAPostView;
- (void) renderWebsiteView;
- (void) renderNewPostView;
- (void) renderShareCheckinView;
- (void) renderCheckedinView;
- (void) renderLocationPromosView;
- (void) renderAPromotionView;
- (void) renderNewLocationView;
- (void) renderLocationMapView;
- (void) renderCafeView;
- (void) renderRestaurantView;
- (void) renderTestView;
- (UIView *)findCurrentView;
@end

// SCM Test

@implementation RootViewController
@synthesize mainScrollController, yellowViewController, blueViewController, placesViewController, signinViewController, registerViewController;
@synthesize nearbyPeopleController,	extLocationViewController, loginViewController, regLoginViewController, settingsViewController;
@synthesize postsViewController, aPostViewController,newPostViewController, checkedinViewController,locationPromotions, promosController;
@synthesize locationController, aPromoController,redeemedCPController, aPersonViewController, messageViewController,shareCheckinViewController;
@synthesize newLocationViewController,placeMapViewController,shoppingViewController, lodgingViewController;
@synthesize	cafeViewController, restaurantViewController, nightLifeViewController, testViewController;
@synthesize	websiteView, progressAlert, isAlertVisible;

@synthesize	prevView;
@synthesize	delegate;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	[super viewDidLoad];

	
	MizDataManager *dm = [MizDataManager sharedDataManager];
	viewStack = [[NSMutableArray alloc] init];
	
	[self pushView:MAIN_VIEW];

	if (dm.isAuthenticatedMizUser) {
		locationController = [[LocationController alloc] init];
		[locationController getLocation];
			
		MainScrollViewController * mainController = [[MainScrollViewController alloc] initWithNibName:@"MainScrollView" bundle:nil];

		self.mainScrollController = mainController;
		
		CLLocation *loc = locationController.locationManager.location;
		MizoonLog(@"------------- - New Location coord -- lat=%f  lon=%f", loc.coordinate.latitude, loc.coordinate.longitude);

		[self.view insertSubview:mainController.view atIndex:0];
		[mainController release];
	} else {
		[self renderView: REG_LOGIN_VIEW fromView: INIT_VIEW];
	}

}

#pragma mark PEOPLE VIEWS

- (void) renderTestView 
{
	Mizoon *miz = [Mizoon sharedMizoon];
	
	//	[miz updateLocation];
	
	if (self.testViewController == nil) {
		TestViewController *vController = [[TestViewController alloc] initWithNibName:@"NearbyPeople" bundle:nil];
		
		//		peopleController.rootViewController = self;
		self.testViewController	= vController;
		[vController release];
	}
	
	if ([miz needToFetchData:NearbyPeopleData]) {
		//		progressAlert = [[MizProgressHUD alloc] initWithLabel:@"Searching..."];
		//		[progressAlert show];
		[self performSelector:@selector(getTestData) withObject:nil afterDelay:0];			 
		
	} else {
		[self hideLoadMessage];
		
		
		[self prepareToDisplay:TEST_VIEW];		
		[self.view insertSubview:testViewController.view atIndex:0];
		self.prevView = MAIN_VIEW;
		
	} 
}



- (void) getTestData 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
//	MizDataManager *dm = [MizDataManager sharedDataManager];
	
	
//	if ([dm fetchNearbyPeople: radius atIndex:0 numberToRet:NUM_PEOPLE_TO_FETCH ] == nil) {
//		[self hideLoadMessage];
//		
//		
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Unable to locate nearby people at this time. Please try again in a few seconds." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
//		[alert show];
//		[alert release];		
//		
//		
//		return;
//	}
	[self hideLoadMessage];
	[self.nearbyPeopleController.peopleTableView reloadData];
	[self prepareToDisplay:PEOPLE_VIEW];
	[self.view insertSubview:nearbyPeopleController.view atIndex:0];
	self.prevView = MAIN_VIEW;
	[pool release];
	
}




- (void) renderNearbyPeopleView 
{
	Mizoon *miz = [Mizoon sharedMizoon];

//	[miz updateLocation];
	
	if (self.nearbyPeopleController == nil) {
		NearbyPeopleController *peopleController = [[NearbyPeopleController alloc] initWithNibName:@"NearbyPeople" bundle:nil];
		
		self.nearbyPeopleController	= peopleController;
		[peopleController release];
	}
	
	if ([miz needToFetchData:NearbyPeopleData]) {
		[self performSelector:@selector(getNearbyPeople) withObject:nil afterDelay:0];			 
	} else {
		[self hideLoadMessage];


		[self prepareToDisplay:PEOPLE_VIEW];		
		[self.view insertSubview:nearbyPeopleController.view atIndex:0];
		self.prevView = MAIN_VIEW;
		
	} 
}



- (void) getNearbyPeople 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int	radius=DEFAULT_RADIUS;
	
	MizDataManager *dm = [MizDataManager sharedDataManager];
	
	
	if ([dm fetchNearbyPeople: radius atIndex:0 numberToRet:NUM_PEOPLE_TO_FETCH ] == nil) {
		[self hideLoadMessage];
		
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Couldn't locate nearby people at this time. Can you try again in a few seconds?" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[alert show];
		[alert release];		
		
		
		return;
	}
	[self.nearbyPeopleController.peopleTableView reloadData];
	[self prepareToDisplay:PEOPLE_VIEW];
	[self.view insertSubview:nearbyPeopleController.view atIndex:0];
	self.prevView = MAIN_VIEW;
	
	[self hideLoadMessage];

	[pool release];
	
}



- (void) renderAPersonView 
{
	if (self.aPersonViewController != nil) {
		[aPersonViewController.view removeFromSuperview];
		[aPersonViewController release];
	}
	
	APersonViewController *viewController =  [[APersonViewController alloc] initWithNibName:@"APersonView" bundle:nil];
	self.aPersonViewController = viewController;
	[viewController release];

	[self prepareToDisplay:A_PERSON_VIEW];
	[self.view insertSubview:aPersonViewController.view atIndex:0];

	//	self.prevView = PEOPLE_VIEW;
}



- (void) renderMessageView 
{
	if (self.messageViewController != nil) {
		[messageViewController.view removeFromSuperview];
		[messageViewController release];
	}
	
	MessageViewController *viewController =  [[MessageViewController alloc] initWithNibName:@"MessageView" bundle:nil];
	self.messageViewController = viewController;
	[viewController release];

	
//	self.messageViewController = [[MessageViewController alloc] initWithNibName:@"MessageView" bundle:nil];
	
	[self prepareToDisplay:SEND_MESSAGE_VIEW];
	[self.view insertSubview:messageViewController.view atIndex:0];
	self.prevView = A_PERSON_VIEW;
}



#pragma mark POST VIEWS 

- (void) renderNearbyPostsView 
{
	Mizoon *miz = [Mizoon sharedMizoon];

//	[miz updateLocation];
	if (self.postsViewController == nil) {
		PostsViewController *postsController = [[PostsViewController alloc] initWithNibName:@"PostsView" bundle:nil];
		
		self.postsViewController	= postsController;
		[postsController release];
	}
	
	if ([miz needToFetchData:NearbyPostsData]) {
//		progressAlert = [[MizProgressHUD alloc] initWithLabel:@"Searching..."];
//		[progressAlert show];
		[self performSelector:@selector(getNearbyPosts) withObject:nil afterDelay:1.0];			 
		
	} else {
		[self hideLoadMessage];


		[self prepareToDisplay:POSTS_VIEW];		
		[self.view insertSubview:postsViewController.view atIndex:0];
		[self.view bringSubviewToFront:postsViewController.view];
		[self bringTopBarToFront];

		self.prevView = MAIN_VIEW;
		
	}
}



- (void) getNearbyPosts {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int	radius=DEFAULT_RADIUS;
	
	MizDataManager *dm = [MizDataManager sharedDataManager];
	
	if ([dm fetchNearbyPosts: radius atIndex:0 numberToRet:NUM_POSTS_TO_FETCH ] == nil) {
		[self hideLoadMessage];
		
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Couldn't find any posts near you. Can you try again in a few minutes?" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[alert show];
		[alert release];		
		
		[self popView];
		
		[pool release];
		
		return;
	}
	
	[self hideLoadMessage];
	
	[self.postsViewController.postsTableView reloadData];
	[self prepareToDisplay:POSTS_VIEW];
	[self.view insertSubview:postsViewController.view atIndex:0];
	[self.view bringSubviewToFront:postsViewController.view];
	[self bringTopBarToFront];
	
	self.prevView = MAIN_VIEW;
	
	//	[placesArr release];
	[pool release];
}




- (void) renderAPostView 
{
	//	if (self.aPostViewController != nil) 
	//		[self.aPostViewController release];
	
	APostViewController *postController = [[APostViewController alloc] initWithNibName:@"APostView" bundle:nil];
	
	self.aPostViewController	= postController;
	[postController release];
	
	[self prepareToDisplay:A_POST_VIEW];		
	[self.view insertSubview:aPostViewController.view atIndex:0];
	self.prevView = POSTS_VIEW;
}


- (void) renderNewPostView 
{
	//	if (self.aPostViewController != nil) 
	//		[self.aPostViewController release];
	
	NewPostViewController *postController = [[NewPostViewController alloc] initWithNibName:@"NewPostView" bundle:nil];
	
	self.newPostViewController	= postController;
	[postController release];
	
	[self prepareToDisplay:NEW_POST_VIEW];		
	[self.view insertSubview:newPostViewController.view atIndex:0];
	[self.view bringSubviewToFront:newPostViewController.view];
	[self bringTopBarToFront];
	
	self.prevView = POSTS_VIEW;
}



- (void) reloadPostsView 
{	
	if (self.postsViewController == nil) {
		PostsViewController *postsController = [[PostsViewController alloc] initWithNibName:@"PostsView" bundle:nil];
		
		self.postsViewController	= postsController;
		[postsController release];
	}
	
	[self prepareToDisplay:POSTS_VIEW];		
	[self.view insertSubview:postsViewController.view atIndex:0];
	self.prevView = MAIN_VIEW;
}
	

- (void) reloadRenderPostsView {
	
	[newPostViewController.view removeFromSuperview];	
	[self.postsViewController.postsTableView reloadData];
	
	[self.view insertSubview:postsViewController.view atIndex:0];
	self.prevView = MAIN_VIEW;
}


#pragma mark LOCATION VIEWS



- (void) renderPlacesView 
{	
	if (self.placesViewController == nil) {
		PlacesViewController *placesController = [[PlacesViewController alloc] initWithNibName:@"PlacesView2" bundle:nil];
		
		placesController.rootViewController = self;
		self.placesViewController = placesController;
		[placesController release];
	}
	
	[self prepareToDisplay:PLACES_VIEW];		
	[self.view insertSubview:placesViewController.view atIndex:0];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Places_Data" object:nil];	 
	
	[self hideLoadMessage];
}


- (void) renderPlacesData:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[placesViewController.view removeFromSuperview];
	
	if (self.placesViewController != nil) 
		self.placesViewController = nil;
	
	PlacesViewController *placesController = [[PlacesViewController alloc] initWithNibName:@"PlacesView" bundle:nil];
	placesController.rootViewController = self;
	self.placesViewController = placesController;
	[placesController release];
	
	
	[self prepareToDisplay:PLACES_VIEW];		
	[self.view insertSubview:placesViewController.view atIndex:0];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Places_Data" object:nil];	 
	
	[self hideLoadMessage];
	
	[pool release];
}



- (void) getNearbyPlaces 
{		
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int	radius=2;
	
	MizDataManager *dm = [MizDataManager sharedDataManager];
	
	if ([dm fetchNearbyPlaces: radius atIndex:0 numberToRet:100 ] == nil) {
		[self hideLoadMessage];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Unable to connect. Please try again in a few minutes." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[alert show];
		[alert release];		
		
		[pool release];
		return;
	}
	[self hideLoadMessage];
	
	//	[progressAlert dismissWithClickedButtonIndex:0 animated:YES];
	//    [progressAlert release];
	
	[self.placesViewController.placesTableView reloadData];
	
	[self prepareToDisplay:PLACES_VIEW];
	[self.view insertSubview:placesViewController.view atIndex:0];
	self.prevView = MAIN_VIEW;
	
	[pool release];
}


- (void) reloadNearbyPlaces 
{
	//	Mizoon *miz = [Mizoon sharedMizoon];
	//	RootViewController *rvc = [miz getRootViewController];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int	radius=2;
	
	MizDataManager *dm = [MizDataManager sharedDataManager];
	
	[dm fetchNearbyPlaces: radius atIndex:0 numberToRet:100 ];
	
	[placesViewController.view removeFromSuperview];
	
	//	[rvc.progressAlert dismissWithClickedButtonIndex:0 animated:YES];
	//    [rvc.progressAlert release];
	
	if (self.placesViewController != nil) 
		self.placesViewController = nil;
	
	PlacesViewController *placesController = [[PlacesViewController alloc] initWithNibName:@"PlacesView" bundle:nil];
	
	placesController.rootViewController = self;
	self.placesViewController = placesController;
	[placesController release];
	
	
	[self.view insertSubview:placesViewController.view atIndex:0];
	self.prevView = MAIN_VIEW;
	
	[pool release];
}



- (void) renderLocationMapView
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	if (self.placeMapViewController != nil) {
		[placeMapViewController.view removeFromSuperview];
		self.placeMapViewController = nil;
	}
	
	PlaceMapViewController *viewController = [[PlaceMapViewController alloc] init];
	self.placeMapViewController	= viewController;
	[viewController release];
	
	[self prepareToDisplay:PLACE_MAP_VIEW];		
	[self.view insertSubview:placeMapViewController.view atIndex:0];
	
	[pool release];
}



- (void) renderCafeView
{
	if (self.cafeViewController != nil) {
		[cafeViewController.view removeFromSuperview];
		cafeViewController = nil;
	}
	CafeViewController *viewController =  [[[CafeViewController alloc] init] retain];
	self.cafeViewController	= viewController;
	[viewController release];
		
	[self prepareToDisplay:CAFE_VIEW];		
	[self.view insertSubview:cafeViewController.view atIndex:0];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Cafe_Data" object:nil];	 
		
	[self hideLoadMessage];
}


- (void) renderNLView
{
	if (self.nightLifeViewController != nil) {
		[nightLifeViewController.view removeFromSuperview];
		nightLifeViewController = nil;
	}
		
	NightLifeViewController *viewController = [[[NightLifeViewController alloc] init] retain];
	self.nightLifeViewController	= viewController;
	[viewController release];
		
	[self prepareToDisplay:NIGHTLIFE_VIEW];		
	[self.view insertSubview:nightLifeViewController.view atIndex:0];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_NL_Data" object:nil];	 
		
	[self hideLoadMessage];
}



- (void) renderShoppingView
{
	if (self.shoppingViewController != nil) {
		[shoppingViewController.view removeFromSuperview];
		shoppingViewController = nil;
	}
		
	ShoppingViewController *viewController = [[[ShoppingViewController alloc] init] retain];
	self.shoppingViewController	= viewController;
	[viewController release];
		
	[self prepareToDisplay:SHOPPING_VIEW];		
	[self.view insertSubview:shoppingViewController.view atIndex:0];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Shopping_Data" object:nil];	 
		
	[self hideLoadMessage];
}



- (void) renderLodgingView
{

	if (self.lodgingViewController != nil) {
		[lodgingViewController.view removeFromSuperview];
		lodgingViewController = nil;
	}
		
	LodgingViewController *viewController = [[[LodgingViewController alloc] init] retain];
	self.lodgingViewController	= viewController;
	[viewController release];
		
	[self prepareToDisplay:LODGING_VIEW];		
	[self.view insertSubview:lodgingViewController.view atIndex:0];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Lodging_Data" object:nil];	 
	
	[self hideLoadMessage];
}



- (void) renderLodgingData:(NSNotification *)notification 
{
	if (self.lodgingViewController != nil) {
		[lodgingViewController.view removeFromSuperview];
		self.lodgingViewController = nil;
	}
	
	LodgingViewController *viewController = [[LodgingViewController alloc] init];
	self.lodgingViewController	= viewController;
	[viewController release];
	
	
	[self prepareToDisplay:LODGING_VIEW];		
	[self.view insertSubview:lodgingViewController.view atIndex:0];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Lodging_Data" object:nil];	 
	
	[self hideLoadMessage];
}


- (void) renderRestaurantView
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	

	if (self.restaurantViewController != nil) {
		[restaurantViewController.view removeFromSuperview];
		restaurantViewController = nil;
	}
		
	RestaurantViewController *viewController = [[[RestaurantViewController alloc] init] retain ];
	self.restaurantViewController	= viewController;
	[viewController release];
		
		
	[self prepareToDisplay:RESTAURANT_VIEW];		
	[self.view insertSubview:restaurantViewController.view atIndex:0];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Restaurant_Data" object:nil];	 
		
	[self hideLoadMessage];
	[pool release];
}


- (void) renderRestaurantData:(NSNotification *)notification 
{
	if (self.restaurantViewController != nil) {
		[restaurantViewController.view removeFromSuperview];
		self.restaurantViewController = nil;
	}
	
	RestaurantViewController *viewController = [[RestaurantViewController alloc] init];
	self.restaurantViewController	= viewController;
	[viewController release];
	
	
	[self prepareToDisplay:RESTAURANT_VIEW];		
	[self.view insertSubview:restaurantViewController.view atIndex:0];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Restaurant_Data" object:nil];	 
	
	[self hideLoadMessage];
}


- (void) renderShareCheckinView 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	if (self.shareCheckinViewController != nil) 
		[shareCheckinViewController.view removeFromSuperview];
	
	ConfirmCheckinViewController *shareController = [[ConfirmCheckinViewController alloc] initWithNibName:@"CheckedinView" bundle:nil];
	self.shareCheckinViewController	= shareController;
	[shareController release];
	
	[self prepareToDisplay:SHARE_CHECKIN_VIEW];		
	[self.view insertSubview:shareCheckinViewController.view atIndex:0];
	self.prevView = EXTERNAL_LOCATION_VIEW;		

	[pool release];
}




- (void) renderCheckedinView 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	/*
	 if (self.checkedinViewController == nil) {
	 CheckedinViewController *checkedinController = [[CheckedinViewController alloc] initWithNibName:@"CheckedinView" bundle:nil];
	 
	 self.checkedinViewController	= checkedinController;
	 [checkedinController release];
	 }
	 */
	if (self.checkedinViewController != nil) {
		[checkedinViewController.view removeFromSuperview];
		[checkedinViewController release];
		checkedinViewController = nil;
	}
	CheckedinViewController *checkedinController = [[CheckedinViewController alloc] initWithNibName:@"CheckedinView" bundle:nil];
	
	self.checkedinViewController	= checkedinController;
	[checkedinController release];
	
	[self prepareToDisplay:CHECKED_IN_VIEW];		
	[self.view insertSubview:checkedinViewController.view atIndex:0];
	self.prevView = EXTERNAL_LOCATION_VIEW;		
	
	[pool release];
}




- (void) reloadConfirmCheckin
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	if (self.shareCheckinViewController != nil) {
		[shareCheckinViewController.view removeFromSuperview];
		self.shareCheckinViewController = nil;
	}
	
	ConfirmCheckinViewController *shareController = [[ConfirmCheckinViewController alloc] initWithNibName:@"CheckedinView" bundle:nil];
	
	self.shareCheckinViewController	= shareController;
	[shareController release];
	
	[self prepareToDisplay:SHARE_CHECKIN_VIEW];		
	[self.view insertSubview:shareCheckinViewController.view atIndex:0];
	
	[pool release];
}

- (void) websiteViewWithRequest:(NSURLRequest *) requestObj yScroll: (CGFloat) rollUp
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (self.websiteView != nil) {
		[websiteView removeFromSuperview];
		[websiteView release];
	}
	CGRect webFrame = [[UIScreen mainScreen] applicationFrame];  
//	webFrame.origin.y = TOP_BAR_WITH;
	
	if ( rollUp < 0 )
		webFrame.size.height += -rollUp;
	
	webFrame.origin.y = rollUp;
	
	self.websiteView = [[UIWebView alloc] initWithFrame:webFrame];  
	self.websiteView.backgroundColor = [UIColor whiteColor]; 
	self.websiteView.delegate = self;
	self.websiteView.scalesPageToFit = TRUE;
	
	[websiteView loadRequest:requestObj];
	
	[pool release];
}


- (void) renderWebsiteView
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

//	if (self.websiteView != nil) {
//		[websiteView removeFromSuperview];
//		[websiteView release];
//	}
//	CGRect webFrame = [[UIScreen mainScreen] applicationFrame];  
//	webFrame.origin.y = TOP_BAR_WITH;
//	
//	self.websiteView = [[UIWebView alloc] initWithFrame:webFrame];  
//	self.websiteView.backgroundColor = [UIColor whiteColor];  
//	self.websiteView.scalesPageToFit = TRUE;
	
	[self prepareToDisplay:WEBSITE_VIEW];
	[self.view insertSubview:self.websiteView atIndex:0];
	self.prevView = EXTERNAL_LOCATION_VIEW;
	
	[pool release];
}



- (void) renderNewLocationView
{
	if (self.newLocationViewController != nil) {
		[newLocationViewController.view removeFromSuperview];
		self.newLocationViewController = nil;
	}
	
	NewLocationViewController *viewController = [[[NewLocationViewController alloc] init] retain];
	self.newLocationViewController	= viewController;
	[viewController release];
	
	[self prepareToDisplay:NEW_LOCATION_VIEW];		
	[self.view insertSubview:newLocationViewController.view atIndex:0];
}





#pragma mark SETUP VIEWS
- (void) reloadSetup
{
	if (self.settingsViewController != nil) {
		[settingsViewController.view removeFromSuperview];
//		[self.settingsViewController release];
		self.settingsViewController = nil;
	}
	
	SettingsViewController *settings = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:0];
	self.settingsViewController = settings;
	[settings release];
	
	[self prepareToDisplay:SETTINGS_VIEW];
	[self.view insertSubview:settingsViewController.view atIndex:0];
}



- (IBAction) settingsView
{
	if (self.settingsViewController == nil) {
		SettingsViewController *settings = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:0];
		[self.view insertSubview:settings.view atIndex:0];
		self.settingsViewController = settings;
		
		[settings release];	
	}
	[self prepareToDisplay:SETTINGS_VIEW];
	[self.view insertSubview:settingsViewController.view atIndex:0];
}




- (void) renderLoginView {
	
	if (self.loginViewController == nil) {
		LoginViewController	*loginController = [[LoginViewController alloc] initWithNibName:@"LoginView2" bundle:nil];
		
		loginController.rootViewController = self;
		self.loginViewController = loginController;
		[loginController release];
	}
	
	[self.view insertSubview:loginViewController.view atIndex:1];
	
	
	self.prevView = MAIN_VIEW;	
}




- (void) renderRegLoginView 
{
	UIView *currentView;
	
	if (self.regLoginViewController == nil) {
		RegLoginViewController	*regLoginController = [[RegLoginViewController alloc] initWithNibName:@"RegLoginView" bundle:nil];
		
		self.regLoginViewController = regLoginController;
		[regLoginController release];
	}
	switch (self.prevView) {
		case INIT_VIEW:
			[self prepareToDisplay:REG_LOGIN_VIEW];		
			[self.view insertSubview:regLoginViewController.view atIndex:1];
			return;
			
		case SIGN_IN_VIEW:
			currentView = signinViewController.view;
			break;
			
		case REGISTER_VIEW:
			currentView = registerViewController.view;
			break;
			
		case SETTINGS_VIEW:
			currentView = settingsViewController.view;
			break;
			
		default:
			break;
	}
	UIView *theWindow = [currentView superview];
	[currentView removeFromSuperview];
	
	[theWindow addSubview:regLoginViewController.view];
	
	CATransition *animation = [CATransition animation];
	[animation setDuration:1.0];
	//	[animation setType:kCATransitionFromRight];
	animation.type = kCATransitionMoveIn;
	[animation setSubtype:kCATransitionFromLeft];
	
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
	
	[[theWindow layer] addAnimation:animation forKey:@"SwitchToRegLoginView"];
	
	
	/*	
	 if (self.prevView == INIT_VIEW) {
	 [self prepareToDisplay:REG_LOGIN_VIEW];		
	 [self.view insertSubview:regLoginViewController.view atIndex:1];
	 } else {
	 
	 if (self.prevView == SIGN_IN_VIEW) {
	 currentView = signinViewController.view;
	 } else {
	 currentView = registerViewController.view;
	 }
	 UIView *theWindow = [currentView superview];
	 [currentView removeFromSuperview];
	 
	 [theWindow addSubview:regLoginViewController.view];
	 
	 CATransition *animation = [CATransition animation];
	 [animation setDuration:1.0];
	 //	[animation setType:kCATransitionFromRight];
	 animation.type = kCATransitionMoveIn;
	 [animation setSubtype:kCATransitionFromLeft];
	 
	 [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
	 
	 [[theWindow layer] addAnimation:animation forKey:@"SwitchToRegLoginView"];
	 }
	 */
}



- (void) renderSigninView 
{
	
	if (self.signinViewController == nil) {
		SigninViewController	*signinView = [[SigninViewController alloc] initWithNibName:@"SigninView" bundle:nil];
		
		self.signinViewController = signinView;
		[signinView release];
	}
	
	[self prepareToDisplay:SIGN_IN_VIEW];
	
	[self.view insertSubview:signinViewController.view atIndex:0];
	CATransition *animation = [CATransition animation];
	[animation setDuration:1.0];
	//	[animation setType:kCATransitionFromRight];
	animation.type = kCATransitionMoveIn;
	[animation setSubtype:kCATransitionFromRight];
	
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
	
	[[self.view layer] addAnimation:animation forKey:@"SwitchToLoginView"];
	self.prevView = MAIN_VIEW;	
}


- (void) renderRegistrationView 
{
	if (self.registerViewController == nil) {
		RegisterViewController	*reg = [[RegisterViewController alloc] initWithNibName:@"RegisterView" bundle:nil];
		
		self.registerViewController = reg;
		[reg release];
	}
	
	[self prepareToDisplay:REGISTER_VIEW];
	
	[[[Mizoon sharedMizoon] getRootViewController].view viewWithTag:2001].hidden = TRUE;	// hide the home button
	
	[self.view insertSubview:registerViewController.view atIndex:0];
	CATransition *animation = [CATransition animation];
	[animation setDuration:1.0];
	animation.type = kCATransitionMoveIn;
	[animation setSubtype:kCATransitionFromRight];
	
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
	
	[[self.view layer] addAnimation:animation forKey:@"SwitchToLoginView"];
	
	self.prevView = MAIN_VIEW;	
}



#pragma mark PROMOTIONS VIEWS
- (void) renderLocationPromosView 
{
	Mizoon *miz = [Mizoon sharedMizoon];

	if (self.locationPromotions == nil) {
		LocationPromoController *locWithPromo = [[LocationPromoController alloc] initWithNibName:@"LocationPromotions" bundle:nil];
		
		self.locationPromotions	= locWithPromo;
		[locWithPromo release];
	}
	
	if ([miz needToFetchData:LocationsWithPromoData]) {

		[self performSelector:@selector(getLocationsWithPromo) withObject:nil afterDelay:1.0];			 
		
	} else {
		[self hideLoadMessage];

		
		[self prepareToDisplay:LOCATIONS_WITH_PROMOTIONS_VIEW];		
		[self.view insertSubview:locationPromotions.view atIndex:0];
		self.prevView = MAIN_VIEW;
		
	}
}




- (void) renderPromotionsView 
{
	
	MizDataManager *dm = [MizDataManager sharedDataManager];
	Mizoon *miz = [Mizoon  sharedMizoon];

	[miz updateLocation];

	if (self.promosController != nil) 
		[promosController.view removeFromSuperview];
	
	
	PromosController *viewController =  [[PromosController alloc] initWithNibName:@"PromosView" bundle:nil];
	self.promosController = viewController;
	[viewController release];
	
	
//	self.promosController = [[PromosController alloc] initWithNibName:@"PromosView" bundle:nil];
			
	if (dm.promotions && [miz getSelectedLocation] && ([miz getSelectedLocation].lid == miz.lastSelectedLid)) {
		[self prepareToDisplay:PROMOTIONS_VIEW];
		[self.view insertSubview:promosController.view atIndex:0];
		self.prevView = LOCATIONS_WITH_PROMOTIONS_VIEW;
	} else {
		[self renderLoadMessage:@"Searching..."];
//		progressAlert = [[MizProgressHUD alloc] initWithLabel:@"Searching..."];
//		[progressAlert show];
		[self performSelector:@selector(getPromotions) withObject:nil afterDelay:1.0];			 		
	}	
}




- (void) renderAPromotionView 
{
	
	//	MizDataManager *dm = [MizDataManager sharedDataManager];
	
	if (self.aPromoController != nil) 
		[aPromoController.view removeFromSuperview];
	
	
//	self.aPromoController = [[APromoController alloc] initWithNibName:@"APromoView" bundle:nil];
	APromotionController *viewController =  [[APromotionController alloc] initWithNibName:@"APromotionController" bundle:nil];
	self.aPromoController = viewController;
	[viewController release];

	
//	self.aPromoController = [[APromotionController alloc] initWithNibName:@"APromotionController" bundle:nil];

	[self prepareToDisplay:A_PROMOTION_VIEW];
	[self.view insertSubview:aPromoController.view atIndex:0];
	self.prevView = PROMOTIONS_VIEW;
}



- (void) renderRedeemedCPView 
{
	
	if (self.redeemedCPController == nil) {
		RedeemedCPController	*redeemView = [[RedeemedCPController alloc] initWithNibName:@"RedeemedCPView" bundle:nil];

		self.redeemedCPController = redeemView;
		[redeemView release];
	}
		
	[self prepareToDisplay:REDEEMED_VIEW];
	[self.view insertSubview:redeemedCPController.view atIndex:0];
	self.prevView = PROMOTIONS_VIEW;
}



- (void) getLocationsWithPromo 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int	radius=DEFAULT_RADIUS;
	
	MizDataManager *dm = [MizDataManager sharedDataManager];
	//	if (!dm.locationsWithPromos || dm.promoLocSize == 0) {
	//		[dm fetchLocationsWithPromos:radius atIndex:0 numberToRet:100];
	//	}
	
	if ([dm fetchLocationsWithPromos:radius atIndex:0 numberToRet:100] == nil) {
		[self hideLoadMessage];
		
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Couldn't find any promotions near you. Can you try again in a few minutes?" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[alert show];
		[alert release];		
		
		[self popView];

		[pool release];
		return;
	}
	[self hideLoadMessage];
	
	[self.locationPromotions.promosTableView reloadData];
	
	[self prepareToDisplay:LOCATIONS_WITH_PROMOTIONS_VIEW];
	[self.view insertSubview:locationPromotions.view atIndex:0];
	self.prevView = MAIN_VIEW;
	[pool release];
	
}



- (void) getPromotions 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	MizDataManager *dm = [MizDataManager sharedDataManager];
	Mizoon	*miz = [Mizoon sharedMizoon];
	//	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	//	RootViewController *rvc = delegate.rootViewController;
	//	LocationPromoController *locPromos = rvc.locationPromotions;
	
	//	[dm fetchPromotions:locPromos.selectedLid];
	[dm fetchPromotions:miz.lastSelectedLid];
	
	
	
	if (!dm.promotions) {
		[self hideLoadMessage];
		
		
		[self renderView:LOCATIONS_WITH_PROMOTIONS_VIEW fromView:PROMOTIONS_VIEW];
		
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Unable to locate nearby promotions. Please try again in a few seconds." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[alert show];
		[alert release];		
		
		
		return;
	}
	[self hideLoadMessage];
	
	
	[self prepareToDisplay:PROMOTIONS_VIEW];
	[self.view insertSubview:promosController.view atIndex:0];
	self.prevView = LOCATIONS_WITH_PROMOTIONS_VIEW;
	[pool release];
	
}


#pragma mark ROOT CONTROLLER



// To add a new view to the root controller add it here and make sure you also update the pepareToDisplay func too.
- (IBAction) renderView:(int) viewID fromView:(int) currentViewID
{
	self.prevView = currentViewID;
	
#if 0
//	CLLocation *tmpLocation = [[CLLocation alloc] initWithLatitude:37.447231543895796 longitude:-122.16552257537842];  // Downtown palo alto
//	CLLocation *tmpLocation = [[CLLocation alloc] initWithLatitude:39.49132430037711 longitude:-100.2008056640625];  // some where in Idaho
//	CLLocation *tmpLocation = [[CLLocation alloc] initWithLatitude:37.453592 longitude:-122.182505];  // Cafe Barrone
	CLLocation *tmpLocation = [[CLLocation alloc] initWithLatitude:37.36289222264524 longitude:-121.92137718200684];  // San jose airport


	[MizDataManager sharedDataManager].currentLocation = [tmpLocation retain];

#endif
	[self pushView:viewID];
	
	if (viewID != EXTERNAL_LOCATION_VIEW) {
		[[MizDataManager sharedDataManager] releaseVisitors];
	}
	self.delegate = nil;
	
	//	object = [queue objectAtIndex: [queue count] -1];  // take out the last one
	//	[queue removeObjectAtIndex:  [queue count] -1];
	
	switch (viewID) {
		case TEST_VIEW:
			[self renderTestView];
			break;
		case PLACES_VIEW:
			[self renderPlacesView];
			break;
		case PEOPLE_VIEW:
			[self renderNearbyPeopleView];
			break;
		case POSTS_VIEW:
			[self renderNearbyPostsView];
			break;
		case LOCATIONS_WITH_PROMOTIONS_VIEW:
			[self renderLocationPromosView];
			break;
			
		case REGISTER_VIEW:
			[self renderRegistrationView];
			break;
			
		case REG_LOGIN_VIEW:
			[self renderRegLoginView];
			break;
			
		case SIGN_IN_VIEW:
			[self renderSigninView];
			break;

		case LOGIN_VIEW:
			[self renderLoginView];
			break;
			
		case A_POST_VIEW:
			[self renderAPostView];
			break;
			
		case NEW_POST_VIEW:
			[self renderNewPostView];
			break;
			
		case SHARE_CHECKIN_VIEW:
			[self renderShareCheckinView];
			break;
			
		case CHECKED_IN_VIEW:
			[self renderCheckedinView];
			break;
			
			
		case PROMOTIONS_VIEW:
			[self renderPromotionsView];
			break;
			
		case A_PROMOTION_VIEW:
			[self renderAPromotionView];
			break;
			
		case REDEEMED_VIEW:
			[self renderRedeemedCPView];
			break;
			
		case A_PERSON_VIEW:
			[self renderAPersonView];
			break;
			
		case SEND_MESSAGE_VIEW:
			[self renderMessageView];
			break;
			
		case WEBSITE_VIEW:
			[self renderWebsiteView];
			break;
			
		case SETTINGS_VIEW:
			[self settingsView];
			break;
						
		case NEW_LOCATION_VIEW:
			[self renderNewLocationView];
			break;
			
		case PLACE_MAP_VIEW:
			[self renderLocationMapView];
			break;
			
		case CAFE_VIEW:
			[self renderCafeView];
			break;

		case RESTAURANT_VIEW:
			[self renderRestaurantView];
			break;
			
		case NIGHTLIFE_VIEW:
			[self renderNLView];
			break;
			
		case SHOPPING_VIEW:
			[self renderShoppingView];
			break;
			
		case LODGING_VIEW:
			[self renderLodgingView];
			break;
			
			
		case MAIN_VIEW:
			if (self.mainScrollController == nil) {
				MainScrollViewController *mainViewController = [[MainScrollViewController alloc] initWithNibName:@"MainScrollView" bundle:nil];
				
				self.mainScrollController	= mainViewController;
				[mainViewController release];
			}
			[self prepareToDisplay:MAIN_VIEW];
			[self.view insertSubview:mainScrollController.view atIndex:0];
			self.prevView = MAIN_VIEW;
			break;
			
			
		case EXTERNAL_LOCATION_VIEW:
		{
			ALocationViewController *extLocationView = [[ALocationViewController alloc] initWithNibName:@"ExtLocationView" bundle:nil];
			
			extLocationView.rootViewController = self;
			self.extLocationViewController = extLocationView;
			[extLocationView release];
		}		
			[self prepareToDisplay:EXTERNAL_LOCATION_VIEW];
			[self.view insertSubview:extLocationViewController.view atIndex:0];
			self.prevView = PLACES_VIEW;
			break;
#if 0	
		case TEST_VIEW:
			[UIView beginAnimations:@"View Flip"  context:nil];
			[UIView setAnimationDuration:1.25];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
			
			if (self.yellowViewController.view.superview == nil) {
				if (self.yellowViewController == nil) {
					YellowViewController *yellowController = [[YellowViewController alloc] initWithNibName:@"YellowView" bundle:nil];
					
					self.yellowViewController = yellowController;
					[yellowController release];
				}
				[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
				[blueViewController viewWillAppear:YES];
				[yellowViewController viewWillDisappear:YES];
				
				if (self.placesViewController != nil) 
					[placesViewController.view removeFromSuperview];
				
				if (self.blueViewController != nil) 
					[blueViewController.view removeFromSuperview];
				
				[self.view insertSubview:yellowViewController.view atIndex:0];
				
				
			} else {
				if (self.blueViewController == nil) {
					MainViewController *blueController = [[MainViewController alloc] initWithNibName:@"BlueView" bundle:0];
					[self.view insertSubview:blueController.view atIndex:0];
					
					[blueController release];	
				}
				[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
				[yellowViewController viewWillAppear:YES];
				[blueViewController viewWillDisappear:YES];
				
				
				[yellowViewController.view removeFromSuperview];
				[self.view insertSubview:blueViewController.view atIndex:0];
				
				[blueViewController viewWillDisappear:YES];
				[yellowViewController viewDidAppear:YES];
				
			}
			[UIView commitAnimations];
			self.prevView = PLACES_VIEW;
			
			break;
#endif		
		default:
			break;
	}
}


- (void) prepareToReleadALocation
{
	int topView = [self topView];

	if (topView == EXTERNAL_LOCATION_VIEW) {
		[self popView];

		if (self.extLocationViewController != nil) {
			[extLocationViewController.view removeFromSuperview];
			[extLocationViewController release];
			extLocationViewController = nil;
		}
	}
	if (topView == CHECKED_IN_VIEW) {
		[self popView];
		
		if (self.checkedinViewController != nil) {
			[checkedinViewController.view removeFromSuperview];
			[checkedinViewController release];
			checkedinViewController = nil;
		}
	}
}

- (void) removeView: (int) viewID
{
	[self popView];

	switch (viewID) {
		case SETTINGS_VIEW:
			[settingsViewController.view removeFromSuperview];
			[settingsViewController release];
			settingsViewController = nil;
			break;
			
		case CHECKED_IN_VIEW:
			[checkedinViewController.view removeFromSuperview];
			[checkedinViewController release];
			checkedinViewController = nil;			
			break;

		default:
			break;
	}
}


- (void) prepareToDisplay: (int) viewID {
	
	if (viewID == MAIN_VIEW  || viewID == SEND_MESSAGE_VIEW || viewID == REG_LOGIN_VIEW ) 
		[self hideTopBar];
	else
		[self showTopBar];
	
	[self.delegate willRemoveView:viewID];
	
	if (viewID != TEST_VIEW && self.testViewController != nil) {
		[testViewController.view removeFromSuperview];
		[self.testViewController release];
		self.testViewController = nil;
	}

	
	if (viewID != YELLOW_VIEW && self.yellowViewController != nil) 
		[yellowViewController.view removeFromSuperview];
	
	if (viewID != PLACES_VIEW && self.placesViewController != nil) {
		[placesViewController.view removeFromSuperview];
		[placesViewController release];
		placesViewController = nil;
	}
	if (viewID != PEOPLE_VIEW && self.nearbyPeopleController	!= nil) {
		[nearbyPeopleController.view removeFromSuperview];
		[nearbyPeopleController release];
		nearbyPeopleController = nil;
	}
	if (viewID != LOGIN_VIEW && self.loginViewController	!= nil) {
		[loginViewController.view removeFromSuperview];
		[loginViewController	release];
		loginViewController = nil;
	}
	//	if (viewID != MAIN_VIEW && self.blueViewController != nil) 
	//		[blueViewController.view removeFromSuperview];
	if (viewID != MAIN_VIEW && self.mainScrollController != nil) {
		[mainScrollController.view removeFromSuperview];
		
		// hide the rootview bottom toolbar
		//		[self.view viewWithTag:1000].hidden = TRUE;
	}
	
	if (viewID != EXTERNAL_LOCATION_VIEW && self.extLocationViewController != nil) {
		[extLocationViewController.view removeFromSuperview];
		[extLocationViewController release];
		extLocationViewController = nil;
	}
	
	if (viewID != REG_LOGIN_VIEW && self.regLoginViewController != nil) {
		[regLoginViewController.view removeFromSuperview];
		[regLoginViewController release];
		regLoginViewController = nil;
	}
	if (viewID != SIGN_IN_VIEW && self.signinViewController != nil) {
		[signinViewController.view removeFromSuperview];
		[signinViewController release];
		signinViewController = nil;
	}
	if (viewID != SETTINGS_VIEW	&& self.settingsViewController != nil) {	
		[settingsViewController.view removeFromSuperview];
		[settingsViewController release];
		settingsViewController = nil;
	}
	if (viewID != REGISTER_VIEW	&& self.registerViewController != nil) {
		[registerViewController.view removeFromSuperview];	
		[[self.view viewWithTag:kJoinButtonTag] removeFromSuperview];
		[registerViewController release];
		registerViewController = nil;
	}
	if (viewID != POSTS_VIEW	&& self.postsViewController != nil) {
		[postsViewController.view removeFromSuperview];
		[postsViewController release];
		postsViewController = nil;
	}
	if (viewID != A_POST_VIEW	&& self.aPostViewController != nil) {
		[aPostViewController.view removeFromSuperview];	
		[aPostViewController release];
		//		[aPostViewController release];
		aPostViewController = nil;
	}
	if (viewID != NEW_POST_VIEW	&& self.newPostViewController != nil) {
		[newPostViewController.view removeFromSuperview];	
		[newPostViewController release];
		newPostViewController = nil;
	}
	if (viewID != SHARE_CHECKIN_VIEW	&& self.shareCheckinViewController != nil) {
		[shareCheckinViewController.view removeFromSuperview];	
		[shareCheckinViewController release];
		shareCheckinViewController = nil;
	}
	if (viewID != CHECKED_IN_VIEW	&& self.checkedinViewController != nil) {
		[checkedinViewController.view removeFromSuperview];
		[checkedinViewController release];
		checkedinViewController = nil;
	}
	if (viewID != LOCATIONS_WITH_PROMOTIONS_VIEW	&& self.locationPromotions != nil) {
		[locationPromotions.view removeFromSuperview];	
		[locationPromotions release];
		locationPromotions = nil;
	}
	if (viewID != PROMOTIONS_VIEW	&& self.promosController != nil) {
		[promosController.view removeFromSuperview];
		[promosController release];
		promosController = nil;
	}
	if (viewID != A_PROMOTION_VIEW	&& self.aPromoController != nil) {
		[aPromoController.view removeFromSuperview];
		[aPromoController release];
		aPromoController = nil;
	}
	if (viewID != REDEEMED_VIEW	&& self.redeemedCPController != nil) {
		[redeemedCPController.view removeFromSuperview];
		[redeemedCPController release];

		//		[redeemedCPController release];
		redeemedCPController = nil;
	}
	if (viewID != A_PERSON_VIEW	&& self.aPersonViewController != nil) {
		[aPersonViewController.view removeFromSuperview];	
		[aPersonViewController release];
		aPersonViewController = nil;
	}
	if (viewID != SEND_MESSAGE_VIEW	&& self.messageViewController != nil) {
		[messageViewController.view removeFromSuperview];	
		[messageViewController release];
		messageViewController = nil;
	}
	if (viewID != WEBSITE_VIEW	&& self.websiteView != nil) {
		[websiteView removeFromSuperview];	
		[websiteView release];
		websiteView = nil;
	}
	if (viewID != NEW_LOCATION_VIEW	&& self.newLocationViewController != nil) {
		[self.newLocationViewController.view removeFromSuperview];	
		[newLocationViewController release];
		newLocationViewController = nil;
	}
	if (viewID != PLACE_MAP_VIEW	&& self.placeMapViewController != nil) {
		[self.placeMapViewController.view removeFromSuperview];	
		[placeMapViewController release];
		placeMapViewController = nil;
	}
	if (viewID != CAFE_VIEW	&& self.cafeViewController != nil) {
		[self.cafeViewController.view removeFromSuperview];	
		[cafeViewController release];
		cafeViewController = nil;
	}
	if (viewID != RESTAURANT_VIEW	&& self.restaurantViewController != nil) {
		[self.restaurantViewController.view removeFromSuperview];
		[restaurantViewController release];
		restaurantViewController = nil;
	}
	if (viewID != NIGHTLIFE_VIEW	&& self.nightLifeViewController != nil) {
		[self.nightLifeViewController.view removeFromSuperview];
		[nightLifeViewController release];
		nightLifeViewController = nil;
	}	
	if (viewID != SHOPPING_VIEW	&& self.shoppingViewController != nil) {
		[self.shoppingViewController.view removeFromSuperview];
		[shoppingViewController release];
		shoppingViewController = nil;
	}		
	if (viewID != LODGING_VIEW	&& self.lodgingViewController != nil) {
		[self.lodgingViewController.view removeFromSuperview];
		[lodgingViewController release];
		lodgingViewController = nil;
	}	
}



- (void) hideHomeButton 
{	
	[self.view viewWithTag:2001].hidden = TRUE;
}


- (void) hideTopBar {
	//	[self.view viewWithTag:1000].hidden = TRUE;
	
	[self.view viewWithTag:2000].hidden = TRUE;
	[self.view viewWithTag:2001].hidden = TRUE;
	[self.view viewWithTag:2002].hidden = TRUE;
}

- (void) showTopBar {
	//	[self.view viewWithTag:1000].hidden = TRUE;
	
	[self.view viewWithTag:2000].hidden = FALSE;  // tool bar
	[self.view viewWithTag:2001].hidden = FALSE;	// home button
	[self.view viewWithTag:2002].hidden = FALSE;	// back button
}

- (void) bringTopBarToFront {
	//	[self.view viewWithTag:1000].hidden = TRUE;
	
	[self.view bringSubviewToFront: [self.view viewWithTag:2000]];
	[self.view bringSubviewToFront: [self.view viewWithTag:2001]];
	[self.view bringSubviewToFront: [self.view viewWithTag:2002]];
}

- (void) pushView: (int) viewID {
	NSNumber *viewIDNumber = [[NSNumber alloc] initWithInt:viewID];
	
	// if the top of the stack already contains the viewid, don't push it
	if ([viewStack count] > 0) {
		NSNumber *idAtTop = [viewStack objectAtIndex:  [viewStack count] -1];
		
		if ([idAtTop isEqualToNumber:viewIDNumber]) 
			return;
	}
	[viewStack addObject: viewIDNumber];  // adds at end
	//	MizoonLog(@"PUSH---->View stack size=%d  View=%d", [viewStack count], viewID);
}


- (int) topView {
	return [[viewStack objectAtIndex: [viewStack count] -1] intValue];
}


- (int) topPlusOneView {
	return [[viewStack objectAtIndex: [viewStack count] -2] intValue];
}


- (int) popView {
	
	if (![viewStack count]) 
		return 0;
	
	NSNumber *viewID = [viewStack objectAtIndex: [viewStack count] -1];  // take out the last one
	NSNumber *mainNumber = [[NSNumber alloc] initWithInt:MAIN_VIEW];
	
	// don't pop the main_view at the bottomof the stack
	if ([viewID isEqualToNumber:mainNumber] && [viewStack count] == 1) {
		[mainNumber release];
		return 0;
	}
	
	[viewStack removeObjectAtIndex:  [viewStack count] -1];
	[viewID release];
	[mainNumber release];
	
	return [[viewStack objectAtIndex: [viewStack count] -1] intValue];
}


- (void) popToBase {
	
	NSNumber *mainViewID = [[NSNumber alloc] initWithInt:MAIN_VIEW];
	NSArray *viewStackCopy = [NSArray arrayWithArray:viewStack];
	
	//	[self printViewStack];
	for (NSNumber *viewID in viewStackCopy) {
        if (![viewID isEqualToNumber:mainViewID]) {
			[viewStack removeObject:viewID];
        }
	}
	//	[self printViewStack];
}



- (void) printViewStack {
	MizoonLog(@"viewStack--");
	
	for (NSNumber *viewID in viewStack) {
		MizoonLog(@"%@ ", viewID);
	}
}



- (BOOL) isInViewStack: (int) viewID {
	
	NSNumber *viewIDNumber = [[NSNumber alloc] initWithInt:viewID];
	
	for (NSNumber *mizView in viewStack) {
        if ([mizView isEqualToNumber:viewIDNumber]) {
			[viewIDNumber release];
			return TRUE;
        }
	}
	[viewIDNumber release];
	return FALSE;
}

- (void) homeView {
	//	if (self.blueViewController == nil) {
	//		MizMenuViewController *blueController = [[MizMenuViewController alloc] initWithNibName:@"BlueView" bundle:0];
	//		[self.view insertSubview:blueController.view atIndex:0];
	//		
	//		[blueController release];	
	//	}
	//	[self prepareToDisplay:MAIN_VIEW];
	//	[self.view insertSubview:blueViewController.view atIndex:0];
	//	[self popToBase];
	
	if (self.mainScrollController == nil) {
		MainScrollViewController *mainController = [[MainScrollViewController alloc] initWithNibName:@"MainScrollView" bundle:0];
		[self.view insertSubview:mainController.view atIndex:0];
		
		[mainController release];	
	}
	[self prepareToDisplay:MAIN_VIEW];
	[self.view insertSubview:mainScrollController.view atIndex:0];
	[self popToBase];
	
	//	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	//	
	//	// hide the rootview bottom toolbar
	//	[rvc.view viewWithTag:1000].hidden = TRUE;
	[self hideTopBar];
}	


- (void) goBack {
	
	int topView = [self popView];
//	[self prepareToDisplay:topView];

	[self renderView: topView fromView: INIT_VIEW];
	//	[self renderView: self.prevView fromView: INIT_VIEW];
}	

- (void) renderLoadMessage: (NSString *) message
{
	progressAlert = [[MizProgressHUD alloc] initWithLabel:message];
	[progressAlert show];
	
	self.isAlertVisible = YES;
}



- (void) hideLoadMessage
{
	if (isAlertVisible) {
		[progressAlert dismissWithClickedButtonIndex:0 animated:YES];
		[progressAlert release];
		
		self.isAlertVisible = NO;
	}
}

- (IBAction) reloadView:(int) viewID 
{
	MizDataManager *dm = [MizDataManager sharedDataManager];

	int	radius=2;

	switch (viewID) {
		case PLACES_VIEW:
	
//			[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(renderPlacesData:) name:@"MZ_Have_Places_Data" object:nil];
//			[[MizDataManager sharedDataManager] fetchNearbyPlaces:cafeViewController];
			
			[placesViewController.view removeFromSuperview];
			
			if (self.placesViewController != nil) 
				self.placesViewController = nil;
			
			PlacesViewController *placesController = [[PlacesViewController alloc] initWithNibName:@"PlacesView" bundle:nil];
			placesController.rootViewController = self;
			self.placesViewController = placesController;
			[placesController release];
			
			
			[self prepareToDisplay:PLACES_VIEW];		
			[self.view insertSubview:placesViewController.view atIndex:0];
			[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Places_Data" object:nil];	 
			
			[self hideLoadMessage];
			break;
			
		case CAFE_VIEW:
//			[dm fetchNearbyCafe:self];

			[cafeViewController.view removeFromSuperview];
			if (self.cafeViewController != nil) 
				cafeViewController = nil;
			
			CafeViewController *cafeController = [[[CafeViewController alloc] init] retain];
			self.cafeViewController = cafeController;
			[cafeController release];
			
			[self.view insertSubview:cafeViewController.view atIndex:0];
			self.prevView = MAIN_VIEW;
			break;
			
		case RESTAURANT_VIEW:
//			[dm fetchNearbyRestaurants:self];
			
			[restaurantViewController.view removeFromSuperview];
			if (self.restaurantViewController != nil) 
				restaurantViewController = nil;
			
			RestaurantViewController *restController = [[[RestaurantViewController alloc] init] retain];
			self.restaurantViewController = restController;
			[restController release];
			
			[self.view insertSubview:restaurantViewController.view atIndex:0];
			self.prevView = MAIN_VIEW;
			break;
		
		case NIGHTLIFE_VIEW:
//			[dm fetchNearbyNightLife:self];
			
			[nightLifeViewController.view removeFromSuperview];
			if (self.nightLifeViewController != nil) 
				nightLifeViewController = nil;
			
			NightLifeViewController *NLController = [[[NightLifeViewController alloc] init] retain];
			self.nightLifeViewController = NLController;
			[NLController release];
			
			[self.view insertSubview:nightLifeViewController.view atIndex:0];
			self.prevView = MAIN_VIEW;
			break;
			
		case SHOPPING_VIEW:
//			[dm fetchNearbyShopping:self];
			
			[shoppingViewController.view removeFromSuperview];
			if (self.shoppingViewController != nil) 
				shoppingViewController = nil;
			
			ShoppingViewController *sViewController = [[[ShoppingViewController alloc] init] retain];
			self.shoppingViewController = sViewController;
			[sViewController release];
			
			[self.view insertSubview:shoppingViewController.view atIndex:0];
			self.prevView = MAIN_VIEW;
			break;

		case LODGING_VIEW:
//			[dm fetchNearbyLodging:self];
			
			[lodgingViewController.view removeFromSuperview];
			if (self.lodgingViewController != nil) 
				lodgingViewController = nil;
			
			LodgingViewController *lViewController = [[[LodgingViewController alloc] init] retain];
			self.lodgingViewController = lViewController;
			[lViewController release];
			
			[self.view insertSubview:lodgingViewController.view atIndex:0];
			self.prevView = MAIN_VIEW;
			break;
			
			
		case POSTS_VIEW:
			
			if ([dm fetchNearbyPosts: radius atIndex:0 numberToRet:NUM_POSTS_TO_FETCH ] == nil) {				
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Unable to locate any posts near you. Please try again in a few minutes." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
				[alert show];
				[alert release];		
				
				return;
			}
	
			[postsViewController.view removeFromSuperview];
			if (self.postsViewController != nil) 
				self.postsViewController = nil;
			
			PostsViewController *postsController = [[PostsViewController alloc] initWithNibName:@"PostsView" bundle:nil];
			
			self.postsViewController = postsController;
			[postsController release];
			[self.view insertSubview:postsViewController.view atIndex:0];
			self.prevView = MAIN_VIEW;
			
			break;
			
		case PEOPLE_VIEW:
			
			[dm clearNearbyList];
			if ([dm fetchNearbyPeople: radius atIndex:0 numberToRet:NUM_PEOPLE_TO_FETCH ] == nil) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Unable to locate nearby people at this time. Please try again in a few seconds." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
				[alert show];
				[alert release];		
				return;
			}
			[nearbyPeopleController.view removeFromSuperview];
			if (self.nearbyPeopleController != nil) 
				self.nearbyPeopleController = nil;
			
			NearbyPeopleController *peopleController = [[NearbyPeopleController alloc] initWithNibName:@"NearbyPeople" bundle:nil];
			
			self.nearbyPeopleController = peopleController;
			[peopleController release];
			[self.view insertSubview:nearbyPeopleController.view atIndex:0];
			self.prevView = MAIN_VIEW;
			
			break;
			
		case LOCATIONS_WITH_PROMOTIONS_VIEW:
			
			if ([dm fetchLocationsWithPromos:radius atIndex:0 numberToRet:100] == nil) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Unable to locate nearby promotions at this time. Please try again in a few seconds." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
				[alert show];
				[alert release];		
				return;
			}
			[locationPromotions.view removeFromSuperview];
			if (self.locationPromotions != nil) 
				self.locationPromotions = nil;
			
			LocationPromoController *locWithPromo = [[LocationPromoController alloc] initWithNibName:@"LocationPromotions" bundle:nil];
			
			self.locationPromotions = locWithPromo;
			[locWithPromo release];
			[self.view insertSubview:locationPromotions.view atIndex:0];
			self.prevView = MAIN_VIEW;
			
			break;
			
			
	}
}		
			
		
- (UIView *)findCurrentView
{
//    if (self.view.isFirstResponder) {        
//        return self.view;     
//    }
//	
//    for (UIView *subView in self.view.subviews) {
//        UIView *firstResponder = [subView findCurrentView];
//		
//        if (firstResponder != nil) {
//			return firstResponder;
//        }
//    }
	
    return nil;
}


- (void) testMethod {
//	MizoonServer *server = [MizoonServer alloc];
	
//	NSArray *places = [server getNearbyPlaces];
	printf("Please enter a word:");
    fflush(stdout);
}


- (IBAction) switchViews:(id) sender {
	/*
	UIButton *button = (UIButton*) sender;
	
	MizoonLog(@"user clicked: %@", sender);
//	MizoonLog(@"sender string: %s", [sender stringValue]);
//	MizoonLog(@"tag sender: %d", [sender tag] );
	MizoonLog(@"button title %@", [button currentTitle]);
	MizoonLog(@"button tag %@", [button tag]);
	MizoonLog(@"button name %@", [button currentTitle]);

*/
	
	[UIView beginAnimations:@"View Flip"  context:nil];
	[UIView setAnimationDuration:1.25];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	
	if (self.yellowViewController.view.superview == nil) {
		if (self.yellowViewController == nil) {
			YellowViewController *yellowController = [[YellowViewController alloc] initWithNibName:@"YellowView" bundle:nil];
			
			self.yellowViewController = yellowController;
			[yellowController release];
		}
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
		[blueViewController viewWillAppear:YES];
		[yellowViewController viewWillDisappear:YES];
		
		[blueViewController.view removeFromSuperview];
		[self.view insertSubview:yellowViewController.view atIndex:0];
		
		[yellowViewController viewWillDisappear:YES];
		[blueViewController viewDidAppear:YES];
	} else {
		if (self.blueViewController == nil) {
			MainViewController *blueController = [[MainViewController alloc] initWithNibName:@"BlueView" bundle:0];
			[self.view insertSubview:blueController.view atIndex:0];
			
			[blueController release];	
		}
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
		[yellowViewController viewWillAppear:YES];
		[blueViewController viewWillDisappear:YES];

		
		[yellowViewController.view removeFromSuperview];
		[self.view insertSubview:blueViewController.view atIndex:0];

		[blueViewController viewWillDisappear:YES];
		[yellowViewController viewDidAppear:YES];

	}
	[UIView commitAnimations];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	MizoonLog(@"---------------> didReceiveMemoryWarning: RootView");

	ImageCache *imageChache = [ImageCache sharedImageCache];

	[imageChache freeCacheSlots];
	
	// Release any cached data, images, etc that aren't in use.
	if (self.blueViewController.view.superview == nil) {
		self.blueViewController = nil;
	} else {
		self.yellowViewController = nil;
	}

}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
//	self.locationManager = nil;
}


- (void)dealloc {
//	[locationManager release];
	[yellowViewController release];
	[blueViewController release];
    [super dealloc];
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[[Mizoon sharedMizoon] hideLoadMessage];
}

@end
