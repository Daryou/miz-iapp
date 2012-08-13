//
//  MizDataManager.h
//  Mizoon
//
//  Created by Daryoush Paknad on 2/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	"XMLRPCRequest.h"
#import	"XMLRPCResponse.h"
#import	"XMLRPCConnection.h"
#import <CoreLocation/CoreLocation.h>
#import	"Constants.h"
#import	"MizoonLocation.h"
#import "GAConnectionDelegate.h"



#import <FactualSDK/FactualAPI.h>
#import <FactualSDK/FactualQuery.h>


@class GAConnectionManager;

#define MIZOON_SERVICE "mizoon.com"


// NSUserDefaults keys
#define kIsAuthenticated			@"isAuthenticated"
#define kIsFBAuthenticated			@"isFBAuthenticated"
#define kIsTwtAuthenticated			@"isTwtAuthenticated"

#define kUsername					@"userName"
#define	kUserPoints					@"points"


typedef struct  chkInfo {
	float		lat;
	float		lon;
	NSString	*name;
	int			lid;	
} CheckinInfo;

@interface MizDataManager : NSObject <GAConnectionDelegate,FactualAPIDelegate> {

@private
    NSMutableArray		*photosDB;
	BOOL				isAuthenticatedMizUser;	
	BOOL				isFBAuthenticatedUser;	
	BOOL				isTwtAuthenticatedUser;	

	BOOL				checkedin;
	CheckinInfo			*checkedinLoc;
	NSString			*username;
    NSString			*currentDirectoryPath;
	NSString			*sessionId;
    NSOperationQueue	*asyncOperationsQueue;
	BOOL				isProblemWithXMLRPC;

	CLLocation			*currentLocation;
	CLLocation			*prevLocation;

	
//	MizoonLocation		*selectedLocation;
	
	NSArray				*nearbyPeople;
	int					nearbyPeopleSize;
	NSArray				*locationPeople;
	int					locationPeopleSize;
	NSArray				*nearbyPlaces;
	int					nearbyPlacesSize;
	NSArray				*nearbySales;
	int					nearbySalesSize;
	NSArray				*nearbyCoupons;
	int					nearbyCouponsSize;
	NSArray				*nearbyPosts;
	int					nearbyPostsSize;
	NSArray				*locationsWithPromos;
	int					promoLocSize;
	NSArray				*promotions;
	int					promoSize;

	NSMutableData		*asyncPostData;
	
	
	NSDate			*placesLastFetch;
	NSDate			*peopleLastFetch;
	NSDate			*postsLastFetch;
	NSDate			*promosLastFetch;
	NSDate			*cafesLastFetch;
	NSDate			*restaurantsLastFetch;
	NSDate			*nightLastFetch;
	NSDate			*shopsLastFetch;
	NSDate			*lodgeLastFetch;

	NSMutableArray			*visitorList;
	NSMutableArray			*fetchedData;
	NSMutableArray			*cafeList;
	NSMutableArray			*restaurantList;
	NSMutableArray			*placesList;
	NSMutableArray			*nightLifeList;
	NSMutableArray			*shoppingList;
	NSMutableArray			*lodgingList;
	
	GAConnectionManager *geoapiManager_;
    /************* FACTUAL ****************/
    
	FactualAPI              *_factualObject;
    NSMutableDictionary     *_factualObjPrefs;
    FactualQueryResult      *_queryResult;
    NSTimeInterval          _requestStartTime;
    FactualAPIRequest       *_activeRequest;

    /************* END FACTUAL ************/
    

}

+ (MizDataManager *)sharedDataManager;
@property (nonatomic, retain) NSDate *placesLastFetch, *peopleLastFetch, *postsLastFetch, *promosLastFetch, *cafesLastFetch, *restaurantsLastFetch, *nightLastFetch, *shopsLastFetch, *lodgeLastFetch;
@property (nonatomic, retain) NSMutableArray *fetchedData;
@property (nonatomic, retain) NSMutableArray *visitorList;
@property (nonatomic, retain) NSMutableArray *placesList;
@property (nonatomic, retain) NSMutableArray *cafeList;
@property (nonatomic, retain) NSMutableArray *restaurantList;
@property (nonatomic, retain) NSMutableArray *nightLifeList;
@property (nonatomic, retain) NSMutableArray *shoppingList;
@property (nonatomic, retain) NSMutableArray *lodgingList;

@property (nonatomic, retain) NSArray		*nearbyPeople;
@property (nonatomic, retain) NSArray		*locationPeople;
@property (nonatomic, retain) NSArray		*nearbyPlaces;
@property (nonatomic, retain) NSArray		*nearbySales;
@property (nonatomic, retain) NSArray		*nearbyCoupons;
@property (nonatomic, retain) NSArray		*nearbyPosts;
@property (nonatomic, retain) NSArray		*locationsWithPromos;
@property (nonatomic, retain) NSArray		*promotions;

