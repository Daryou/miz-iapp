//
//  RootViewController.h
//  Mizoon main view controller
//
//  Created by Daryoush Paknad on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import	"Constants.h"

@class	TestViewController;

@class	LocationController;
@class	MainScrollViewController;
@class	MainViewController;
@class	YellowViewController;
@class	PlacesViewController;
@class	ALocationViewController;
@class	NearbyPeopleController;
@class	LoginViewController;
@class	RegLoginViewController;
@class	SigninViewController;
@class	RegisterViewController;
@class	SettingsViewController;
@class	PostsViewController;
@class	APostViewController;
@class	NewPostViewController;
@class	ConfirmCheckinViewController;
@class	CheckedinViewController;
@class	LocationPromoController;
@class	PromosController;
@class	APromotionController;
@class	RedeemedCPController;
@class	APersonViewController;
@class	MessageViewController;
@class	NewLocationViewController;
@class	PlaceMapViewController;
@class	CafeViewController;
@class	RestaurantViewController;
@class	NightLifeViewController;
@class	ShoppingViewController;
@class	LodgingViewController;

@protocol MizoonRootControllerDelegate;


@interface RootViewController : UIViewController <CLLocationManagerDelegate, UIWebViewDelegate> {
	NSMutableArray				*viewStack;
	BOOL						isAlertVisible;
	LocationController			*locationController;
	NSInteger					prevView;
	
	UIAlertView					*progressAlert;

	TestViewController				*testViewController;

	MainScrollViewController		*mainScrollController;
	MainViewController			*blueViewController;
	YellowViewController			*yellowViewController;
	PlacesViewController			*placesViewController;
	NearbyPeopleController			*nearbyPeopleController;
	ALocationViewController		*extLocationViewController;
	LoginViewController				*loginViewController;
	RegLoginViewController			*regLoginViewController;
	SigninViewController			*signinViewController;
	RegisterViewController			*registerViewController;
	SettingsViewController			*settingsViewController;
	PostsViewController				*postsViewController;
	APostViewController				*aPostViewController;
	NewPostViewController			*newPostViewController;
	ConfirmCheckinViewController		*shareCheckinViewController;
	CheckedinViewController			*checkedinViewController;
	LocationPromoController			*locationPromotions;
	PromosController				*promosController;
	APromotionController			*aPromoController;
	RedeemedCPController			*redeemedCPController;
	APersonViewController			*aPersonViewController;
	MessageViewController			*messageViewController;
	NewLocationViewController		*newLocationViewController;
	PlaceMapViewController			*placeMapViewController;
	CafeViewController				*cafeViewController;
	RestaurantViewController		*restaurantViewController;
	NightLifeViewController			*nightLifeViewController;
	ShoppingViewController			*shoppingViewController;
	LodgingViewController			*lodgingViewController;
	
	UIWebView						*websiteView;
	
	id<MizoonRootControllerDelegate> delegate;

}


@property (nonatomic, retain) UIAlertView *progressAlert;


@property (nonatomic, retain) LocationController *locationController;

@property NSInteger				prevView;
@property BOOL					isAlertVisible;
@property (nonatomic, retain)	UIWebView						*websiteView;

@property (nonatomic, retain)	TestViewController				*testViewController;

@property (nonatomic, retain)	MainScrollViewController		*mainScrollController;
@property (nonatomic, retain)	MainViewController			*blueViewController;
@property (nonatomic, retain)	YellowViewController			*yellowViewController;
@property (nonatomic, retain)	PlacesViewController			*placesViewController;
@property (nonatomic, retain)	NearbyPeopleController			*nearbyPeopleController;
@property (nonatomic, retain)	ALocationViewController		*extLocationViewController;
@property (nonatomic, retain)	LoginViewController				*loginViewController;
@property (nonatomic, retain)	RegLoginViewController			*regLoginViewController;
@property (nonatomic, retain)	SigninViewController			*signinViewController;
@property (nonatomic, retain)	RegisterViewController			*registerViewController;
@property (nonatomic, retain)	SettingsViewController			*settingsViewController;
@property (nonatomic, retain)	PostsViewController				*postsViewController;
@property (nonatomic, retain)	APostViewController				*aPostViewController;
@property (nonatomic, retain)	NewPostViewController			*newPostViewController;
@property (nonatomic, retain)	ConfirmCheckinViewController		*shareCheckinViewController;
@property (nonatomic, retain)	CheckedinViewController			*checkedinViewController;
@property (nonatomic, retain)	LocationPromoController			*locationPromotions;
@property (nonatomic, retain)	PromosController				*promosController;
//@property (nonatomic, retain)	APromoController				*aPromoController;
@property (nonatomic, retain)	APromotionController			*aPromoController;
@property (nonatomic, retain)	RedeemedCPController			*redeemedCPController;
@property (nonatomic, retain)	APersonViewController			*aPersonViewController;
@property (nonatomic, retain)	MessageViewController			*messageViewController;
@property (nonatomic, retain)	NewLocationViewController		*newLocationViewController;
@property (nonatomic, retain)	PlaceMapViewController			*placeMapViewController;
@property (nonatomic, retain)	CafeViewController				*cafeViewController;
@property (nonatomic, retain)	RestaurantViewController		*restaurantViewController;
@property (nonatomic, retain)	NightLifeViewController			*nightLifeViewController;
@property (nonatomic, retain)	ShoppingViewController			*shoppingViewController;
@property (nonatomic, retain)	LodgingViewController			*lodgingViewController;


@property (nonatomic, assign) 	id<MizoonRootControllerDelegate> delegate;


- (void) renderLoadMessage: (NSString *) message;
- (void) hideLoadMessage;

- (IBAction)	switchViews:(id) sender;
- (void)		prepareToDisplay: (int) viewID;
- (IBAction)	renderView:(int) viewID fromView:(int) currentViewID;
- (IBAction)	reloadView:(int) viewID;
- (void)		reloadPostsView;
- (void)		removeView: (int) viewID;
- (IBAction)	homeView;
- (IBAction)	settingsView;
- (IBAction)	goBack;
- (void)		getNearbyPosts;
- (void)		reloadRenderPostsView;
- (void)		reloadConfirmCheckin;
- (void)		reloadSetup;
- (void)		prepareToReleadALocation;
- (void)		pushView: (int) viewID;
- (int)			topPlusOneView;
- (int)			popView;
- (int)			topView;
- (void)		popToBase;
- (BOOL)		isInViewStack: (int) viewID;
- (void)		printViewStack;
- (void)		hideTopBar;
- (void)		hideHomeButton;
- (void)		showTopBar;
- (void)		bringTopBarToFront;
//- (void)		websiteViewWithRequest:(NSURLRequest *) requestObj;
- (void) websiteViewWithRequest:(NSURLRequest *) requestObj yScroll: (CGFloat) rollUp;

- (void) testMethod;
@end
