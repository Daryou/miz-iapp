//
//  Mizoon.h
//  Mizoon
//
//  Created by Daryoush Paknad on 5/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import	"Constants.h"
#import "MizoonAppDelegate.h"
#import	"MizDataManager.h"
#import	"RootViewController.h"
#import	"MizProgressHUD.h"
#import	"Utilities.h"
#import	"MizoonLocation.h"
#import	"MizoonerProfiles.h"
#import	"Facebook.h"
#import	"FBConnect.h"
#import "TwtOAuthEngine.h"
#import	"Mizooner.h"


@class TwtOAuthEngine;
@class Reachability;



typedef enum  {
	PlacesData = 0,
	NearbyPeopleData,
	NearbySalesData,
	NearbyPostsData,
	LocationsWithPromoData,
	NearbyCafeData,
	NearbyRestaurantData,
	NearbyNLData,
	NearbyShoppingData,
	NearbyLodgingData
} MizoonDataTypes;

NSArray const *testList;


@interface Mizoon : NSObject <FBSessionDelegate, FBRequestDelegate, FBDialogDelegate, SA_OAuthTwitterEngineDelegate, MKMapViewDelegate>{
	BOOL					networkConnection;
//	FBSession				*fbSession;
//	IBOutlet FBLoginButton	*fbLoginButton;
	Facebook				*fbSession;

	TwtOAuthEngine			*twtOAuthEngine;
	NSOperationQueue		*operationQueue;
	NSDictionary			*sPromoDict;
	int						sPromoRow;
	int						sPromoLid;
	NSUInteger				sPerson;
	MizoonerProfiles		*sPersonProfile;
	NSUInteger				sLocationNum;
	MizoonLocation			*sLocation;
	int						lastSelectedLid;
	int						selectedPost;
	NSString				*redeemedCP;
	NSMutableArray			*locSearchRes;
	BOOL					tmpCheckin;
	Reachability			*hostReach;
    Reachability			*internetReach;
    Reachability			*wifiReach;
	int						clickedView;    // llast main view that was clicked on; used in Mizdata to resore view if it fails to fetch data
	MKMapView				*coreMapView;
	NSDate					*methodStart;
}

+ (Mizoon *)sharedMizoon;

@property (nonatomic, retain) NSDate	*methodStart;

@property BOOL  networkConnection;
@property int  clickedView;

//@property (nonatomic, retain) FBSession *fbSession;
@property (nonatomic, retain) Facebook *fbSession;

@property (nonatomic, retain) TwtOAuthEngine *twtOAuthEngine;

@property (nonatomic, retain) NSDictionary *sPromoDict;
@property (nonatomic, retain) MizoonLocation *sLocation;

@property (retain) NSOperationQueue *operationQueue;

@property (nonatomic, retain) NSMutableArray *locSearchRes;


@property int sPromoLid;
@property int sPromoRow;
@property int lastSelectedLid;
@property BOOL  tmpCheckin;

@property NSUInteger sPerson;
@property NSUInteger sLocationNum;

@property int selectedPost;

@property (nonatomic, copy) NSString			*redeemedCP;



#pragma mark helper
- (void) postError: (NSString *) name withErrNum:(NSString *) errNum andErrDesc: (NSString *) errDesc;
- (BOOL) hasNetworkConnection;
- (void) networkConnectionAlert;

- (float) getUserlat;
- (float) getUserlon;
- (NSString *) getUserName;
- (NSString *) getUserPassword;
- (NSUInteger) getMizoonerPoints;
- (void) setMizoonerPoints: (NSUInteger) points;
- (void) showLoadMessage: (NSString *) message;
- (void) hideLoadMessage;

- (RootViewController *) getRootViewController;
- (void) updateLocation;


- (BOOL) needToFetchData: (MizoonDataTypes) dataType;
- (BOOL) isCoupon: (NSDictionary *) thePromo;
- (NSDictionary *) getSelectedPersonDict;
- (void) setSelectedPerson: (NSUInteger) row;
- (void) setSelectedPersonFromDict: (NSDictionary *) personDict;
- (MizoonerProfiles *) getSelectedPersonProfile;
- (NSString *) getSelectedPersonUName;
- (NSString *) getSelectedPersonUID;

- (NSDictionary *) getSelectedPromo;

- (NSMutableArray *) getVisitors;
- (NSInteger) getNumberOfVisitors;
- (void) setSelectedVisitor: (NSUInteger) row;
- (void) setSelectedLocationFromArray: (NSArray *) locations atIndex: (NSUInteger) row;
- (void) setSelectedLocationAtRow: (NSUInteger) row;
- (void) setSelectedLocation:(NSDictionary *) locationDict;
- (MizoonLocation *) getSelectedLocation;
- (void) checkinSelectedLocation;
- (void) checkinWithMessage: (NSString *) message;
- (MizoonLocation *) getNthLocation: (NSUInteger) row;
- (NSMutableArray *) nearbyRestaurnats;
- (NSMutableArray *) nearbyCafes;
- (NSMutableArray *) nearbyLocations;
- (NSMutableArray *) nearbyNightLife;
- (NSMutableArray *) nearbyShopping;
- (NSMutableArray *) nearbyLodging;
- (void) temporaryCheckin;
- (void) resetTmpCheckin;
- (BOOL) isTemporaryCheckedin;


- (BOOL) isUserFBAuthenticated;
- (void)setFBStatus:(NSString *)statusString atLocation: (MizoonLocation *) location;
//- (UIImage *) getImageForLoction: (NSString *) name catrgory: (NSString *) type subType: (NSString *) subType;
- (NSString *) getIconForLoction: (NSString *) name catrgory: (NSString *) type subType: (NSString *) subType;
- (void)postFBStatus:(NSString *)statusMessage;
- (void) mizFBLogin;
- (void) mizFBLogout;

- (NSArray *) getPosts;
- (NSDictionary *) getSelectedPost;

- (NSString*)md5HexDigest:(NSString*)input;
- (NSString *) getApplicationKey;

#pragma mark Twitter 
//- (void) testTwitter;
- (BOOL) isLoggedInTwitter;
- (void)postToTwitter:(NSString *)message;
- (void)postToTwitter:(NSString *)message atLocation: (MizoonLocation *) location;
- (void) twitterLogout;
- (void) twitterLogin: (NSString *) data;
- (void) initTwitter;

@end