//@property (nonatomic, retain) MizoonLocation		*selectedLocation;

@property (nonatomic, retain) CLLocation	*currentLocation;
@property (nonatomic, retain) CLLocation	*prevLocation;

@property (nonatomic, retain) NSString		*username;

@property (nonatomic, retain) NSMutableArray	*photosDB;
@property (nonatomic, copy) NSString			*currentDirectoryPath;
@property (nonatomic, copy) NSString			*sessionId;

@property (nonatomic, assign) BOOL				isProblemWithXMLRPC; 
@property (nonatomic, assign) BOOL				isAuthenticatedMizUser; 
@property (nonatomic, assign) BOOL				isFBAuthenticatedUser; 
@property (nonatomic, assign) BOOL				isTwtAuthenticatedUser;

@property (nonatomic, assign) BOOL				checkedin; 
@property CheckinInfo	*checkedinLoc;

@property int	nearbyPeopleSize;
@property int	nearbyPlacesSize;
@property int	nearbyPostsSize;
@property int	nearbySalesSize;
@property int	nearbyCouponsSize;
@property int	locationPeopleSize;
@property int	promoLocSize;
@property int	promoSize;


- (BOOL) fetchVisitors: (MizoonLocation *) theLocation;
- (void) placesSearch: (NSString *) searchText;
- (void) placeRegExpSearch: (NSString *) searchText;
- (void) fetchNearbyNightLife: (id) delegate;
- (void) fetchNearbyShopping: (id) delegate;
- (void) fetchNearbyLodging: (id) delegate;
- (void) fetchNearbyCafe: (id) delegate;
- (void) fetchNearbyRestaurants: (id) delegate;
- (void) fetchNearbyPlaces: (id) delegate;
- (void) clearNearbyList;
- (NSArray *) fetchNearbyPlaces: (int) radius atIndex: (int) index numberToRet:(int)num_ret;
- (NSArray *) fetchNearbyPeople: (int) radius atIndex: (int) index numberToRet:(int)num_ret;
- (NSArray *) fetchNearbyPosts: (int) radius atIndex: (int) index numberToRet:(int)num_ret;
- (NSArray *) fetchLocationsWithPromos: (int) radius atIndex: (int) index numberToRet:(int)num_ret;
- (NSArray *) fetchPromotions: (int) lid;

- (void) doFactualQuery;
-(void) clearFactualReferences;

    
- (BOOL) sendFriendRequest:  (NSString *) uid;
- (BOOL) sendMessage: (NSString *) message  recipient: (NSString *) uid;
//- (BOOL) uploadPost: (NSString *) message withPhoto: (UIImage *) photo;
- (NSArray *) uploadPost:  (NSString *) message withPhoto: (UIImage *) photo  postRadius: (int) radius  numberToRet: (int) num_ret;
- (BOOL) checkin: (NSDictionary *) location;
- (BOOL) checkinMizoonLoc: (MizoonLocation *) mizLocation;
- (BOOL) checkinLocaton: (MizoonLocation *) mizLocation withMessage: checkinMsg;

- (BOOL) redeemCoupon:(NSString *) prid fromLocation: (NSString *) lid;
- (BOOL) authenticate: (NSString *) uname withPaswword: (NSString *) password;
- (BOOL) NSLogout: (NSString *) username;
- (BOOL) mizoonRegister: (NSString *) uid withPassword: (NSString *) password andEmail:(NSString *)email zip: (NSString *) zip andPhone: (NSString *) phone ;


- (void) mizAyncPost: (NSString *) postUrl postBody: (NSData *) body;
- (XMLRPCResponse *)executeXMLRPCRequest:(XMLRPCRequest *)req byHandlingError:(BOOL)shouldHandleFalg;
- (NSError *)errorWithResponse:(XMLRPCResponse *)res shouldHandle:(BOOL)shouldHandleFlag;
- (NSError *)defaultError;
- (BOOL)handleError:(NSError *)err;


#pragma mark Helper
- (void) releaseVisitors;
- (BOOL) userIsInThisPlace: (NSString *) name latitude: (float) lat longitude: (float) lon;
	
#pragma mark -
#pragma mark CRUD for keychain Passwords
-(NSString*) getMizPasswordFromKeychainWithUsername:(NSString *)userName;
-(void) saveMizPasswordToKeychain:(NSString *)password andUserName:(NSString *)userName;
-(void) updateMizPasswordInKeychain:(NSString *)password andUserName:(NSString *)userName;
-(void) deleteMizFromKeychain:(NSString *)userName;


@end
