//
//  MizDataManager.m
//  Mizoon
//
//  Created by Daryoush Paknad on 2/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MizDataManager.h"
#import "SFHFKeychainUtils.h"
#import	"RootViewController.h"
#import	"MizoonAppDelegate.h"
#import	"MizoonUser.h"
#import	"Mizooner.h"
#import	"Constants.h"

#import	"SBJsonParser.h"
#import	"NSData+Base64.h"
#import	"NSString+Helpers.h"
#import	"MizXMLParser.h"


#import	"GAConnectionManager.h"
#import	"NSString+SBJSON.h"
#import	"JSON.h"

#import "NSStringAdditions.h"
#import	"NSDictionary_JSONExtensions.h"
#import "CLLocation (Strings).h"


#define SGEO

#ifdef SGEO
NSString *SimpleGeoURL = @"http://api.simplegeo.com";
NSString *SGSecretKey = @"Y8fJhTPjEcqFvkSVM9PdFtcFhSxKYneh";
NSString *SGConsumerKey = @"WekCeY4kXZa3DSfxMdtAXDzFsYWUmETL";
NSString *SGOauthVersion = @"1.0";
NSString *globalRadius = @"8";  // 8 kilometers

#import "hmac.h"
#import "Base64Transcoder.h"

#endif


#define FACTUAL
#ifdef FACTUAL

/************* FACTUAL ****************/

NSString * const PREFS_FACTUAL_TABLE = @"factual_table";
NSString * const PLACES_TABLE_DESC = @"Global Places";
NSString * const RESTAURANTS_TABLE_DESC = @"US Restaurants";

NSString * const PREFS_GEO_ENABLED = @"enable_geo";
NSString * const PREFS_TRACKING_ENABLED = @"enable_track";
NSString * const PREFS_LATITUDE = @"lat";
NSString * const PREFS_LONGITUDE = @"lng";
NSString * const PREFS_RADIUS = @"radius";

NSString * const PREFS_LOCALITY_FILTER_ENABLED = @"enable_locality";
NSString * const PREFS_LOCALITY_FILTER_TYPE = @"locality_type";
NSString * const PREFS_LOCALITY_FILTER_TEXT = @"locality_filter";

NSString * const PREFS_CATEGORY_FILTER_ENABLED = @"enable_category";
NSString * const PREFS_CATEGORY_FILTER_TYPE = @"category_filter";

static NSString* localityFields[] = {
    @"locality",
    @"region",
    @"country",
    @"postcode"
};

static NSString* topLevelCategories[] = { 
    @"Arts, Entertainment & Nightlife",
    @"Automotive",
    @"Business & Professional Services",
    @"Community & Government",
    @"Education",
    @"Food & Beverage",
    @"Health & Medicine",
    @"Legal & Financial",
    @"Personal Care & Services",
    @"Real Estate & Home Improvement",
    @"Shopping",
    @"Sports & Recreation ",
    @"Travel & Tourism"
};
/************* END FACTUAL ************/


#endif


#define NUMBER_TO_RETURN		30


#define kURL @"URL"
#define kMETHOD @"METHOD"
#define kMETHODARGS @"METHODARGS"


#define kLATITUDE			@"latitude"
#define kLONGTITUDE			@"longtitude"
#define kRADIUS				@"radius"
#define kINDEX				@"index"
#define kNUMBER_RETURN		@"num_ret"
#define kUSERNAME			@"username"
#define kPASSWORD			@"password"
#define kSESSID				@"sessid"
#define	kCREDENTIALS		@"credentials"
#define	kEMAIL				@"email"
#define	kLOCATION_NAME		@"loc_name"
#define	kLOCATION_ID		@"loc_id"
#define	kLOCATION_ADDRESS	@"address"
#define	kLOCATION_CITY		@"city"
#define	kLOCATION_STATE		@"state"
#define	kZIP				@"zip"
#define	kPHONE				@"phone"
#define	kLOCATION_WEBSITE	@"website"
#define	kLOCATION_CATEGORY	@"category"
#define	kPHOTO				@"photo"
#define	kPOST_MESSAGE		@"message"
#define	kLID				@"lid"
#define kPROMOTION_ID		@"prid"
#define kRECIPIENT_ID		@"recipient"
#define	kCHECKIN_MESSAGE	@"checkin_msg"

#define SEARCH_RADIUS       5000

NSString *const kGAKeywordFormat = @"http://api.geoapi.com/v1/e/%@/keyword-search?apikey=%@&pretty=1&q=%@";
NSString *searchTerm;

@interface MizDataManager() // private methods
- (BOOL) fetchSessionId;
- (NSArray *) getJSONResponseStream: (NSString *) resSource;
- (NSString *)executeRESTfulAuthRequest:(NSURL *)url withUsername: (NSString *)username andPassword: (NSString *) password;
- (NSString *)executeRESTfulRequest:(NSURL *)url;
- (NSString	*) contructSQuery: (NSString *) searchText;
- (NSString	*) queryCafes: (NSString *) searchText;
- (NSString	*) queryRestaurants: (NSString *) searchText;
- (NSString	*) queryNightLife: (NSString *) searchText;
- (NSString	*) queryPlaces: (NSString *) searchText;
- (NSString	*) queryShopping: (NSString *) searchText;
- (NSString	*) queryLodging: (NSString *) searchText;

- (void) havePlacesData:(NSNotification *)notification;
- (void) haveCafeData:(NSNotification *)notification;
- (void) haveRestaurantData:(NSNotification *)notification;
- (void) haveNLData:(NSNotification *)notification;
- (void) haveLodgingData:(NSNotification *)notification;
- (void) haveShoppingData:(NSNotification *)notification;

#ifdef SGEO
- (BOOL) simpleGeoSendrequest: (NSString *) reqString withRequestParam: (NSMutableDictionary *) requestParam;
- (NSString*) signatureBaseStringFromRequest:(NSURLRequest*)request params:(NSDictionary*)params;
- (NSString *) generateNonce;
- (NSString*) generateTimestamp;
- (NSString*) signText:(NSString*)text withSecret:(NSString*)secret;
- (NSString*) normalizeRequestParams:(NSDictionary*)params;
#endif	

@end


@implementation MizDataManager

static MizDataManager *sharedDataManager;

//@synthesize selectedLocation;
@synthesize currentLocation, prevLocation;
@synthesize photosDB, currentDirectoryPath,sessionId;
@synthesize nearbyPeople, locationPeople, nearbyPosts, nearbySales, nearbyCoupons, nearbyPlaces;
@synthesize isProblemWithXMLRPC, username, nearbyPlacesSize, nearbyPeopleSize, locationsWithPromos, promotions; 
@synthesize nearbyPostsSize, nearbySalesSize, nearbyCouponsSize, locationPeopleSize, checkedin, checkedinLoc, promoLocSize, promoSize;
@synthesize isAuthenticatedMizUser, isFBAuthenticatedUser,isTwtAuthenticatedUser;

@synthesize	fetchedData, placesList,cafeList, restaurantList, nightLifeList, visitorList, shoppingList, lodgingList;
@synthesize placesLastFetch, peopleLastFetch, postsLastFetch, promosLastFetch, cafesLastFetch, restaurantsLastFetch, 
			nightLastFetch, shopsLastFetch, lodgeLastFetch;



- (void)dealloc {
	[nearbyPeople release];
	[locationPeople release];
	[nearbyPlaces release];
	[nearbySales release];
	[nearbyCoupons release];
	[nearbyPosts release];
	[locationsWithPromos release];
	[promotions release];
	
	
	[photosDB release];
    [asyncOperationsQueue release];
    [super dealloc];
	sharedDataManager = 0;

#ifdef FACTUAL
    [self clearFactualReferences];
#endif
}



// Initialize the singleton instance if needed and return
+ (MizDataManager *)sharedDataManager {
    {
        if (!sharedDataManager)
            sharedDataManager = [[MizDataManager alloc] init];
		
        return sharedDataManager;
    }
}

+ (id)alloc {
	//	@synchronized(self)
    {
        NSAssert(sharedDataManager == nil, @"Attempted to allocate a second instance of a singleton.");
        sharedDataManager = [super alloc];
        return sharedDataManager;
    }
}


+ (id)copy {
	//	@synchronized(self)
    {
        NSAssert(sharedDataManager == nil, @"Attempted to copy the singleton.");
        return sharedDataManager;
    }
}


- (id)init {
    if (self = [super init]) {
        asyncOperationsQueue = [[NSOperationQueue alloc] init];
        [asyncOperationsQueue setMaxConcurrentOperationCount:2];
		
		
		NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
		
		self.isAuthenticatedMizUser = [userData boolForKey:kIsAuthenticated];
		self.isFBAuthenticatedUser = [userData boolForKey:kIsFBAuthenticated];
		self.isTwtAuthenticatedUser =  [ userData boolForKey: kIsTwtAuthenticated];
		
		self.username = [userData stringForKey:kUsername];

		// let's create a mizooner user 
		if (self.isAuthenticatedMizUser ) {
			MizoonUser *user = [MizoonUser sharedMizooner];
			user.userId = self.username;
			user.points = [userData integerForKey:kUserPoints];
		}
		
		
        // Set current directory for Mizoon app
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.currentDirectoryPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"mizoon"];
		
        BOOL isDir;
		
        if (![fileManager fileExistsAtPath:self.currentDirectoryPath isDirectory:&isDir] || !isDir) {
            [fileManager createDirectoryAtPath:self.currentDirectoryPath withIntermediateDirectories: YES attributes:nil error:NULL];
        }
		
        // set the current dir
        [fileManager changeCurrentDirectoryPath:self.currentDirectoryPath];
		
		// allocate checkinLoc 
		checkedinLoc = malloc( sizeof(CheckinInfo) );
		checkedinLoc->lat = checkedinLoc->lon =checkedinLoc->lid = 0;
		checkedinLoc->name = NULL;
		
		geoapiManager_ = [[GAConnectionManager alloc] initWithAPIKey:GEO_API_KEY delegate:self];
        
#ifdef FACTUAL
        // initialize the factual api object ... 
        _factualObject = [[FactualAPI alloc] initWithAPIKey:@"4pafEWcQnjHEEODpmfvoSmh3fN9yHCbdGGTaqeZX" secret:@"wyLqNX1uYRxseG9gGbSqxKbgmEjhNqKnaleCqh3H"];
        _factualObjPrefs = [[NSMutableDictionary alloc] init];
        [self populateQueryDefaults];
#endif
		
		[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(failedToFetchData:) name:@"MZ_NO_Data" object:nil];

    }
	
    return self;
}


- (void) failedToFetchData:(NSNotification *)notification 
{
	[[Mizoon sharedMizoon] hideLoadMessage];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
													 message:@"Couldn't locate any location near you. Can you try again?"
													delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert	release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Restaurant_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Cafe_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_NL_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Shopping_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Lodging_Data" object:nil];	 

	[[[Mizoon sharedMizoon] getRootViewController] popView];
}


#pragma mark Actions


-(BOOL) authenticate: (NSString *) uid withPaswword: (NSString *) password {
	
	if (![[Mizoon sharedMizoon] hasNetworkConnection]) {
		return FALSE;
	}
	
	// logout the user
//	[self MizoonLogout:uid];

	if (!self.sessionId)
		[self fetchSessionId];

//	NSString *credentials = [[NSString stringWithFormat:@"%@:%@", uid, password] base64Encoding];
		
	NSMutableDictionary *methodArgs = [NSMutableDictionary dictionary];
	[methodArgs setObject: password forKey:@"password"];
	[methodArgs setObject: self.sessionId forKey:kSESSID];
//	[methodArgs setObject: @"adfadfad" forKey:kSESSID];


	[methodArgs setObject: uid forKey:@"username"];
	
    NSArray *args = [NSArray arrayWithObjects:methodArgs,nil];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:MIZOON_XMLRPC_SERVER forKey:kURL];
	[params setObject:@"mizoon.auth" forKey:kMETHOD];
    [params setObject:args forKey:kMETHODARGS];
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:[params valueForKey:kURL]]];
    [request setMethod:[params valueForKey:kMETHOD] withObjects: [params valueForKey:kMETHODARGS]];
	
	XMLRPCResponse *response = [self executeXMLRPCRequest:request byHandlingError:NO];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WS_authenticate_Completed" object:(id)self];

    id resObj = [response object];
	
//	[request release];
//	[response	release];
	
	if ([resObj isKindOfClass:[NSError class]]) 
        return FALSE;

	if (![resObj valueForKey:@"user"])
		return FALSE;
	
	self.isAuthenticatedMizUser = TRUE;
	self.username = [[NSString alloc] initWithString:uid];

	MizoonUser *user = [MizoonUser sharedMizooner];
	user.userId = self.username;
	
	[self saveMizPasswordToKeychain: password andUserName:uid];

	if (self.isAuthenticatedMizUser == TRUE) {
		MizoonLog(@"It is true - user is authenticated ");
	}
	
//	MizoonLog(@"Is authenticated =%@", self.isAuthenticatedMizUser);   This crashes the app!!
	NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
		
	[userData	setBool:TRUE forKey:kIsAuthenticated];
	[userData	setObject:uid forKey:kUsername];
	[userData	synchronize];
		
	return TRUE;
}



- (BOOL) mizoonRegister: (NSString *) uid withPassword: (NSString *) password andEmail:(NSString *)email zip: (NSString *) zip andPhone: (NSString *) phone 
{
	if (![[Mizoon sharedMizoon] hasNetworkConnection]) {
		return FALSE;
	}
	
	if (![self fetchSessionId]) 
		return FALSE;
	
	NSMutableDictionary *methodArgs = [NSMutableDictionary dictionary];
	[methodArgs setValue: uid forKey:kUSERNAME];
	[methodArgs setValue: password forKey:kPASSWORD];
	[methodArgs setValue: email forKey:kEMAIL];
	[methodArgs setValue: zip forKey:kZIP];
	[methodArgs setValue: phone	forKey:kPHONE];
	[methodArgs setValue: sessionId forKey:kSESSID];

    NSArray *args = [NSArray arrayWithObjects:methodArgs,nil];
//	MizoonLog(@"args=%@", args);
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:MIZOON_XMLRPC_SERVER forKey:kURL];
	[params setObject:@"mizoon.register" forKey:kMETHOD];
    [params setObject:args forKey:kMETHODARGS];
	
	
    XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:[params valueForKey:kURL]]];
    [request setMethod:[params valueForKey:kMETHOD] withObjects: [params valueForKey:kMETHODARGS]];
	
	XMLRPCResponse *response = [self executeXMLRPCRequest:request byHandlingError:YES];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WS_mizoonRegister_Completed" object:(id)self];

//	[request release];

	if (!response) 
		return FALSE;
	
    id resObj = [response object];
	if ([resObj isKindOfClass:[NSError class]]) 
        return FALSE;
	
	
	self.isAuthenticatedMizUser = TRUE;
	self.username = [[NSString alloc] initWithString:uid];
	
	[self saveMizPasswordToKeychain: password andUserName:uid];
		
	NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
	
	[userData	setBool:TRUE forKey:kIsAuthenticated];
	[userData	setObject:uid forKey:kUsername];
	[userData	synchronize];
	
    return TRUE;	
}



-(BOOL) NSLogout: (NSString *) uid 
{
	if (!self.sessionId)
		[self fetchSessionId];
	
	NSMutableDictionary *methodArgs = [NSMutableDictionary dictionary];
	[methodArgs setObject: self.sessionId forKey:kSESSID];

    NSArray *args = [NSArray arrayWithObjects:methodArgs,nil];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:MIZOON_XMLRPC_SERVER forKey:kURL];
	[params setObject:@"user.logout" forKey:kMETHOD];
    [params setObject:args forKey:kMETHODARGS];
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:[params valueForKey:kURL]]];
    [request setMethod:[params valueForKey:kMETHOD] withObjects: [params valueForKey:kMETHODARGS]];
	
	XMLRPCResponse *response = [self executeXMLRPCRequest:request byHandlingError:NO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WS_logout_Completed" object:(id)self];

    id resObj = [response object];
	
//	[request release];
//	[response	release];
	
	if ([resObj isKindOfClass:[NSError class]]) 
        return FALSE;
	
	MizoonLog(@"%@ is logged out", self.username);
	
		
	self.isAuthenticatedMizUser = FALSE;
	[self.username release];
	self.username = nil;
	
	[self deleteMizFromKeychain:uid];
	
	NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
	
	[userData	setBool:FALSE forKey:kIsAuthenticated];
	[userData	setObject:nil forKey:kUsername];
	[userData	synchronize];
	
	return TRUE;
}



- (NSArray *) uploadPost:  (NSString *) message withPhoto: (UIImage *) photo  postRadius: (int) radius numberToRet: (int) num_ret
{

//- (BOOL) uploadPost: (NSString *) message withPhoto: (UIImage *) photo {

	if ((!message || [message length] < 1) && !photo) 
		return FALSE;
	
	if (![self fetchSessionId]) 
		return FALSE;
	
	MizoonLocation	*theLocation = [[Mizoon sharedMizoon] getSelectedLocation];
	
	NSData *imageData = UIImageJPEGRepresentation(photo, 0.9);	
	NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
	NSString *user = [userData stringForKey:kUsername];
	
//	NSString *password = [self getMizPasswordFromKeychainWithUsername: user];
	NSString *password = [[Mizoon sharedMizoon] md5HexDigest:[self getMizPasswordFromKeychainWithUsername: user]];

	NSMutableDictionary *methodArgs = [NSMutableDictionary dictionary];
	[methodArgs setValue: sessionId forKey:kSESSID];
	[methodArgs setValue: user forKey:kUSERNAME];
	[methodArgs setValue: password forKey:kPASSWORD];
	
	if (theLocation) {
		[methodArgs setValue: theLocation.name forKey:kLOCATION_NAME];
		[methodArgs setValue: [NSString stringWithFormat:@"%d",  theLocation.lid] forKey:kLOCATION_ID];
		[methodArgs setValue: theLocation.address forKey:kLOCATION_ADDRESS];
		[methodArgs setValue: theLocation.city forKey:kLOCATION_CITY];
		[methodArgs setValue: theLocation.state forKey:kLOCATION_STATE];		
		[methodArgs setValue: theLocation.zip forKey:kZIP];
		
		(theLocation.phone) ? [methodArgs setValue: theLocation.phone forKey:kPHONE] : [methodArgs setValue:[NSNull null] forKey:kPHONE];
		(theLocation.website) ? [methodArgs setValue: theLocation.website forKey:kLOCATION_WEBSITE] : [methodArgs setValue:[NSNull null] forKey:kLOCATION_WEBSITE];
		(theLocation.category) ? [methodArgs setValue: theLocation.category forKey:kLOCATION_CATEGORY] : [methodArgs setValue:[NSNull null] forKey:kLOCATION_CATEGORY];
	} else {
		[methodArgs setValue:[NSNull null] forKey:kLOCATION_NAME];
		[methodArgs setValue:[NSNull null]  forKey:kLOCATION_ID];
		[methodArgs setValue:[NSNull null] forKey:kLOCATION_ADDRESS];
		[methodArgs setValue:[NSNull null]  forKey:kLOCATION_CITY];
		[methodArgs setValue:[NSNull null]  forKey:kLOCATION_STATE];		
		[methodArgs setValue:[NSNull null]  forKey:kZIP];
		[methodArgs setValue:[NSNull null] forKey:kPHONE];
		[methodArgs setValue:[NSNull null] forKey:kLOCATION_WEBSITE];
		[methodArgs setValue:[NSNull null] forKey:kLOCATION_CATEGORY];
	} 
		

	[methodArgs setValue: [NSString stringWithFormat:@"%d",  radius] forKey:kRADIUS];
	[methodArgs setValue: [NSString stringWithFormat:@"%d",  num_ret] forKey:kNUMBER_RETURN];

	[methodArgs setValue: [NSString stringWithFormat:@"%f",  currentLocation.coordinate.latitude] forKey:kLATITUDE];
	[methodArgs setValue: [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude] forKey:kLONGTITUDE];

//	[methodArgs setValue: [NSString stringWithFormat:@"%@", imageData] forKey:kPHOTO];
	if (photo) {
		[methodArgs setValue:imageData forKey:kPHOTO];
	} else {
		[methodArgs setValue:@" " forKey:kPHOTO];
	}
	
	if (message && [message length] >= 1) {
		[methodArgs setValue: message forKey:kPOST_MESSAGE];
	} else {
		[methodArgs setValue: @" " forKey:kPOST_MESSAGE];

	}


    NSArray *args = [NSArray arrayWithObjects:methodArgs,nil];
//	MizoonLog(@"args=%@", args);
	//	MizoonLog(@"args=%@", methodArgs);
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:MIZOON_XMLRPC_SERVER forKey:kURL];
	[params setObject:@"nearby.post" forKey:kMETHOD];
    [params setObject:args forKey:kMETHODARGS];
	
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:[params valueForKey:kURL]]];
    [request setMethod:[params valueForKey:kMETHOD] withObjects: [params valueForKey:kMETHODARGS]];
	
#if ASYNC_POST
	XMLRPCResponse *response = [self executeXMLRPCRequest:request byHandlingError:NO];
#else
	XMLRPCConnection *connection = [[XMLRPCConnection alloc] autorelease];
	
	[connection  initWithXMLRPCRequest:request delegate: connection];
	
	return nil;
#endif
	
	
#if ASYNC_POST
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WS_Post_Completed" object:(id)self];
	
	
    id resObj = [response object];
	
	if ([resObj isKindOfClass:[NSError class]]) 
        return FALSE;
		
	NSString *posts =[resObj valueForKey:@"posts"];
	if (!posts || ([posts length] < 1 )) 
		return nil;
	
	SBJSON *jsonParser = [SBJSON new];
	
	// Parse the JSON response into an Object
	NSDictionary *feed = (NSDictionary *)[jsonParser objectWithString:posts error:NULL];
	
	self.nearbyPostsSize = [[feed valueForKey:@"size"] intValue];
	if (self.nearbyPostsSize > MAX_NUM_POSTS_TO_DISPLAY) {
		self.nearbyPostsSize = MAX_NUM_POSTS_TO_DISPLAY;
	}
	
	// get the array of "stream" from the feed and cast to NSArray
	NSArray *streams = (NSArray *)[feed valueForKey:@"stream"];
	
	
	if (self.nearbyPosts)
		self.nearbyPosts = nil;
	
	self.nearbyPosts = streams;
	
	[jsonParser	release];
	
	return streams;
#endif
}




- (BOOL) sendFriendRequest:  (NSString *) uid {
		
	if (![self fetchSessionId]) 
		return FALSE;
	
	NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
	NSString *user = [userData stringForKey:kUsername];
	NSString *password = [self getMizPasswordFromKeychainWithUsername: user];
	
	NSString *encodedUserName = [user stringByUrlEncoding];
	NSString *encodedUserPassword = [password stringByUrlEncoding];
	NSString *encodedUid = [uid stringByUrlEncoding];
	NSString *encodedSessId = [sessionId stringByUrlEncoding];

	NSData *body = [[NSString stringWithFormat:@"user_name=%@&password=%@&uid=%@&session=%@", 
			 encodedUserName, encodedUserPassword, encodedUid, encodedSessId] dataUsingEncoding:NSUTF8StringEncoding];
	
	NSString * postUrl = [NSString stringWithFormat:@"%@/?q=api/be_friends", MIZOON_SERVER];
	[self mizAyncPost: postUrl postBody: (NSData *) body];
	
	[encodedUid release];
	[encodedUserPassword release];
	[encodedUserName	release];
	[encodedSessId	release];
	
    return TRUE;	
}




- (BOOL) sendMessage: (NSString *) message  recipient: (NSString *) uid {
	
	if ( !message || [message length] < 1 ) 
		return FALSE;
	
	if (![self fetchSessionId]) 
		return FALSE;
	
	NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
	NSString *user = [userData stringForKey:kUsername];
	NSString *password = [self getMizPasswordFromKeychainWithUsername: user];
	
#if 0
	NSMutableDictionary *methodArgs = [NSMutableDictionary dictionary];
	[methodArgs setValue: sessionId forKey:kSESSID];
	[methodArgs setValue: user forKey:kUSERNAME];
	[methodArgs setValue: password forKey:kPASSWORD];
	[methodArgs setValue: uid forKey:kRECIPIENT_ID];
	

	[methodArgs setValue: message forKey:kPOST_MESSAGE];
	
    NSArray *args = [NSArray arrayWithObjects:methodArgs,nil];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:MIZOON_XMLRPC_SERVER forKey:kURL];
	[params setObject:@"mizoon.message" forKey:kMETHOD];
    [params setObject:args forKey:kMETHODARGS];
	
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:[params valueForKey:kURL]]];
    [request setMethod:[params valueForKey:kMETHOD] withObjects: [params valueForKey:kMETHODARGS]];
	
	XMLRPCResponse *response = [self executeXMLRPCRequest:request byHandlingError:NO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WS_Send_Message_Completed" object:(id)self];
	
	
    id resObj = [response object];
	
	if ([resObj isKindOfClass:[NSError class]]) 
        return FALSE;

#else
	 NSString *encodedUserName = [user stringByUrlEncoding];
	 NSString *encodedUserPassword = [password stringByUrlEncoding];
	 NSString *encodedUid = [uid stringByUrlEncoding];
	 NSString *encodedSessId = [sessionId stringByUrlEncoding];
	 NSString *encodedMsg = [message stringByUrlEncoding];
	 
	 NSData *body = [[NSString stringWithFormat:@"user_name=%@&password=%@&recipient=%@&session=%@&message=%@", 
					  encodedUserName, encodedUserPassword, encodedUid, encodedSessId, encodedMsg] dataUsingEncoding:NSUTF8StringEncoding];
	 
	 NSString * postUrl = [NSString stringWithFormat:@"%@/?q=api/priv_msg", MIZOON_SERVER];
	 [self mizAyncPost: postUrl postBody: (NSData *) body];
	 
	 [encodedUid release];
	 [encodedUserPassword release];
	 [encodedUserName	release];
	 [encodedSessId	release];
	 [encodedMsg	release];
#endif	 
	 
    return TRUE;	
}



- (BOOL)  redeemCoupon:(NSString *) prid fromLocation: (NSString *) lid {
	Mizoon	*miz = [Mizoon sharedMizoon];
	
	if (![self fetchSessionId]) 
		return FALSE;
	
	NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
	NSString *user = [userData stringForKey:kUsername];
	NSString *password = [self getMizPasswordFromKeychainWithUsername: user];
	
	NSMutableDictionary *methodArgs = [NSMutableDictionary dictionary];
	[methodArgs setValue: sessionId forKey:kSESSID];
	[methodArgs setValue: user forKey:kUSERNAME];
	[methodArgs setValue: password forKey:kPASSWORD];
	[methodArgs setValue: lid forKey:kLOCATION_ID];
	[methodArgs setValue: prid forKey:kPROMOTION_ID];

	
    NSArray *args = [NSArray arrayWithObjects:methodArgs,nil];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:MIZOON_XMLRPC_SERVER forKey:kURL];
	[params setObject:@"mizoon.redeem" forKey:kMETHOD];
    [params setObject:args forKey:kMETHODARGS];
	
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:[params valueForKey:kURL]]];
    [request setMethod:[params valueForKey:kMETHOD] withObjects: [params valueForKey:kMETHODARGS]];
	
	XMLRPCResponse *response = [self executeXMLRPCRequest:request byHandlingError:NO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WS_Redeem_Completed" object:(id)self];
	
	
    id resObj = [response object];
	//	[request release];
	
	if ([resObj isKindOfClass:[NSError class]]) 
        return FALSE;
	
	miz.redeemedCP = prid;
	
    return TRUE;		
}




- (BOOL) checkin: (NSDictionary *) location {
	
	
	if (![self fetchSessionId]) 
		return FALSE;
	
	NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
	NSString *user = [userData stringForKey:kUsername];
	NSString *password = [self getMizPasswordFromKeychainWithUsername: user];
	
	NSMutableDictionary *methodArgs = [NSMutableDictionary dictionary];
	[methodArgs setValue: sessionId forKey:kSESSID];
	[methodArgs setValue: user forKey:kUSERNAME];
	[methodArgs setValue: password forKey:kPASSWORD];
	[methodArgs setValue: [location valueForKey:@"name"] forKey:kLOCATION_NAME];
	[methodArgs setValue: [location valueForKey:@"address"] forKey:kLOCATION_ADDRESS];
	[methodArgs setValue: [location valueForKey:@"city"] forKey:kLOCATION_CITY];
	[methodArgs setValue: [location valueForKey:@"state"] forKey:kLOCATION_STATE];
	[methodArgs setValue: [location valueForKey:@"zip"] forKey:kZIP];
	[methodArgs setValue: [location valueForKey:@"phone"] forKey:kPHONE];
	[methodArgs setValue: [location valueForKey:@"website"] forKey:kLOCATION_WEBSITE];
	[methodArgs setValue: [location valueForKey:@"lat"] forKey:kLATITUDE];
	[methodArgs setValue: [location valueForKey:@"lon"] forKey:kLONGTITUDE];
	[methodArgs setValue: [location valueForKey:@"type"] forKey:kLOCATION_CATEGORY];
	[methodArgs setValue: [location valueForKey:@"nid"] forKey:kLOCATION_ID];
	
	
    NSArray *args = [NSArray arrayWithObjects:methodArgs,nil];
	//	MizoonLog(@"args=%@", args);
	//	MizoonLog(@"args=%@", methodArgs);
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:MIZOON_XMLRPC_SERVER forKey:kURL];
	[params setObject:@"mizoon.checkin" forKey:kMETHOD];
    [params setObject:args forKey:kMETHODARGS];
	
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:[params valueForKey:kURL]]];
    [request setMethod:[params valueForKey:kMETHOD] withObjects: [params valueForKey:kMETHODARGS]];
	
	XMLRPCResponse *response = [self executeXMLRPCRequest:request byHandlingError:NO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WS_Post_Completed" object:(id)self];
	
	
    id resObj = [response object];
//	[request release];

	if ([resObj isKindOfClass:[NSError class]]) 
        return FALSE;
		
	
	self.checkedin = TRUE;
	CheckinInfo *cInfo = self.checkedinLoc;
	cInfo->lat= [[location valueForKey:@"lat"] floatValue];
	cInfo->lon= [[location valueForKey:@"lon"] floatValue];
	cInfo->name= [location valueForKey:@"name"];
	cInfo->lid= [[location valueForKey:@"nid"] intValue];
//	MizoonLog(@"----------------------website=%@", (NSString *) [location valueForKey:@"website"]);


	self.locationPeopleSize = 0;
	if (self.locationPeople) 
		self.locationPeople = NULL;

	NSString *visitors =[resObj valueForKey:@"visitors"];
	if (!visitors || ([visitors length] < 1 )) 
		return TRUE;

	SBJSON *jsonParser = [SBJSON new];
	NSDictionary *feed = (NSDictionary *)[jsonParser objectWithString:visitors error:NULL];
	
//	MizoonLog(@"----------------------Number of visitors=%@", (NSString *) [feed valueForKey:@"size"]);

	
	// release the old dictionary
	if (self.locationPeopleSize) 
		[locationPeople release];
	
	
	self.locationPeopleSize = [[feed valueForKey:@"size"] intValue];
	
	// get the array of "stream" from the feed and cast to NSArray
	self.locationPeople = (NSArray *)[feed valueForKey:@"stream"];

	[jsonParser release];
	
    return TRUE;	
}


- (BOOL) checkinLocaton: (MizoonLocation *) mizLocation withMessage: checkinMsg {
	
	
	if (![self fetchSessionId]) 
		return FALSE;
	
	NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
	NSString *user = [userData stringForKey:kUsername];
	NSString *password = [self getMizPasswordFromKeychainWithUsername: user];
	
	NSMutableDictionary *methodArgs = [NSMutableDictionary dictionary];
	[methodArgs setValue: sessionId forKey:kSESSID];
	[methodArgs setValue: user forKey:kUSERNAME];
	[methodArgs setValue: password forKey:kPASSWORD];
	
	[methodArgs setValue: checkinMsg forKey:kCHECKIN_MESSAGE];

	[methodArgs setValue: mizLocation.name forKey:kLOCATION_NAME];
	[methodArgs setValue: mizLocation.address forKey:kLOCATION_ADDRESS];
	[methodArgs setValue: mizLocation.city forKey:kLOCATION_CITY];
	[methodArgs setValue: mizLocation.state forKey:kLOCATION_STATE];
	[methodArgs setValue: mizLocation.zip forKey:kZIP];
	[methodArgs setValue: mizLocation.phone forKey:kPHONE];
	[methodArgs setValue: mizLocation.website forKey:kLOCATION_WEBSITE];
	[methodArgs setValue: mizLocation.category forKey:kLOCATION_CATEGORY];
	
	NSString *lat = [[NSString alloc] initWithFormat:@"%f", mizLocation.latitude ];
	NSString *lon = [[NSString alloc] initWithFormat:@"%f", mizLocation.longitude ];
	NSString *lid = [[NSString alloc] initWithFormat:@"%d", mizLocation.lid ];
	
	[methodArgs setValue: lat  forKey:kLATITUDE];
	[methodArgs setValue: lon forKey:kLONGTITUDE];
	[methodArgs setValue: lid forKey:kLOCATION_ID];
	
	[lat release];
	[lon release];
	[lid release];
	
    NSArray *args = [NSArray arrayWithObjects:methodArgs,nil];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:MIZOON_XMLRPC_SERVER forKey:kURL];
	[params setObject:@"mizoon.checkin" forKey:kMETHOD];
    [params setObject:args forKey:kMETHODARGS];
	
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:[params valueForKey:kURL]]];
    [request setMethod:[params valueForKey:kMETHOD] withObjects: [params valueForKey:kMETHODARGS]];
	XMLRPCResponse *response = [self executeXMLRPCRequest:request byHandlingError:NO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WS_Checkin_Completed" object:(id)self];
	
	
    id resObj = [response object];
	[request release];  // XXXX
	
	if ([resObj isKindOfClass:[NSError class]]) 
        return FALSE;
	
	
	self.checkedin = TRUE;
	CheckinInfo *cInfo = self.checkedinLoc;
	cInfo->lat= mizLocation.latitude;
	cInfo->lon= mizLocation.longitude;
	cInfo->name= mizLocation.name;
	cInfo->lid= mizLocation.lid;	
	
	self.locationPeopleSize = 0;
	if (self.locationPeople) 
		self.locationPeople = NULL;
	
	[[Mizoon sharedMizoon] setMizoonerPoints: [[resObj valueForKey:@"points"] intValue]];

	
	NSString *visitors =[resObj valueForKey:@"visitors"];
	if (!visitors || ([visitors length] < 1 )) 
		return TRUE;
	
	SBJSON *jsonParser = [SBJSON new];
	NSDictionary *feed = (NSDictionary *)[jsonParser objectWithString:visitors error:NULL];
	
	// release the old dictionary
	if (self.locationPeopleSize) 
		[locationPeople release];
	
	self.locationPeopleSize = [[feed valueForKey:@"size"] intValue];
	
	// get the array of "stream" from the feed and cast to NSArray
	self.locationPeople = (NSArray *)[feed valueForKey:@"stream"];
	
	[jsonParser release];

    return TRUE;	
}



- (BOOL) checkinMizoonLoc: (MizoonLocation *) mizLocation {
	
	Mizoon *miz = [Mizoon sharedMizoon];
	
	if (![self fetchSessionId]) 
		return FALSE;
	
	NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
	NSString *user = [userData stringForKey:kUsername];
	NSString *password = [self getMizPasswordFromKeychainWithUsername: user];
	
	NSMutableDictionary *methodArgs = [NSMutableDictionary dictionary];
	[methodArgs setValue: sessionId forKey:kSESSID];
	[methodArgs setValue: user forKey:kUSERNAME];
	[methodArgs setValue: password forKey:kPASSWORD];
	
	[methodArgs setValue: @" " forKey:kCHECKIN_MESSAGE];

	[methodArgs setValue: mizLocation.name forKey:kLOCATION_NAME];
	[methodArgs setValue: mizLocation.address forKey:kLOCATION_ADDRESS];
	[methodArgs setValue: mizLocation.city forKey:kLOCATION_CITY];
	
	if (!mizLocation.state || ([mizLocation.state length] == 0)) {
		[methodArgs setValue: @" " forKey:kLOCATION_STATE];
		
	} else {
		[methodArgs setValue: mizLocation.state forKey:kLOCATION_STATE];
	}
	
	[methodArgs setValue: mizLocation.zip forKey:kZIP];
	[methodArgs setValue: mizLocation.phone forKey:kPHONE];

	if (!mizLocation.website|| ([mizLocation.website length] == 0)) {
		[methodArgs setValue: @" " forKey:kLOCATION_WEBSITE];

	} else {
		[methodArgs setValue: mizLocation.website forKey:kLOCATION_WEBSITE];
	}

	[methodArgs setValue: mizLocation.category forKey:kLOCATION_CATEGORY];

	NSString *lat = [NSString stringWithFormat:@"%f", mizLocation.latitude ];
	NSString *lon = [NSString stringWithFormat:@"%f", mizLocation.longitude ];
	NSString *lid = [NSString stringWithFormat:@"%d", mizLocation.lid ];

	[methodArgs setValue: lat  forKey:kLATITUDE];
	[methodArgs setValue: lon forKey:kLONGTITUDE];
	[methodArgs setValue: lid forKey:kLOCATION_ID];
	
//	[lat release];
//	[lon release];
//	[lid release];
	
    NSArray *args = [NSArray arrayWithObjects:methodArgs,nil];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:MIZOON_XMLRPC_SERVER forKey:kURL];
	[params setObject:@"mizoon.checkin" forKey:kMETHOD];
    [params setObject:args forKey:kMETHODARGS];
	
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:[params valueForKey:kURL]]];
    [request setMethod:[params valueForKey:kMETHOD] withObjects: [params valueForKey:kMETHODARGS]];
	
	XMLRPCResponse *response = [self executeXMLRPCRequest:request byHandlingError:NO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WS_Checkin_Completed" object:(id)self];
	
	
    id resObj = [response object];
//	MizoonLog(@"(1)--------------------------ref count=%d", [request retainCount]);
//	[request release];
//	MizoonLog(@"(2)--------------------------ref count=%d", [request retainCount]);

	[methodArgs release];
	
	if ([resObj isKindOfClass:[NSError class]]) 
        return FALSE;
	
	
	self.checkedin = TRUE;
	CheckinInfo *cInfo = self.checkedinLoc;
	cInfo->lat= mizLocation.latitude;
	cInfo->lon= mizLocation.longitude;
	cInfo->name= mizLocation.name;
	cInfo->lid= mizLocation.lid;
//	MizoonLog(@"----------------------website=%@", (NSString *) mizLocation.website);
	
	
	self.locationPeopleSize = 0;
	if (self.locationPeople) 
		self.locationPeople = NULL;
	
	[miz setMizoonerPoints: [[resObj valueForKey:@"points"] intValue]];
	 
	NSString *visitors =[resObj valueForKey:@"visitors"];
	if (!visitors || ([visitors length] < 1 )) 
		return TRUE;
	
	SBJSON *jsonParser = [SBJSON new];
	NSDictionary *feed = (NSDictionary *)[jsonParser objectWithString:visitors error:NULL];
	
//	MizoonLog(@"----------------------Number of visitors=%@", (NSString *) [feed valueForKey:@"size"]);
	
	
	// release the old dictionary
	if (self.locationPeopleSize) 
		[locationPeople release];
	
	
	self.locationPeopleSize = [[feed valueForKey:@"size"] intValue];
	
	// get the array of "stream" from the feed and cast to NSArray
	self.locationPeople = (NSArray *)[feed valueForKey:@"stream"];
	
	[jsonParser release];
	
//	[request release];  // XXXX

    return TRUE;	
}


#pragma mark Retrieve data 





- (NSArray *) fetchNearbyPosts: (int) radius atIndex: (int) index numberToRet:(int)num_ret {
	
	NSString * postURL = [NSString stringWithFormat: @"%@/?q=api/posts/&lat=%f&lon=%f&index=%i&ret=%i&radius=%i", MIZOON_RESTFUL_SERVER,  
						  currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, index, num_ret, radius];
	
#ifdef MIZOON_DEBUG
	[Mizoon sharedMizoon].methodStart  = [NSDate date];
#endif
	
	
	NSString * response = [self executeRESTfulRequest:[NSURL URLWithString:postURL]];
	
	
	
#ifdef MIZOON_DEBUG
	NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:[Mizoon sharedMizoon].methodStart];
	DebugLog(@"--> Fetch Post execution time=%f", executionTime);
#endif
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WS_nearbyPosts_Completed" object:(id)self];
		
	if (response == nil) 
		return nil;
	
	SBJSON *jsonParser = [SBJSON new];
	
	// Parse the JSON response into an Object
	NSDictionary *feed = (NSDictionary *)[jsonParser objectWithString:response error:NULL];
	
//	MizoonLog(@"----------------------total nearby posts size=%@", (NSString *) [feed valueForKey:@"size"]);
	
	
	self.nearbyPostsSize = [[feed valueForKey:@"size"] intValue];
	if (self.nearbyPostsSize > MAX_NUM_POSTS_TO_DISPLAY) {
		self.nearbyPostsSize = MAX_NUM_POSTS_TO_DISPLAY;
	}
	
	// get the array of "stream" from the feed and cast to NSArray
	NSArray *streams = (NSArray *)[feed valueForKey:@"stream"];
	
	
	if (self.nearbyPosts && index)
		self.nearbyPosts = [self.nearbyPosts arrayByAddingObjectsFromArray:streams];
	else 	
		self.nearbyPosts = streams;
	
	[jsonParser	release];
	self.postsLastFetch = [NSDate date];

	return streams;
}


- (NSArray *) XfetchNearbyPlaces: (int) radius atIndex: (int) index numberToRet:(int)num_ret {
#if 0	
	//	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	//	RootViewController *rvc = delegate.rootViewController;
	
//	NSString * placesURL = [NSString stringWithFormat: @"%@/?q=api/places/&lat=%f&lon=%f&index=%i&ret=%i&radius=%i", MIZOON_RESTFUL_SERVER,  
//							currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, index, num_ret, radius];
	
//	NSString *placesURL = @"http://api.geoapi.com/v1/search?lat=37.405023&lon=-122.12693&radius=.05km&apikey=demo&pretty=1";

	
	// " = %22 --- {=%7B  ---- [=%5B --- :=%3A --- }=%7D --- ]=%5D
	NSString *placesURL = @"http://api.geoapi.com/v1/q?q=%7B%22lat%22%3A+37.405023,+%22lon%22%3A+-122.12693,+%22radius%22%3A+%221km%22,+%22entity%22%3A+%5B%7B%22type%22%3A+%22business%22,+%22guid%22%3A+null,+%22view.listing%22%3A%20+%7B%22a:verticals%22%3A+%20[]+%22b:verticals%22%3A+%20[]+%22address%22%3A%20[]+%22phone%22%3A%20[]+%22website%22%3A%20[]+%22review%22%3A%20[]+%22category%22%3A%20[]+%22name%22%3A%20null%7D%7D%5D%7D&apikey=demo&pretty=1";
//http://api.geoapi.com/v1/q?q={%22lat%22:+37.405023,+%22lon%22:+-122.12693,+%22radius%22:+%221km%22,+%22limit%22:+%2230%22,+%22entity%22:+[{%22type%22:+%22business%22,+%22guid%22:+null,+%22distance-from-origin%22:+null,+%22view.listing%22:%20+{%22a:verticals%22:+%20[]+%22b:verticals%22:+%20[]+%22address%22:%20[]+%22phone%22:%20[]+%22website%22:%20[]+%22review%22:%20[]+%22category%22:%20[]+%22name%22:%20null}}]}&apikey=demo&pretty=1
	NSString * response = [self executeRESTfulRequest:[NSURL URLWithString:placesURL]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WS_nearbyPlaces_Completed" object:(id)self];
	
	if (response == nil) 
		return nil;
	
	SBJSON *jsonParser = [SBJSON new];
	
	// Parse the JSON response into an Object
	NSDictionary *feed = (NSDictionary *)[jsonParser objectWithString:response error:NULL];
	
	
	// get the array of "stream" from the feed and cast to NSArray
//	NSArray *streams = (NSArray *)[feed valueForKey:@"stream"];
	NSArray *streams = (NSArray *)[feed valueForKey:@"entity"];

	self.nearbyPlacesSize = [streams count];
//	MizoonLog(@"----------------------total nearby places size=%d", self.nearbyPlacesSize);

	NSDictionary *location = [streams objectAtIndex:0];
	

	MizoonLog(@"--------guid=%@", (NSString *) [location valueForKey:@"guid"]);

	MizoonLog(@"--------name=%@", (NSString *) [[location valueForKey:@"view.listing"] valueForKey:@"name"]);
	MizoonLog(@"--------type=%@", (NSString *) [location  valueForKey:@"type"]);
	MizoonLog(@"--------type=%@", (NSString *) [[location valueForKey:@"meta"] valueForKey:@"geom"]);

	MizoonLog(@"--------type=%@", (NSString *) [[[location valueForKey:@"meta"] valueForKey:@"geom"] valueForKey:@"coordinates"]);
	MizoonLog(@"--------lon=%@", (NSString *) [[[[location valueForKey:@"meta"] valueForKey:@"geom"] valueForKey:@"coordinates"] objectAtIndex:0]);
	MizoonLog(@"--------lat=%@", (NSString *) [[[[location valueForKey:@"meta"] valueForKey:@"geom"] valueForKey:@"coordinates"] objectAtIndex:1]);


	MizoonLog(@"----------------------total nearby places size=%@", (NSString *) [feed valueForKey:@"size"]);

	
	if (self.nearbyPlaces !=nil) 
		[self.nearbyPlaces release];
	
	self.nearbyPlaces = streams;
	
	//	[jsonParser release];
	//	[streams release];
	//	[feed release];
	//	[placesURL release];
	
	return streams;
#endif
	return NULL;
}



- (void) placesSearch: (NSString *) searchText
{	
#ifdef MIZOON_DEBUG
	[Mizoon sharedMizoon].methodStart  = [NSDate date];
#endif

//	[geoapiManager_ executeQuery:[self contructSQuery:searchText]];
    [[MizDataManager sharedDataManager] doFactualSearch:searchText];

	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(haveSearchData:) name:@"MZ_Have_Data" object:nil];
}




- (void) placeRegExpSearch: (NSString *) searchText
{		
#ifdef MIZOON_DEBUG
	[Mizoon sharedMizoon].methodStart  = [NSDate date];
#endif
	
	// This is a 2 request process - first get the guid of the parent and then do a keyword search
	[geoapiManager_ requestParentsForCoords:self.currentLocation.coordinate];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(haveRegExpSearchData:) name:@"MZ_Have_Data" object:nil];
	
	if (searchTerm) {
		[searchTerm release];
	}

	searchTerm = [[NSString alloc] initWithString: searchText];
}


- (void) haveRegExpSearchData:(NSNotification *)notification 
{	
	if (!self.fetchedData) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Data" object:nil];	 
		return;
	}
	
#ifdef MIZOON_DEBUG
	NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:[Mizoon sharedMizoon].methodStart];
	DebugLog(@"--------------------Search execution time=%f", executionTime);
#endif
	
	NSString *guid=nil;
	
	for (id obj in self.fetchedData) {
		
		NSDictionary *meta = [obj objectForKey:@"meta"];
		NSLog(@"guid: %@", [obj objectForKey:@"guid"]);
		NSLog(@"type: %@", [meta objectForKey:@"type"]);
		NSLog(@"nam: %@", [meta objectForKey:@"name"]);

		if ([[meta objectForKey:@"type"] isEqualToString:@"city"]) {
			guid = [obj objectForKey:@"guid"];
			break;
		}
	}
	

	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Data" object:nil];	 

//	[self requestEntitySearch: guid searchFor: searchTerm];
}



- (void)requestEntitySearch:(NSString *) guid searchFor: (NSString *) searchStr
{
	NSString *const kGAKeywordFormat = @"http://api.geoapi.com/v1/e/%@/keyword-search?apikey=%@&pretty=1&q=%@";

	NSString *url = [NSString stringWithFormat:kGAKeywordFormat, guid, GEO_API_KEY,searchStr];
	[geoapiManager_ requestURL:url];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Search_Data" object:(id)self];
}


- (void) haveSearchData:(NSNotification *)notification 
{
	//	MizDataManager *md = [MizDataManager sharedDataManager];
	
	if (!self.fetchedData) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Data" object:nil];	 
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_NO_Data" object:(id)self];
		return;
	}
	
#ifdef MIZOON_DEBUG
	NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:[Mizoon sharedMizoon].methodStart];
	DebugLog(@"--------------------Search execution time=%f", executionTime);
#endif
	
	if (self.placesList) {		
		self.placesList = nil;
	}
	NSMutableArray *places = [[NSMutableArray alloc] init];
	self.placesList = places;
	[places	release];
	
	for (id obj in self.fetchedData) {
		[self.placesList addObject:[MizoonLocation initWithLocation:obj]];
	}	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Search_Data" object:(id)self];
}



- (void) fetchNearbyRestaurants: (id) delegate
{	
#ifdef MIZOON_DEBUG
	[Mizoon sharedMizoon].methodStart  = [NSDate date];
#endif
	
    [[MizDataManager sharedDataManager] doFactualRestaurantQuery];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(haveRestaurantData:) name:@"MZ_Have_Data" object:nil];
}


- (void) haveRestaurantData:(NSNotification *)notification 
{
//	MizDataManager *md = [MizDataManager sharedDataManager];
	
	if (!self.fetchedData) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_NO_Data" object:(id)self];
		return;
	}

#ifdef MIZOON_DEBUG
	NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:[Mizoon sharedMizoon].methodStart];
	DebugLog(@"--> Fetch Restaurant execution time=%f", executionTime);
#endif
	if (self.restaurantList) {		
		self.restaurantList = nil;
	}
	NSMutableArray *cafes = [[NSMutableArray alloc] init];
	self.restaurantList = cafes;
	[cafes	release];
	
	for (id obj in self.fetchedData) {
		[self.restaurantList addObject:[MizoonLocation initWithLocation:obj]];
	}	
	self.restaurantsLastFetch = [NSDate date];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Restaurant_Data" object:(id)self];
}



- (void) fetchNearbyNightLife: (id) delegate
{	
	
    [[MizDataManager sharedDataManager] doFactualNLQuery];

	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(haveNLData:) name:@"MZ_Have_Data" object:nil];
}


- (void) haveNLData:(NSNotification *)notification 
{
	//	Mizoon *miz = [Mizoon sharedMizoon];
	
	if (!self.fetchedData) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_NO_Data" object:(id)self];
		return;
	}
	
	if (self.nightLifeList) {
		self.nightLifeList = nil;
	}
	NSMutableArray *places = [[NSMutableArray alloc] init];
	self.nightLifeList = places;
	[places	release];
	
	for (id obj in self.fetchedData) {
		[self.nightLifeList addObject:[MizoonLocation initWithLocation:obj]];
	}	
	self.nightLastFetch = [NSDate date];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_NL_Data" object:(id)self];
}




- (void) fetchNearbyShopping: (id) delegate
{	
	
    [[MizDataManager sharedDataManager] doFactualShoppingQuery];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(haveShoppingData:) name:@"MZ_Have_Data" object:nil];
}


- (void) haveShoppingData:(NSNotification *)notification 
{
	
	if (!self.fetchedData) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_NO_Data" object:(id)self];
		return;
	}
	
	if (self.shoppingList) {
		self.shoppingList = nil;
	}
	NSMutableArray *shopping = [[NSMutableArray alloc] init];
	self.shoppingList = shopping;
	[shopping	release];
	
	for (id obj in self.fetchedData) {
		[self.shoppingList addObject:[MizoonLocation initWithLocation:obj]];
	}	
	self.shopsLastFetch = [NSDate date];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Shopping_Data" object:(id)self];
}



- (void) fetchNearbyLodging: (id) delegate
{	
    [[MizDataManager sharedDataManager] doFactualTravelQuery];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(haveLodgingData:) name:@"MZ_Have_Data" object:nil];
}

- (void) haveLodgingData:(NSNotification *)notification 
{
	if (!self.fetchedData) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_NO_Data" object:(id)self];
		return;
	}
	
	if (self.lodgingList) {
		self.lodgingList = nil;
	}
	NSMutableArray *lodging = [[NSMutableArray alloc] init];
	self.lodgingList = lodging;
	[lodging	release];
	
	for (id obj in self.fetchedData) {
		[self.lodgingList addObject:[MizoonLocation initWithLocation:obj]];
	}	
	self.lodgeLastFetch = [NSDate date];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Lodging_Data" object:(id)self];
}



- (void) fetchNearbyCafe: (id) delegate
{	
#ifdef MIZOON_DEBUG
	[Mizoon sharedMizoon].methodStart  = [NSDate date];
#endif
	
	/*********************TEST TWITTER******************
	[[Mizoon sharedMizoon] testTwitter];
	*******************END TEST TWITTER******************/
    
    
    [[MizDataManager sharedDataManager] doFactualCafeQuery];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(haveCafeData:) name:@"MZ_Have_Data" object:nil];
}


- (void) haveCafeData:(NSNotification *)notification 
{
//	Mizoon *miz = [Mizoon sharedMizoon];

	if (!self.fetchedData) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_NO_Data" object:(id)self];
		return;
	}
	
#ifdef MIZOON_DEBUG
	NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:[Mizoon sharedMizoon].methodStart];
	DebugLog(@"--> Fetch Cafe execution time=%f", executionTime);
#endif
	if (self.cafeList) {
		MizoonLog(@"(1) haveCafeData - recount=%d", [self.cafeList retainCount]);

//		[miz.cafeList release];
		self.cafeList = nil;
		
		MizoonLog(@"(2) haveCafeData - recount=%d", [self.cafeList retainCount]);

	}
	NSMutableArray *cafes = [[NSMutableArray alloc] init];
	self.cafeList = cafes;
	[cafes	release];
	
	for (id obj in self.fetchedData) {
		[self.cafeList addObject:[MizoonLocation initWithLocation:obj]];
	}	
	self.cafesLastFetch = [NSDate date];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Cafe_Data" object:(id)self];
}




- (void) fetchNearbyPlaces: (id) delegate
{	
  /*  
//    [self doFactualQuery];
#ifdef MIZOON_DEBUG
	[Mizoon sharedMizoon].methodStart  = [NSDate date];
#endif
	
#ifdef SGEO
	Mizoon  *miz = [Mizoon sharedMizoon];
	
	NSMutableDictionary* requestParam = [NSMutableDictionary dictionary];
	NSString *requestStr = [NSString stringWithFormat:@"/1.0/places/%f,%f.json", [miz getUserlat], [miz getUserlon]];
	[requestParam setValue:@"50" forKey:@"num"];
	[requestParam setValue:globalRadius forKey:@"radius"];

	if ( ![self simpleGeoSendrequest: requestStr withRequestParam: (NSMutableDictionary *) requestParam] )
		return;

	[self havePlacesData:(NSNotification *) nil];
	
//	if (self.placesList) {
//		self.placesList = nil;	
//	}
//	NSMutableArray *places = [[NSMutableArray alloc] init];
//	self.placesList = places;
//	[places	release];
//	
//	for (id obj in self.fetchedData) {
//		[self.placesList addObject:[MizoonLocation initWithLocation:obj]];
//	}	
//	self.placesLastFetch = [NSDate date];
//	
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Data" object:(id)self];
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Places_Data" object:(id)self];
//	

#else
	[geoapiManager_ executeQuery:[self queryPlaces:nil]];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(havePlacesData:) name:@"MZ_Have_Data" object:nil];
#endif
 */   
    [[MizDataManager sharedDataManager] doFactualQuery];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(havePlacesData:) name:@"MZ_Have_Data" object:nil];    
}


- (void) havePlacesData:(NSNotification *)notification 
{	
	if (!self.fetchedData) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_NO_Data" object:(id)self];
		return;
	}
#ifdef MIZOON_DEBUG
	NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:[Mizoon sharedMizoon].methodStart];
	DebugLog(@"--> Fetch Places execution time=%f", executionTime);
#endif
	
	if (self.placesList) {
		self.placesList = nil;	
	}
	NSMutableArray *places = [[NSMutableArray alloc] init];
	self.placesList = places;
	[places	release];
	
	for (id obj in self.fetchedData) {
		[self.placesList addObject:[MizoonLocation initWithLocation:obj]];
	}	
	self.placesLastFetch = [NSDate date];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Places_Data" object:(id)self];
}




- (BOOL) fetchVisitors: (MizoonLocation *) theLocation  
{
			
//	?q=api/visitors/&lat=37.441845&lon=-122.165404&name=coupa%20cafe&address=538%20Ramona%20Street&city=palo%20alto&state=ca&zip=94301&lid=0	

	NSString *uname = [[Mizoon sharedMizoon] getUserName];
	NSString *appKey = [[Mizoon sharedMizoon] getApplicationKey];
	
	NSString * placesURL = [NSString stringWithFormat: @"%@/?q=api/visitors/&uid=%@&app_key=%@&lat=%f&lon=%f&name=%@&address=%@&city=%@&state=%@&zip=%@&lid=%d", 
							MIZOON_RESTFUL_SERVER, uname, appKey, theLocation.latitude, theLocation.longitude, theLocation.name, 
							theLocation.address, theLocation.city, theLocation.state, theLocation.zip, theLocation.lid ];
	
	NSString *encodedUrlString = [placesURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString * response = [self executeRESTfulRequest:[NSURL URLWithString:encodedUrlString]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WS_nearbyPlaces_Completed" object:(id)self];
	
	if (response == nil || [response length] < 1) 
		return FALSE;
	
//	id resObj = [response object];
//	
//	if ([resObj isKindOfClass:[NSError class]]) 
//        return FALSE;
//	
//	NSString *visitors =[resObj valueForKey:@"visitors"];
//	if (!visitors || ([visitors length] < 1 )) 
//		return FALSE;
//	
//	SBJSON *jsonParser = [SBJSON new];
//	NSDictionary *feed = (NSDictionary *)[jsonParser objectWithString:visitors error:NULL];
	
	
	SBJSON *jsonParser = [SBJSON new];
	NSDictionary *feed = (NSDictionary *)[jsonParser objectWithString:response error:NULL];
	if (!feed) 
		return FALSE;
	
	if (self.visitorList) {
		[visitorList release];
		visitorList = nil;
	}
	NSMutableArray *vArray = [[NSMutableArray alloc] init];
	self.visitorList = vArray;
	[vArray	release];
	
	
	NSArray *visitorArray = (NSArray *)[feed valueForKey:@"stream"];
	int numVisitors = [visitorArray count];
	int i;
	Mizooner *visitor;
	NSDictionary *visitorDict;
		
	for (i=0; i<numVisitors; i++) {
		visitorDict = [visitorArray objectAtIndex:i];
		visitor = [[Mizooner alloc] initWithName:[visitorDict valueForKey: @"name"] userProfile:visitorDict];
		[self.visitorList addObject:visitor];

	}
	[jsonParser release];

    return TRUE;	
}


- (NSArray *) fetchNearbyPlaces: (int) radius atIndex: (int) index numberToRet:(int)num_ret {
	
	//	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	//	RootViewController *rvc = delegate.rootViewController;
	Mizoon	*miz = [Mizoon sharedMizoon];
	
	if (![miz needToFetchData: PlacesData]) {
		return self.nearbyPlaces;
	}
	
	MizoonLog(@"fetchNearbyPlaces = lat=%f lon=%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
	
	NSString * placesURL = [NSString stringWithFormat: @"%@/?q=api/places/&lat=%f&lon=%f&index=%i&ret=%i&radius=%i", MIZOON_RESTFUL_SERVER,  
							currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, index, num_ret, radius];
	NSString * response = [self executeRESTfulRequest:[NSURL URLWithString:placesURL]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WS_nearbyPlaces_Completed" object:(id)self];
	
//	id resObj = [response object];
//	
//	if ([resObj isKindOfClass:[NSError class]]) 
//        return nil;
//
//	NSString *places =[resObj valueForKey:@"places"];
//	if (!places || ([places length] < 1 )) 
//		return nil;
//	
//	SBJSON *jsonParser = [SBJSON new];
//	NSDictionary *feed = (NSDictionary *)[jsonParser objectWithString:places error:NULL];
	
	
	if (response == nil || [response length] < 1) {
//		UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"Unknown location coordinate"
//												message:@"Please refresh to get your current coordinate"
//											   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//		[alert1	release];
		return nil;
	}
	
	SBJSON *jsonParser = [SBJSON new];
	
	// Parse the JSON response into an Object
	NSDictionary *feed = (NSDictionary *)[jsonParser objectWithString:response error:NULL];
	
	MizoonLog(@"----------------------total nearby places size=%@", (NSString *) [feed valueForKey:@"size"]);
	self.nearbyPlacesSize = [[feed valueForKey:@"size"] intValue];
	
	// get the array of "stream" from the feed and cast to NSArray
	NSArray *streams = (NSArray *)[feed valueForKey:@"stream"];
	
	if (self.nearbyPlaces !=nil) 
		[self.nearbyPlaces release];
	
	self.nearbyPlaces = streams;
	
	[jsonParser release];
	//	[streams release];
	//	[feed release];
	//	[placesURL release];
	self.placesLastFetch = [NSDate date];

	return streams;
}

- (void) clearNearbyList
{
	if (self.nearbyPeople !=nil) {
		[nearbyPeople release];
		nearbyPeople = nil;
	}
}


- (NSArray *) fetchNearbyPeople: (int) radius atIndex: (int) index numberToRet:(int)num_ret {
	
	//	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	//	RootViewController *rvc = delegate.rootViewController;
	
	if (![self fetchSessionId]) 
		return nil;
	
	NSMutableDictionary *methodArgs = [NSMutableDictionary dictionary];
	[methodArgs setValue: @"2" forKey:kRADIUS];
	[methodArgs setValue: [NSString stringWithFormat:@"%i", num_ret] forKey:kNUMBER_RETURN];
	[methodArgs setValue: sessionId forKey:kSESSID];
	[methodArgs setValue: [NSString stringWithFormat:@"%f",  currentLocation.coordinate.latitude] forKey:kLATITUDE];
	[methodArgs setValue: [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude] forKey:kLONGTITUDE];
	[methodArgs setValue: [NSString stringWithFormat:@"%i",  index] forKey:kINDEX];
	
    NSArray *args = [NSArray arrayWithObjects:methodArgs,nil];
	MizoonLog(@"lat=%f lobn=%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
	//	MizoonLog(@"args=%@", methodArgs);
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:MIZOON_XMLRPC_SERVER forKey:kURL];
	[params setObject:@"nearby.people" forKey:kMETHOD];
    [params setObject:args forKey:kMETHODARGS];
	
	
	/****************** TEST **************************
	 NSEnumerator *enumerator = [methodArgs keyEnumerator];
	 id key;
	 
	 while ((key = [enumerator nextObject])) {
	 MizoonLog(@"key=%@ \t value=%@", key,[methodArgs valueForKey:key] );
	 
	 }
	 ****************** TEST **************************/
	
    XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:[params valueForKey:kURL]]];
    [request setMethod:[params valueForKey:kMETHOD] withObjects: [params valueForKey:kMETHODARGS]];
	
#ifdef MIZOON_DEBUG
	[Mizoon sharedMizoon].methodStart  = [NSDate date];
#endif
	
	XMLRPCResponse *response = [self executeXMLRPCRequest:request byHandlingError:YES];
	
	
	
#ifdef MIZOON_DEBUG
	NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:[Mizoon sharedMizoon].methodStart];
	DebugLog(@"--> Fetch People execution time=%f", executionTime);
#endif
	

	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WS_nearbyPeople_Completed" object:(id)self];
	
	
    id resObj = [response object];
	
	if ([resObj isKindOfClass:[NSError class]]) 
        return nil;
	

	//	[methodArgs release];
//	[params	release];
	
	NSString *people =[resObj valueForKey:@"message"];
	if (!people || ([people length] < 1 )) 
		return nil;
	
	SBJSON *jsonParser = [SBJSON new];
	NSDictionary *feed = (NSDictionary *)[jsonParser objectWithString:people error:NULL];
	NSArray *streams = (NSArray *)[feed valueForKey:@"stream"];
	
	[jsonParser release];
	[request release];

	
	MizoonLog(@"----------------------Number of people=%@", (NSString *) [feed valueForKey:@"size"]);

	self.nearbyPeopleSize = [[feed valueForKey:@"size"] intValue];
	if (self.nearbyPeopleSize == 0) 
		return nil;
	
	if (self.nearbyPeople)
		self.nearbyPeople = [self.nearbyPeople arrayByAddingObjectsFromArray:streams];
	else 	
		self.nearbyPeople = streams;
	
	MizoonLog(@"\n Number of people in the array=%i", [self.nearbyPeople count]);

	self.peopleLastFetch = [NSDate date];

    return streams;	
}


- (NSArray *) fetchLocationsWithPromos: (int) radius atIndex: (int) index numberToRet:(int)num_ret {
	
	if (![self fetchSessionId]) 
		return nil;
	
	NSMutableDictionary *methodArgs = [NSMutableDictionary dictionary];
	[methodArgs setValue: @"2" forKey:kRADIUS];
	[methodArgs setValue: [NSString stringWithFormat:@"%i", num_ret] forKey:kNUMBER_RETURN];
	[methodArgs setValue: sessionId forKey:kSESSID];
#if 1
	[methodArgs setValue: [NSString stringWithFormat:@"%f",  currentLocation.coordinate.latitude] forKey:kLATITUDE];
	[methodArgs setValue: [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude] forKey:kLONGTITUDE];
#else
	[methodArgs setValue: [NSString stringWithFormat:@"%f",  37.44573] forKey:kLATITUDE];
	[methodArgs setValue: [NSString stringWithFormat:@"%f", -122.16145] forKey:kLONGTITUDE];
#endif
	[methodArgs setValue: [NSString stringWithFormat:@"%i",  index] forKey:kINDEX];


    NSArray *args = [NSArray arrayWithObjects:methodArgs,nil];
//	MizoonLog(@"args=%@", args);
	//	MizoonLog(@"args=%@", methodArgs);
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:MIZOON_XMLRPC_SERVER forKey:kURL];
	[params setObject:@"mizoon.loc.promos" forKey:kMETHOD];
    [params setObject:args forKey:kMETHODARGS];
	
	
    XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:[params valueForKey:kURL]]];
    [request setMethod:[params valueForKey:kMETHOD] withObjects: [params valueForKey:kMETHODARGS]];
	
	XMLRPCResponse *response = [self executeXMLRPCRequest:request byHandlingError:YES];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WS_loc_promos_Completed" object:(id)self];
	
    id resObj = [response object];
//	[request release];
	
	if ([resObj isKindOfClass:[NSError class]]) 
        return nil;
	
	self.promoLocSize = 0;
	// release the old dictionary
	if (self.locationsWithPromos) {
		[locationsWithPromos release];
		locationsWithPromos = nil;
	}
	NSString *locations =[resObj valueForKey:@"locations"];
	if (!locations || ([locations length] < 1 )) 
		return nil;
	
	SBJSON *jsonParser = [SBJSON new];
	NSDictionary *feed = (NSDictionary *)[jsonParser objectWithString:locations error:NULL];
	
	MizoonLog(@"----------------------Number of locations with promos=%@", (NSString *) [feed valueForKey:@"size"]);
	
	self.promoLocSize = [[feed valueForKey:@"size"] intValue];
	

	// get the array of "stream" from the feed and cast to NSArray
	self.locationsWithPromos = (NSArray *)[feed valueForKey:@"stream"];
	[jsonParser release];
	
	self.promosLastFetch = [NSDate date];

    return self.locationsWithPromos;	
}






- (NSArray *) fetchPromotions: (int) lid {
	
	Mizoon  *miz = [Mizoon sharedMizoon];
	
	if (![self fetchSessionId]) 
		return nil;
	
	NSMutableDictionary *methodArgs = [NSMutableDictionary dictionary];
	[methodArgs setValue: sessionId forKey:kSESSID];
	[methodArgs setValue: [NSString stringWithFormat:@"%d",  lid] forKey:kLID];
	
    NSArray *args = [NSArray arrayWithObjects:methodArgs,nil];
//	MizoonLog(@"args=%@", args);
	//	MizoonLog(@"args=%@", methodArgs);
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:MIZOON_XMLRPC_SERVER forKey:kURL];
	[params setObject:@"mizoon.promos" forKey:kMETHOD];
    [params setObject:args forKey:kMETHODARGS];
	
	
    XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:[params valueForKey:kURL]]];
    [request setMethod:[params valueForKey:kMETHOD] withObjects: [params valueForKey:kMETHODARGS]];
	
	XMLRPCResponse *response = [self executeXMLRPCRequest:request byHandlingError:YES];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WS_promos_Completed" object:(id)self];
	
    id resObj = [response object];
	[request release];   // xxx
	
	if ([resObj isKindOfClass:[NSError class]]) 
        return NULL;
	
	self.promoSize = 0;
	// release the old dictionary
	if (self.promotions) {
		[promotions release];
		promotions=0;
	}
	
	NSString *promos =[resObj valueForKey:@"promos"];
	if (!promos || ([promos length] < 1 )) 
		return NULL;
	
	SBJSON *jsonParser = [SBJSON new];
	NSDictionary *feed = (NSDictionary *)[jsonParser objectWithString:promos error:NULL];
	
	MizoonLog(@"----------------------Number of promos=%@", (NSString *) [feed valueForKey:@"size"]);
	
	if (!feed)
		return NULL;
	
	self.promoSize = [[feed valueForKey:@"size"] intValue];

	[miz setSelectedLocation:feed];
	
	
	// get the array of "stream" from the feed and cast to NSArray
	self.promotions = (NSArray *)[feed valueForKey:@"stream"];
	
	[jsonParser release];

    return self.promotions;	
}



	 

- (BOOL) fetchSessionId {
	
//	NSArray *args = [NSArray arrayWithObjects:@"99ajheo0l7t2ibbt6ag20s0vh2", @"dp", @"dpp",nil];
	
	if (sessionId)
		return TRUE;
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:MIZOON_XMLRPC_SERVER forKey:kURL];
	[params setObject:@"system.connect" forKey:kMETHOD];
	
    XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:[params valueForKey:kURL]]];
    [request setMethod:[params valueForKey:kMETHOD] withObjects:[params valueForKey:kMETHODARGS]];
	
	XMLRPCResponse *response = [self executeXMLRPCRequest:request byHandlingError:YES];
    id resObj = [response object];
	
	if (![resObj valueForKey:@"sessid"])
		return FALSE;
	
	if (!sessionId) {
		self.sessionId = [[NSString alloc] initWithString:[resObj valueForKey:@"sessid"]];
	} else {
		if ( ![self.sessionId isEqualToString:[resObj valueForKey:@"sessid"]]) {
		
			[sessionId release];
			sessionId = nil;
		
			self.sessionId = [[NSString alloc] initWithString:[resObj valueForKey:@"sessid"]];
		}
	}
//	self.sessionId = [[NSString alloc] initWithString:[resObj valueForKey:@"sessid"]];
	

	
	/****************** TEST *************************
	NSEnumerator *enumerator = [resObj keyEnumerator];
	id key;
	
	while ((key = [enumerator nextObject])) {
		MizoonLog(@"key=%@ \t value=%@", key,[resObj valueForKey:key] );

	}
//	NSString *uid =  [resObj valueForKey:@"uid"];
//	NSString *hName =[resObj valueForKey:@"hostname"];
	****************** TEST **************************/

//	MizoonLog(@"session id=%@", self.sessionId);
	
//	MizoonLog(@"(1)-------------------ref=%d", [request retainCount]);
//	MizoonLog(@"(1)-------------------ref=%d", [response retainCount]);
	
//	[request release];   // XXXX
//	[response release];  // XXXX
	
//	[params	release];	// XXXX

    return TRUE;
}


	 

#pragma mark - RESTful Web services

	 
	 
	/*
	 *  
	 *  	NSString *encodedSysName = [sysName stringByUrlEncoding];
	 *		body = [[NSString stringWithFormat:@"device_uuid=%@&app_version=%@&language=%@&os_version=%@&sys_name=%@&name=%@", 
	 *			deviceuuid, appversion, language, osversion, sysName,name] dataUsingEncoding:NSUTF8StringEncoding]];
	 *
	 */
	 
- (void) mizAyncPost: (NSString *) postUrl postBody: (NSData *) body
{	
	//handle data coming back
	[asyncPostData release];
	asyncPostData = [[NSMutableData alloc] init];
		
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:postUrl]
														cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:30.0];
		
	[theRequest setHTTPMethod:@"POST"];
	[theRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
		
	//create the body
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:body ];
		
	NSString *htmlStr = [[[NSString alloc] initWithData:postBody encoding:NSUTF8StringEncoding] autorelease];
	MizoonLog(@"htmlStr %@", htmlStr);
	[theRequest setHTTPBody:postBody];
		
	NSURLConnection *conn=[[[NSURLConnection alloc] initWithRequest:theRequest delegate:self]autorelease];
		
	if (conn) {  
		MizoonLog(@"Request was scheduled to post");
	}   
	else   	{  
		MizoonLog(@"Failed to create a connection!");
	}  	
}
	 
	 
	 
#pragma mark NSURLConnection callbacks
	 
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[asyncPostData appendData: data];
	MizoonLog(@"did recieve data");
}
	 
-(void) connection:(NSURLConnection *)connection  didFailWithError: (NSError *)error {
		 
	MizoonLog(@"Connection failed with error.");
	/*
	UIAlertView *errorAlert = [[UIAlertView alloc]
	initWithTitle: [error localizedDescription]
	message: [error localizedFailureReason]
	delegate:nil
	cancelButtonTitle:@"OK"
	otherButtonTitles:nil];
	[errorAlert show];
	 [errorAlert release];
	*/
}
	 
	 
- (void) connectionDidFinishLoading: (NSURLConnection*) connection {
	MizoonLog(@"connectionDidFinishLoading");
	//process statsData here or call a helper method to do so.
	//it should parse the "latest version" and the over the air download url and give user some opportunity to upgrade if version numbers don't match...
	//all of this should get pulled out of WPAppDelegate and into it's own class... http request, check for stats methods, delegate methods for http, and present user with option to upgrade
	NSString *statsDataString = [[NSString alloc] initWithData:asyncPostData encoding:NSUTF8StringEncoding];
		 
	//	MizoonLog(@"should be statsDataString %@", statsDataString);
	//need to break this up based on the \n
		 
	[statsDataString release];
		 
}
	 
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	MizoonLog (@"connectionDidReceiveResponse %@", response);
}
	 
	 
	 
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge { 
} 
	 
	 
	 
	 
	 
- (void) handleAuthenticationOKForChallenge: (NSURLAuthenticationChallenge *) aChallenge withUser: (NSString*) username password: (NSString*) password {
									
}
	 
	 
- (void) handleAuthenticationCancelForChallenge: (NSURLAuthenticationChallenge *) aChallenge {
		 
}
	 
	 
	 

- (NSString *)executeRESTfulRequest:(NSURL *)url 
{
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
	
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
											cachePolicy:NSURLRequestReturnCacheDataElseLoad
											timeoutInterval:30];
	
	// Make synchronous request
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest
									returningResponse:&response
												error:&error];

	
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//		MizoonLog(@"Received status code: %d %@", [(NSHTTPURLResponse *) response statusCode], 
//			  [NSHTTPURLResponse localizedStringForStatusCode:[(NSHTTPURLResponse *) response statusCode]]) ;
	}
	
//	if (error != NULL) {
//		MizoonLog(@"Error code: %@", [error code]);
//		return nil;
//	}
//	
	if (!urlData) 
		return nil;
	

 	// Construct a String around the Data from the response
	return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}



- (NSString *)executeRESTfulAuthRequest:(NSURL *)url withUsername: (NSString *)uid andPassword: (NSString *) password
{
	/*
	 NSData *urlData;
	 NSURLResponse *response;
	 NSError *error;
	 
	 NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
	 cachePolicy:NSURLRequestReturnCacheDataElseLoad
	 timeoutInterval:30];
	 
	 NSString *format = [NSString stringWithFormat:@"%@:%@", uid, password];
	 [urlRequest addValue:[NSString stringWithFormat:@"Basic %@", [format base64Encoding]] forHTTPHeaderField:@"Authorization"];
	 
	 
	 // Make synchronous request
	 urlData = [NSURLConnection sendSynchronousRequest:urlRequest
	 returningResponse:&response
	 error:&error];
	 
	 
	 if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
	 MizoonLog(@"Received status code: %d %@", [(NSHTTPURLResponse *) response statusCode], 
	 [NSHTTPURLResponse localizedStringForStatusCode:[(NSHTTPURLResponse *) response statusCode]]) ;
	 }
	 
	 if (error != NULL) 
	 return nil;
	 
	 if (!urlData) 
	 return nil;
	 
	 
	 // Construct a String around the Data from the response
	 return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
	 */
	return nil;
}




			  
			  

#pragma mark - XMLRPC

- (XMLRPCResponse *)executeXMLRPCRequest:(XMLRPCRequest *)req byHandlingError:(BOOL)shouldHandleFalg {
	
	//	BOOL httpAuthEnabled = [[currentBlog objectForKey:@"authEnabled"] boolValue];
	BOOL httpAuthEnabled = FALSE;
	
	//	NSString *httpAuthUsername = [currentBlog valueForKey:@"authUsername"];
	//	NSString *httpAuthPassword = [self getHTTPPasswordFromKeychainInContextOfCurrentBlog:currentBlog];
	
	XMLRPCResponse *userInfoResponse = nil;
	if (httpAuthEnabled) {
		//		userInfoResponse = [XMLRPCConnection sendSynchronousXMLRPCRequest:req
		//															 withUsername:httpAuthUsername
		//															  andPassword:httpAuthPassword];
	} else {
		userInfoResponse = [XMLRPCConnection sendSynchronousXMLRPCRequest:req];
	}
    NSError *err = [self errorWithResponse:userInfoResponse shouldHandle:shouldHandleFalg];
	
    if (err)
        return nil;
	
//    return [userInfoResponse object];
	return userInfoResponse;
}


- (NSError *)errorWithResponse:(XMLRPCResponse *)res shouldHandle:(BOOL)shouldHandleFlag {
    NSError *err = nil;
	
    if (!res)
        err = [self defaultError];
	
    if ([res isKindOfClass:[NSError class]]) {
        err = (NSError *)res;
    } else {
        if ([res isFault]) {
            NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:[res fault], NSLocalizedDescriptionKey, nil];
            err = [NSError errorWithDomain:@"com.iphone.mizoon" code:[[res code] intValue] userInfo:usrInfo];
        }
		
        if ([res isParseError]) {
            err = [res object];
        }
    }
	
    if (err && shouldHandleFlag) {
        // patch to eat the zero posts error
        // "Either there are no posts, or something went wrong."
		
        NSString *zeroPostsError = @"Either there are no posts, or something went wrong.";
        NSRange range = [[err description] rangeOfString:zeroPostsError options:NSBackwardsSearch];
		
        if (range.location == NSNotFound) {
            [self handleError:err];
        } else {
            return [NSMutableArray array];
        }
    }
	
    return err;
}


- (NSError *)defaultError {
    NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Failed to request the server.", NSLocalizedDescriptionKey, nil];
    return [NSError errorWithDomain:@"com.iphone.mizoon" code:-1 userInfo:usrInfo];
}

- (BOOL)handleError:(NSError *)err {
    UIAlertView *alert1 = nil;
	
    if ([[err localizedDescription] isEqualToString:@"Bad login/pass combination."]) {
        alert1 = [[UIAlertView alloc] initWithTitle:@"Communication Error"
											message:@"Bad user name or password."
										   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    } else if ([err code] == NSURLErrorUserCancelledAuthentication) {
        alert1 = [[UIAlertView alloc] initWithTitle:@"Communication Error"
											message:@"Bad HTTP Authentication user name or password."
										   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    } else {
        alert1 = [[UIAlertView alloc] initWithTitle:@"Communication Error"
											message:[err localizedDescription]
										   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
	
    [alert1 show];
    MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate setAlertRunning:YES];
	
    [alert1 release];

	[[[Mizoon sharedMizoon] getRootViewController] popView];

    return YES;
}


#pragma mark Helper Methods


- (void) releaseVisitors
{	
	int vCount = [visitorList count];
	Mizooner *visitor;
	
	if (visitorList) {
		for (int i=0; i < vCount; i++) {
			
			visitor = [visitorList objectAtIndex:i];
			
			[visitor release];
//			[p.name release];
	
		}
		
		MizoonLog(@"1 - Ref count = %d", [visitorList retainCount]);

		[visitorList release];
		MizoonLog(@"2 - Ref count = %d", [visitorList retainCount]);

		visitorList = nil;
		MizoonLog(@"3 - Ref count = %d", [visitorList retainCount]);

	}
}


/*
 * Returns true if name, lat and lon are equal to the the checked in location data or if the name is equal to the checkin location's name 
 * and lat and lon are set to 0
 * 
 */
- (BOOL) userIsInThisPlace: (NSString *) name latitude: (float) lat longitude: (float) lon {
	
	CheckinInfo *cInfo = self.checkedinLoc;
		
	// if latitude and longitude are 0, only compare the name
	if (lat == 0  && lon == 0 && [name isEqualToString:cInfo->name] ) 
		return TRUE;
	
	if (cInfo->lat == lat && cInfo->lon == lon && [name isEqualToString:cInfo->name] ) 
		return TRUE;
	
	return FALSE;
}


#pragma mark -
#pragma mark KeyChain Helper Methods Add/Delete passwords in Keychain

/* NOTE: If using SFHFKeychainUtils, we will be passing the blogName (blog url collected on AddBlog view) as the serviceName...
 This is because the util code wants to key off the serviceName for uniqueness when adding to keychain
 in our case, userName and password *could* possibly be the same, but the url should always be different from any other blog
 so that's our choice for a "unique" value to go into the Util's "serviceName" field.
 Currently that assumption is on the wordpress iphone trac for validation...
 
 
 Method Signatures in SFHFKeychainUtils:
 
 + (NSString *) getPasswordForUsername: (NSString *) username andServiceName: (NSString *) serviceName error: (NSError **) error;
 + (void) storeUsername: (NSString *) username andPassword: (NSString *) password forServiceName: (NSString *) serviceName updateExisting: (BOOL) updateExisting error: (NSError **) error;
 + (void) deleteItemForUsername: (NSString *) username andServiceName: (NSString *) serviceName error: (NSError **) error;
 */



-(NSString*) getMizPasswordFromKeychainWithUsername:(NSString *)userName  {
	NSString * keychainPWD = @"";
	NSError *anError = nil;
	
	keychainPWD = [SFHFKeychainUtils getPasswordForUsername : userName andServiceName : @MIZOON_SERVICE error:&anError];

	return keychainPWD;	
}


-(void) saveMizPasswordToKeychain:(NSString *)password andUserName:(NSString *)userName  {
	//call util's store password function, pass in the password, the username and the servicename 
	//note that there is an updateExisting BOOL in the util call below, whereby you can tell the code NOT to modify, but only create if not in keychain already
	//this isn't implemented in the method call for this method, but could be if needed.  Currently hard-coded to FALSE because this code path
	//should only ever get called for a "create" kind of scenario from the Add Blog view's Save button.  (code in: BlogDetailModalViewController)
	//MizoonLog(@"Inside saveBlogPasswordToKeychain... password is %@ userName is %@ blogURL is %@", password, userName, blogURL);
	NSError *anError = nil; 
	[ SFHFKeychainUtils storeUsername:userName andPassword:password forServiceName: @MIZOON_SERVICE updateExisting:FALSE error:&anError ];
}

-(void) updateMizPasswordInKeychain:(NSString *)password andUserName:(NSString *)userName {
	//call util's update pwd function - pass in the "new" password, the username and the blogURL (blogURL = servicename for the Util's code)
	//note that there is an updateExisting BOOL in the util call below, whereby you can tell the code NOT to modify, but only create if not in keychain already
	//this isn't implemented in the method call for this method, but could be if needed.  Currently hard-coded to TRUE here because this code path
	//gets called for an "update" kind of scenario from the Edit Blog view's Save button.  (code in: BlogDetailModalViewController)
	//MizoonLog(@"Inside updatePasswordInKeychain... password is %@ userName is %@ blogURL is %@", password, userName, blogURL);
	NSError *anError = nil;
	[ SFHFKeychainUtils storeUsername:userName andPassword:password forServiceName:@MIZOON_SERVICE  updateExisting:TRUE error:&anError ];
}


-(void) deleteMizFromKeychain:(NSString *)userName {
	MizoonLog(@"inside deleteBlogFromKeychain");
	//Note: The Util will delete the entire keychain entry: (username, mizoon url and password) we just don't need the password passed in to do that
	//username and blogURL are also stored in the standard data structure - password is what we care about here
	//username and blogURL are NOT deleted from the standard data structure (blogsList) at this point, that is handled separately
	//This should only get called from the Remove Blog button of the Edit Blog view (code in BlogDetailModalViewController)
	//call util's delete pwd function -- pass in username, and blogURL
	MizoonLog(@"Inside deleteMizFromKeychain... userName is %@ blogURL is %@", userName, @MIZOON_SERVICE);
	NSError *anError = nil;
	[ SFHFKeychainUtils deleteItemForUsername: userName andServiceName: @MIZOON_SERVICE error:&anError ];
	
}

#pragma mark utilities





- (NSArray *) getJSONResponseStream: (NSString *) resSource {
	id	jsonObject;
	
	//	NSData *resData = [[NSString stringWithFormat:@"%@", resSource] dataUsingEncoding:NSUTF8StringEncoding];
	
	MizXMLParser *xmlParser = [[MizXMLParser alloc] init];
	if ( ![xmlParser parseXMLString:resSource] ) {
		[xmlParser.message release];
		[xmlParser.sessionID release];
		[xmlParser release];
		return nil;
	}
	MizoonLog(@"Message= \n %@", xmlParser.message);
	
	SBJSON *jsonParser = [SBJSON new];
	jsonObject = [jsonParser objectWithString:xmlParser.message error:NULL];
	NSDictionary *feed = (NSDictionary *)jsonObject;
	
	MizoonLog(@"----------------------total nearby people size=%@", (NSString *) [feed valueForKey:@"size"]);
	self.nearbyPeopleSize = [[feed valueForKey:@"size"] intValue];
	
	// get the array of "stream" from the feed and cast to NSArray
	NSArray *streams = (NSArray *)[feed valueForKey:@"stream"];
	[jsonParser release];

	// TODO free xmlParser
    return streams;		
}


#ifdef SGEO


#pragma mark -
#pragma mark SimpleGeo Helper methods 


- (BOOL) simpleGeoSendrequest: (NSString *) reqString withRequestParam: (NSMutableDictionary *) requestParam
{
	MizoonLocation	*aLoc;
	
	NSURL *requestURL = [NSURL URLWithString:[reqString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                               relativeToURL:[NSURL URLWithString:SimpleGeoURL]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:requestURL];    
	
	request.HTTPMethod = @"GET";
    
	NSDictionary *oAuthParams = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
								  SGConsumerKey, @"oauth_consumer_key",
								  @"HMAC-SHA1", @"oauth_signature_method", 
								  SGOauthVersion, @"oauth_version", nil] retain];
	
	
    [requestParam addEntriesFromDictionary:oAuthParams];
    [requestParam setValue:[self generateTimestamp] forKey:@"oauth_timestamp"];
    [requestParam setValue:[self generateNonce] forKey:@"oauth_nonce"];
//	[requestParam setValue:@"8" forKey:@"radius"];
	
	//	[newOAuthParams addEntriesFromDictionary:params];
	
    NSString* baseString = [self signatureBaseStringFromRequest:request params:requestParam];
    NSString* signature = [self signText:baseString withSecret:[NSString stringWithFormat:@"%@&", SGSecretKey]];
    [requestParam setValue:signature forKey:@"oauth_signature"];
	
    NSString* newURL = [NSString stringWithFormat:@"%@?%@", [requestURL absoluteString], [self normalizeRequestParams:requestParam]];
    [request setURL:[NSURL URLWithString:newURL]];
    
	MizoonLog(@"SimpleGeo Request - %@", newURL);
    NSError* error = nil;
    NSURLResponse* response = nil;  
    
	
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	//	MizoonLog(@"SGOAuth - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	
    NSDictionary* jsonObject = nil;;
    if(data && ![data isKindOfClass:[NSNull class]]) {
        NSError* error = nil;
        jsonObject = [NSDictionary dictionaryWithJSONData:data error:&error];
		
        if(error) {
            MizoonLog(@"fetchNearbyPlaces - Error occurred while parsing GeoJSON object: %@", [error description]);
			[[NSNotificationCenter defaultCenter] postNotificationName:@"GEOAPI_Request_Failed" object:(id)self];
			return FALSE;
		}
    }
    
	
    if(jsonObject && error && ![error isKindOfClass:[NSNull class]])
        error = [NSError errorWithDomain:[jsonObject objectForKey:@"message"]
                                    code:[[jsonObject objectForKey:@"code"] intValue]
                                userInfo:nil];
	
    
    if(error || (error && [error isKindOfClass:[NSNull class]])) {
		MizoonLog(@"fetchNearbyPlaces - Error occurred: %@", [error description]);
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GEOAPI_Request_Failed" object:(id)self];
		return FALSE;
	}
    
	if (self.fetchedData) {
		[fetchedData release];
		fetchedData = nil;
	}
	
	NSArray *results = [jsonObject objectForKey:@"features"];
	if (results && [results count] > 0) { 
		self.fetchedData = [[NSMutableArray alloc] init];
		
		for (id obj in results) {
			aLoc = [MizoonLocation simpleGeoLocDict:obj];
			[self.fetchedData addObject:aLoc];
			[aLoc release];
		}	
		
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SG_Not_Expected_Return" object:(id)self];
		return FALSE;
	}
	
	return TRUE;
}


- (NSString*) signatureBaseStringFromRequest:(NSURLRequest*)request params:(NSDictionary*)params
{
    return [NSString stringWithFormat:@"%@&%@&%@",
            [request HTTPMethod],
            [[[request URL] absoluteString] URLEncodedString],
            [[self normalizeRequestParams:params] URLEncodedString]];
}

- (NSString*) normalizeRequestParams:(NSDictionary*)params
{
    NSMutableArray *parameterPairs = [NSMutableArray arrayWithCapacity:([params count])];
    
    NSString* value;
    for(NSString* param in params) {
        
        value = [params objectForKey:param];
        param = [NSString stringWithFormat:@"%@=%@", [param URLEncodedString], [value URLEncodedString]];
        [parameterPairs addObject:param];
    }
    
    NSArray* sortedPairs = [parameterPairs sortedArrayUsingSelector:@selector(compare:)];
    return [sortedPairs componentsJoinedByString:@"&"];
}

- (NSString*) generateTimestamp
{
    return [NSString stringWithFormat:@"%d", time(NULL)];
}

- (NSString *) generateNonce
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    NSMakeCollectable(theUUID);
    return (NSString*)string;
}

- (NSString*) signText:(NSString*)text withSecret:(NSString*)secret 
{
	NSData *theData;
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
    hmac_sha1((unsigned char *)[clearTextData bytes], [clearTextData length], (unsigned char*)[secretData bytes], [secretData length], result);
    
    //Base64 Encoding
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(result, 20, base64Result, &theResultLength);
    theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    return [base64EncodedResult autorelease];
}

#endif

#pragma mark GEOAPI


- (NSString	*) queryRestaurants: (NSString *) searchText
{
	Mizoon *miz = [Mizoon sharedMizoon];
	
	NSMutableDictionary *queryDict = [[[NSMutableDictionary alloc] init] autorelease];
	[queryDict setValue:[NSNumber numberWithFloat:[miz getUserlat]] forKey:@"lat"];
	[queryDict setValue:[NSNumber numberWithFloat:[miz getUserlon]]  forKey:@"lon"];
	[queryDict setValue:@"1km" forKey:@"radius"];
	[queryDict setValue:[NSNumber numberWithInt:100] forKey:@"limit"];
	
	NSMutableDictionary *entityDict = [[[NSMutableDictionary alloc] init] autorelease];
    [entityDict setValue:[NSNull null] forKey:@"guid"];
	[entityDict setValue:[NSNull null] forKey:@"geom"];
	[entityDict setValue:[NSNull null] forKey:@"distance-from-origin"];
	[entityDict setValue:[NSNull null] forKey:@"distance-from-center"];
	[entityDict setValue:@"business" forKey:@"type"];
	
	//	[entityDict setValue:[NSString stringWithFormat:@"%f",  currentLocation.coordinate.latitude] forKey:@"lat"];
	//  [entityDict setValue:[NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude] forKey:@"lon"];
    [entityDict setValue:[NSNull null] forKey:@"distance-from-center"];
	
	
    NSMutableDictionary *listingDict = [[[NSMutableDictionary alloc] init] autorelease];
	
	if (searchText) 
		[listingDict setValue:searchText forKey:@"name^="];
	
	[listingDict setValue:[NSNull null] forKey:@"name"];
	
    [listingDict setValue:[NSNull null] forKey:@"address"];
	[listingDict setValue:[NSNull null] forKey:@"phone"];
	[listingDict setValue:[NSNull null] forKey:@"listing-url"];
	[listingDict setValue:[NSNull null]  forKey:@"verticals"];

	[listingDict setValue:@"restaurants" forKey:@"verticals"];
	//	[listingDict setValue:@"food-and-drink:coffee-houses" forKey:@"b:verticals"];
	
    [entityDict setValue:listingDict forKey:@"view.listing"];	
	[queryDict setValue:[NSArray arrayWithObject:entityDict] forKey:@"entity"];
	
	return [queryDict JSONRepresentation];
}


- (NSString	*) queryLodging: (NSString *) searchText
{
	Mizoon *miz = [Mizoon sharedMizoon];
	
	NSMutableDictionary *queryDict = [[[NSMutableDictionary alloc] init] autorelease];
	[queryDict setValue:[NSNumber numberWithFloat:[miz getUserlat]] forKey:@"lat"];
	[queryDict setValue:[NSNumber numberWithFloat:[miz getUserlon]]  forKey:@"lon"];
	[queryDict setValue:@"1km" forKey:@"radius"];
	[queryDict setValue:[NSNumber numberWithInt:100] forKey:@"limit"];
	
	NSMutableDictionary *entityDict = [[[NSMutableDictionary alloc] init] autorelease];
    [entityDict setValue:[NSNull null] forKey:@"guid"];
	[entityDict setValue:[NSNull null] forKey:@"geom"];
	[entityDict setValue:[NSNull null] forKey:@"distance-from-origin"];
	[entityDict setValue:[NSNull null] forKey:@"distance-from-center"];
	[entityDict setValue:@"business" forKey:@"type"];
	
    NSMutableDictionary *listingDict = [[[NSMutableDictionary alloc] init] autorelease];
	
	if (searchText) 
		[listingDict setValue:searchText forKey:@"name^="];
	
	[listingDict setValue:[NSNull null] forKey:@"name"];
    [listingDict setValue:[NSNull null] forKey:@"address"];
	[listingDict setValue:[NSNull null] forKey:@"phone"];
	[listingDict setValue:[NSNull null] forKey:@"listing-url"];
	
	[listingDict setValue:[NSNull null]  forKey:@"verticals"];
	
	NSMutableArray *verticals =[[[NSMutableArray alloc] init] autorelease];
	[verticals addObject:@"tourist-center"];
	[verticals addObject:@"tourist-center:hostels"];
	[verticals addObject:@"tourist-center:hotels-and-motels"];
	[verticals addObject:@"tourist-center:cottages-and-cabins"];
	[verticals addObject:@"tourist-center:bed-and-breakfast"];
	[verticals addObject:@"tourist-center:lodges-and-vacation-homes"];
	[verticals addObject:@"tourist-center:airlines"];
	[verticals addObject:@"tourist-center:airport"];
	[verticals addObject:@"tourist-center:parking"];
	[verticals addObject:@"tourist-center:public-transportation-and-transit"];
	[verticals addObject:@"tourist-center:railroads-and-trains"];
	[verticals addObject:@"tourist-center:resorts"];
	[verticals addObject:@"tourist-center:taxi-and-car-services"];
	[verticals addObject:@"tourist-center:tour-operators-and-cruises"];
	[verticals addObject:@"tourist-center:tourism-services-and-tickets"];
	[verticals addObject:@"tourist-center:tourist-attractions-and-information"];
	[verticals addObject:@"tourist-center:wildlife-preserve"];
	[verticals addObject:@"tourist-center:historical-spots"];
	[verticals addObject:@"tourist-center:limos-armored-cars-and-chauffers"];
	
	[listingDict setValue:verticals  forKey:@"verticals|="];
	
    [entityDict setValue:listingDict forKey:@"view.listing"];	
	[queryDict setValue:[NSArray arrayWithObject:entityDict] forKey:@"entity"];
	
	return [queryDict JSONRepresentation];
}



- (NSString	*) queryShopping: (NSString *) searchText
{
	Mizoon *miz = [Mizoon sharedMizoon];
	
	NSMutableDictionary *queryDict = [[[NSMutableDictionary alloc] init] autorelease];
	[queryDict setValue:[NSNumber numberWithFloat:[miz getUserlat]] forKey:@"lat"];
	[queryDict setValue:[NSNumber numberWithFloat:[miz getUserlon]]  forKey:@"lon"];
	[queryDict setValue:@"1km" forKey:@"radius"];
	[queryDict setValue:[NSNumber numberWithInt:100] forKey:@"limit"];
	
	NSMutableDictionary *entityDict = [[[NSMutableDictionary alloc] init] autorelease];
    [entityDict setValue:[NSNull null] forKey:@"guid"];
	[entityDict setValue:[NSNull null] forKey:@"geom"];
	[entityDict setValue:[NSNull null] forKey:@"distance-from-origin"];
	[entityDict setValue:[NSNull null] forKey:@"distance-from-center"];
	[entityDict setValue:@"business" forKey:@"type"];
	
    NSMutableDictionary *listingDict = [[[NSMutableDictionary alloc] init] autorelease];
	
	if (searchText) 
		[listingDict setValue:searchText forKey:@"name^="];
	
	[listingDict setValue:[NSNull null] forKey:@"name"];
    [listingDict setValue:[NSNull null] forKey:@"address"];
	[listingDict setValue:[NSNull null] forKey:@"phone"];
	[listingDict setValue:[NSNull null] forKey:@"listing-url"];
	
	[listingDict setValue:[NSNull null]  forKey:@"verticals"];
	
	NSMutableArray *verticals =[[[NSMutableArray alloc] init] autorelease];
	[verticals addObject:@"shopping"];
	[verticals addObject:@"shopping:fashion"];
	[verticals addObject:@"shopping:baby-and-kids-stuff"];
	[verticals addObject:@"shopping:books-news-magazines"];
	[verticals addObject:@"shopping:books-news-magazines:bookstores"];
	[verticals addObject:@"shopping:books-news-magazines:comic-books"];
	[verticals addObject:@"shopping:books-news-magazines:magazines-and-news"];
	[verticals addObject:@"shopping:cameras-and-photos"];
	[verticals addObject:@"shopping:cards-and-stationery"];
	[verticals addObject:@"shopping:computers-and-electronics"];
	[verticals addObject:@"shopping:cosmetics-and-beauty-supplies"];
	[verticals addObject:@"shopping:costumes"];
	[verticals addObject:@"shopping:dance-supplies"];
	[verticals addObject:@"shopping:department-stores"];
	[verticals addObject:@"shopping:discount-stores-and-pawn-shops"];
	[verticals addObject:@"shopping:drugstores"];
	[verticals addObject:@"shopping:fashion:accessories"];
	[verticals addObject:@"shopping:fashion:childrens-clothing"];
	[verticals addObject:@"shopping:fashion:leather-goods"];
	[verticals addObject:@"shopping:fashion:lingerie"];
	[verticals addObject:@"shopping:fashion:maternity-wear"];
	[verticals addObject:@"shopping:fashion:mens-clothing"];
	[verticals addObject:@"shopping:fashion:shoe-stores"];
	[verticals addObject:@"shopping:fashion:sports-wear"];
	[verticals addObject:@"shopping:fashion:womens-clothing"];
	[verticals addObject:@"shopping:florists"];
	[verticals addObject:@"shopping:frames-and-picture-framin"];
	[verticals addObject:@"shopping:furniture"];
	[verticals addObject:@"shopping:gift-and-novelty-stores"];
	[verticals addObject:@"shopping:glasses-and-optometrist"];
	[verticals addObject:@"shopping:jewelry-and-watches"];
	[verticals addObject:@"shopping:luggage"];
	[verticals addObject:@"shopping:outlet-stores"];
	[verticals addObject:@"shopping:shoes"];
	[verticals addObject:@"shopping:shopping-malls-and-centers"];
	[verticals addObject:@"shopping:sporting-goods"];
	[verticals addObject:@"shopping:thrift-stores-and-vintage"];
	[verticals addObject:@"shopping:tobacco-shops"];
	[verticals addObject:@"shopping:toy-stores"];
	[verticals addObject:@"shopping:wedding-and-bridal"];
	[verticals addObject:@"shopping"];
	[verticals addObject:@"shopping:wholesale-stores"];

	[listingDict setValue:verticals  forKey:@"verticals|="];
	
    [entityDict setValue:listingDict forKey:@"view.listing"];	
	[queryDict setValue:[NSArray arrayWithObject:entityDict] forKey:@"entity"];
	
	return [queryDict JSONRepresentation];
}

- (NSString	*) queryNightLife: (NSString *) searchText
{
	Mizoon *miz = [Mizoon sharedMizoon];
	
	NSMutableDictionary *queryDict = [[[NSMutableDictionary alloc] init] autorelease];
	[queryDict setValue:[NSNumber numberWithFloat:[miz getUserlat]] forKey:@"lat"];
	[queryDict setValue:[NSNumber numberWithFloat:[miz getUserlon]]  forKey:@"lon"];
	[queryDict setValue:@"1km" forKey:@"radius"];
	[queryDict setValue:[NSNumber numberWithInt:100] forKey:@"limit"];
	
	NSMutableDictionary *entityDict = [[[NSMutableDictionary alloc] init] autorelease];
    [entityDict setValue:[NSNull null] forKey:@"guid"];
	[entityDict setValue:[NSNull null] forKey:@"geom"];
	[entityDict setValue:[NSNull null] forKey:@"distance-from-origin"];
	[entityDict setValue:[NSNull null] forKey:@"distance-from-center"];
	[entityDict setValue:@"business" forKey:@"type"];
	
    NSMutableDictionary *listingDict = [[[NSMutableDictionary alloc] init] autorelease];
	
	if (searchText) 
		[listingDict setValue:searchText forKey:@"name^="];
	
	[listingDict setValue:[NSNull null] forKey:@"name"];
    [listingDict setValue:[NSNull null] forKey:@"address"];
	[listingDict setValue:[NSNull null] forKey:@"phone"];
	[listingDict setValue:[NSNull null] forKey:@"listing-url"];
	
	[listingDict setValue:[NSNull null]  forKey:@"verticals"];
	
	NSMutableArray *verticals =[[[NSMutableArray alloc] init] autorelease];
	[verticals addObject:@"arts-entertainment-and-nightlife:bars"];
	[verticals addObject:@"arts-entertainment-and-nightlife:adult:adult-entertainment"];
	[verticals addObject:@"arts-entertainment-and-nightlife:bars"];
	[verticals addObject:@"arts-entertainment-and-nightlife:bars:gay-bars"];
	[verticals addObject:@"arts-entertainment-and-nightlife:bars:hookah-bars"];
	[verticals addObject:@"arts-entertainment-and-nightlife:bars:lounges"];
	[verticals addObject:@"arts-entertainment-and-nightlife:bars:pubs"];
	[verticals addObject:@"arts-entertainment-and-nightlife:bars:sports-bars"];
	[verticals addObject:@"arts-entertainment-and-nightlife:bars:wine-bars"];
	[verticals addObject:@"arts-entertainment-and-nightlife:billiards-and-pool-halls"];
	[verticals addObject:@"arts-entertainment-and-nightlife:casinos-and-gambling"];
	[verticals addObject:@"arts-entertainment-and-nightlife:comedy-clubs"];
	[verticals addObject:@"arts-entertainment-and-nightlife:dance-clubs"];
	[verticals addObject:@"arts-entertainment-and-nightlife:jazz-and-blues"];
	[verticals addObject:@"arts-entertainment-and-nightlife:karaoke"];
	[verticals addObject:@"arts-entertainment-and-nightlife:movie-theaters"];
	[verticals addObject:@"arts-entertainment-and-nightlife:nightclubs"];
	[verticals addObject:@"arts-entertainment-and-nightlife:orchestras-symphonies-and-bands"];
	
	[listingDict setValue:verticals  forKey:@"verticals|="];
	
    [entityDict setValue:listingDict forKey:@"view.listing"];	
	[queryDict setValue:[NSArray arrayWithObject:entityDict] forKey:@"entity"];
	
	return [queryDict JSONRepresentation];
}




- (NSString	*) queryPlaces: (NSString *) searchText
{
	Mizoon *miz = [Mizoon sharedMizoon];
	
	NSMutableDictionary *queryDict = [[[NSMutableDictionary alloc] init] autorelease];
	[queryDict setValue:[NSNumber numberWithFloat:[miz getUserlat]] forKey:@"lat"];
	[queryDict setValue:[NSNumber numberWithFloat:[miz getUserlon]]  forKey:@"lon"];
	[queryDict setValue:@"1km" forKey:@"radius"];
	[queryDict setValue:[NSNumber numberWithInt:80] forKey:@"limit"];
	
	NSMutableDictionary *entityDict = [[[NSMutableDictionary alloc] init] autorelease];
    [entityDict setValue:[NSNull null] forKey:@"guid"];
	[entityDict setValue:[NSNull null] forKey:@"geom"];
	[entityDict setValue:[NSNull null] forKey:@"distance-from-origin"];
	[entityDict setValue:[NSNull null] forKey:@"distance-from-center"];
	[entityDict setValue:@"business" forKey:@"type"];
	
    NSMutableDictionary *listingDict = [[[NSMutableDictionary alloc] init] autorelease];
	
	if (searchText) 
		[listingDict setValue:searchText forKey:@"name^="];
	
	[listingDict setValue:[NSNull null] forKey:@"name"];
    [listingDict setValue:[NSNull null] forKey:@"address"];
	[listingDict setValue:[NSNull null] forKey:@"phone"];
	[listingDict setValue:[NSNull null] forKey:@"listing-url"];
	
	[listingDict setValue:[NSNull null]  forKey:@"verticals"];
	
	NSMutableArray *verticals =[[[NSMutableArray alloc] init] autorelease];
	[verticals addObject:@"arts-entertainment-and-nightlife:bars"];
	[verticals addObject:@"arts-entertainment-and-nightlife:concert-halls-and-theaters"];
	[verticals addObject:@"arts-entertainment-and-nightlife:nightclubs"];
	[verticals addObject:@"arts-entertainment-and-nightlife:movie-theaters"];
	[verticals addObject:@"arts-entertainment-and-nightlife:jazz-and-blues"];
	[verticals addObject:@"food-and-drink:coffee-houses"];
	[verticals addObject:@"food-and-drink:grocery-and-convenience-stores"];
	[verticals addObject:@"food-and-drink:supermarkets"];
	[verticals addObject:@"food-and-drink:breweries"];
	[verticals addObject:@"food-and-drink:juice-bars-and-smoothies"];
	[verticals addObject:@"food-and-drink:health-food"];
	[verticals addObject:@"food-and-drink:ice-cream-and-frozen-yogurt"];
	[verticals addObject:@"health-hospitals-and-medicine"];
	[verticals addObject:@"higher-education-and-vocational"];
	[verticals addObject:@"kids-and-child-care:public-schools"];
	[verticals addObject:@"public-and-social-services:postal-offices"];
	[verticals addObject:@"public-and-social-services:library"];
	[verticals addObject:@"real-estate-and-moving:apartments-and-condos"];
	[verticals addObject:@"religious-and-spiritual:christians"];
	[verticals addObject:@"religious-and-spiritual:mosques"];
	[verticals addObject:@"religious-and-spiritual:buddhists"];
	[verticals addObject:@"restaurants"];
	[verticals addObject:@"shopping"];
	[verticals addObject:@"shopping:department-stores"];
	[verticals addObject:@"shopping:wholesale-stores"];
	[verticals addObject:@"shopping:sporting-goods"];
	[verticals addObject:@"shopping:fashion"];
	[verticals addObject:@"sports-the-outdoors-and-recreation:parks"];
	[verticals addObject:@"sports-the-outdoors-and-recreation"];
	[verticals addObject:@"sports-the-outdoors-and-recreation:parks"];
	[verticals addObject:@"sports-the-outdoors-and-recreation:yoga"];
	[verticals addObject:@"sports-the-outdoors-and-recreation:swimming-pools"];
	[verticals addObject:@"sports-the-outdoors-and-recreation:tennis"];
	[verticals addObject:@"sports-the-outdoors-and-recreation:swimming-pools"];
	[verticals addObject:@"sports-the-outdoors-and-recreation:gyms-and-personal-trainers"];
	[verticals addObject:@"sports-the-outdoors-and-recreation:sports-clubs-and-organizations"];
	[verticals addObject:@"tourist-center:airport"];
	[verticals addObject:@"tourist-center:airlines"];
	[verticals addObject:@"tourist-center:hostels"];
	[verticals addObject:@"tourist-center:historical-spots"];
	[verticals addObject:@"tourist-center:hotels-and-motels"];
	[verticals addObject:@"tourist-center:railroads-and-trains"];
	[verticals addObject:@"tourist-center:museums"];
	[verticals addObject:@"tourist-center:zoos"];
	
	
	[listingDict setValue:verticals  forKey:@"verticals|="];

//	[listingDict setValue:[NSNull null]  forKey:@"verticals"];

    [entityDict setValue:listingDict forKey:@"view.listing"];	
	[queryDict setValue:[NSArray arrayWithObject:entityDict] forKey:@"entity"];
	
	return [queryDict JSONRepresentation];
}



- (NSString	*) queryCafes: (NSString *) searchText
{
	Mizoon *miz = [Mizoon sharedMizoon];
	
	NSMutableDictionary *queryDict = [[[NSMutableDictionary alloc] init] autorelease];
	[queryDict setValue:[NSNumber numberWithFloat:[miz getUserlat]] forKey:@"lat"];
	[queryDict setValue:[NSNumber numberWithFloat:[miz getUserlon]]  forKey:@"lon"];
	[queryDict setValue:@"1km" forKey:@"radius"];
	[queryDict setValue:[NSNumber numberWithInt:100] forKey:@"limit"];
	
	NSMutableDictionary *entityDict = [[[NSMutableDictionary alloc] init] autorelease];
    [entityDict setValue:[NSNull null] forKey:@"guid"];
	[entityDict setValue:[NSNull null] forKey:@"geom"];
	[entityDict setValue:[NSNull null] forKey:@"distance-from-origin"];
	[entityDict setValue:[NSNull null] forKey:@"distance-from-center"];
	[entityDict setValue:@"business" forKey:@"type"];
	
    NSMutableDictionary *listingDict = [[[NSMutableDictionary alloc] init] autorelease];
	
	if (searchText) 
		[listingDict setValue:searchText forKey:@"name^="];
	
	[listingDict setValue:[NSNull null] forKey:@"name"];
	
    [listingDict setValue:[NSNull null] forKey:@"address"];
	[listingDict setValue:[NSNull null] forKey:@"phone"];
	[listingDict setValue:[NSNull null] forKey:@"listing-url"];
	[listingDict setValue:[NSNull null]  forKey:@"verticals"];

	[listingDict setValue:@"restaurants" forKey:@"a:verticals"];
	[listingDict setValue:@"food-and-drink:coffee-houses" forKey:@"b:verticals"];

    [entityDict setValue:listingDict forKey:@"view.listing"];	
	[queryDict setValue:[NSArray arrayWithObject:entityDict] forKey:@"entity"];
	
	return [queryDict JSONRepresentation];
}




- (NSString	*) contructSQuery: (NSString *) searchText
{
	Mizoon *miz = [Mizoon sharedMizoon];
	
	NSMutableDictionary *queryDict = [[[NSMutableDictionary alloc] init] autorelease];
	[queryDict setValue:[NSNumber numberWithFloat:[miz getUserlat]] forKey:@"lat"];
	[queryDict setValue:[NSNumber numberWithFloat:[miz getUserlon]]  forKey:@"lon"];
	[queryDict setValue:@"1km" forKey:@"radius"];
	[queryDict setValue:[NSNumber numberWithInt:50] forKey:@"limit"];
	
	NSMutableDictionary *entityDict = [[[NSMutableDictionary alloc] init] autorelease];
    [entityDict setValue:[NSNull null] forKey:@"guid"];
	[entityDict setValue:[NSNull null] forKey:@"geom"];
	[entityDict setValue:[NSNull null] forKey:@"distance-from-origin"];
	[entityDict setValue:[NSNull null] forKey:@"distance-from-center"];
	[entityDict setValue:@"business" forKey:@"type"];
	
    NSMutableDictionary *listingDict = [[[NSMutableDictionary alloc] init] autorelease];
    [listingDict setValue:searchText forKey:@"name^="];
	[listingDict setValue:[NSNull null] forKey:@"name"];
	
    [listingDict setValue:[NSNull null] forKey:@"address"];
	[listingDict setValue:[NSNull null] forKey:@"phone"];
	[listingDict setValue:[NSNull null] forKey:@"listing-url"];
	[listingDict setValue:[NSNull null] forKey:@"verticals"];
	
    [entityDict setValue:listingDict forKey:@"view.listing"];	
	[queryDict setValue:[NSArray arrayWithObject:entityDict] forKey:@"entity"];
	
	return [queryDict JSONRepresentation];
}



- (NSString	*) queryGeoApi: (NSString *) searchText
{
	Mizoon *miz = [Mizoon sharedMizoon];
	
	NSMutableDictionary *queryDict = [[[NSMutableDictionary alloc] init] autorelease];
	[queryDict setValue:[NSNumber numberWithFloat:[miz getUserlat]] forKey:@"lat"];
	[queryDict setValue:[NSNumber numberWithFloat:[miz getUserlon]]  forKey:@"lon"];
	[queryDict setValue:@"1km" forKey:@"radius"];
	[queryDict setValue:[NSNumber numberWithInt:50] forKey:@"limit"];
	
	NSMutableDictionary *entityDict = [[[NSMutableDictionary alloc] init] autorelease];
    [entityDict setValue:[NSNull null] forKey:@"guid"];
	[entityDict setValue:[NSNull null] forKey:@"geom"];
	[entityDict setValue:[NSNull null] forKey:@"distance-from-origin"];
	[entityDict setValue:[NSNull null] forKey:@"distance-from-center"];
	[entityDict setValue:@"business" forKey:@"type"];
	
    NSMutableDictionary *listingDict = [[[NSMutableDictionary alloc] init] autorelease];
    [listingDict setValue:searchText forKey:@"name^="];
	[listingDict setValue:[NSNull null] forKey:@"name"];
	
    [listingDict setValue:[NSNull null] forKey:@"address"];
	[listingDict setValue:[NSNull null] forKey:@"phone"];
	[listingDict setValue:[NSNull null] forKey:@"listing-url"];
	[listingDict setValue:[NSNull null] forKey:@"verticals"];
	
    [entityDict setValue:listingDict forKey:@"view.listing"];	
	[queryDict setValue:[NSArray arrayWithObject:entityDict] forKey:@"entity"];
	
	return [queryDict JSONRepresentation];
}



#pragma mark GAConnectionDelegate

- (void)receivedResponseString:(NSString *)responseString 
{
	MizoonLocation	*aLoc;
	
	if (self.fetchedData) {
		[fetchedData release];
		fetchedData = nil;
	}
	
	NSDictionary *responseDict = [responseString JSONValue];
	NSArray *results = [responseDict objectForKey:@"entity"];

	if (results && [results count] > 0) {  //  places search
		self.fetchedData = [[NSMutableArray alloc] init];
		
		for (id obj in results) {
			aLoc = [MizoonLocation locationWithDict:obj];
			[self.fetchedData addObject:aLoc];
			[aLoc release];
		}	
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Data" object:(id)self];
		return;
	}
	
	results = [[responseDict objectForKey:@"result"] objectForKey:@"parents"];
	
	if (results == nil || [results count] < 1) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_NO_Data" object:(id)self];
		return;
	}
	
	self.fetchedData = [[NSMutableArray alloc] init];
	for (id obj in results) {
		[self.fetchedData addObject:obj];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Data" object:(id)self];
}




- (void)XreceivedResponseString:(NSString *)responseString 
{
	//	Mizoon *miz = [Mizoon sharedMizoon];
	MizoonLocation	*aLoc;
	
	if (self.fetchedData) {
		[fetchedData release];
		fetchedData = nil;
	}
	
	NSDictionary *responseDict = [responseString JSONValue];
	NSArray *results = [responseDict objectForKey:@"entity"];
	
	if (results == nil || [results count] < 1) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_NO_Data" object:(id)self];
		return;
	}
	

	self.fetchedData = [[NSMutableArray alloc] init];
	
	for (id obj in results) {
		aLoc = [MizoonLocation locationWithDict:obj];
		//		[self.fetchedData addObject:[MizoonLocation locationWithDict:obj]];
		[self.fetchedData addObject:aLoc];
		
		[aLoc release];
	}	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Data" object:(id)self];
}



- (void)requestFailed:(NSError *)error 
{
	NSLog(@"requestFailed...................................");
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GEOAPI_Request_Failed" object:(id)self];
	[[Mizoon sharedMizoon] hideLoadMessage ];
//
//	
//	[[Mizoon sharedMizoon] hideLoadMessage];
//	
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
//													message:@"Can't connect to server. Can you try again."
//												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//	[alert show];
//	[alert	release];
//
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Data" object:nil];	 
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Restaurant_Data" object:nil];	 
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Cafe_Data" object:nil];	 
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_NL_Data" object:nil];	 
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Shopping_Data" object:nil];	 
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Lodging_Data" object:nil];	 
//	
//	
//	[[[Mizoon sharedMizoon] getRootViewController] popView];
	
}


#pragma mark FactualImpl 

#ifdef FACTUAL
/************* FACTUAL ****************/
-(void) populateQueryDefaults { 
    [_factualObjPrefs setValue:[NSNumber numberWithInt:0 ] forKey:PREFS_FACTUAL_TABLE];
    
    [_factualObjPrefs setValue:[NSNumber numberWithBool:YES ] forKey:PREFS_GEO_ENABLED];
    [_factualObjPrefs setValue:[NSNumber numberWithBool:YES ] forKey:PREFS_TRACKING_ENABLED];
    [_factualObjPrefs setValue:[NSNumber numberWithDouble:37.416] forKey:PREFS_LATITUDE];
    [_factualObjPrefs setValue:[NSNumber numberWithDouble:-122.132] forKey:PREFS_LONGITUDE];
    [_factualObjPrefs setValue:[NSNumber numberWithDouble:5000.0] forKey:PREFS_RADIUS];
    
    [_factualObjPrefs setValue:[NSNumber numberWithBool:NO] forKey:PREFS_LOCALITY_FILTER_ENABLED];
    [_factualObjPrefs setValue:@"country" forKey:PREFS_LOCALITY_FILTER_TYPE];
    [_factualObjPrefs setValue:@"US" forKey:PREFS_LOCALITY_FILTER_TEXT];
    
    [_factualObjPrefs setValue:[NSNumber numberWithBool:NO] forKey:PREFS_CATEGORY_FILTER_ENABLED];
    [_factualObjPrefs setValue:@"Food & Beverage" forKey:PREFS_CATEGORY_FILTER_TYPE];
}




- (void) updateQueryLocation {

    if ( currentLocation != nil) { 
        [_factualObjPrefs setValue:[NSNumber numberWithDouble:currentLocation.coordinate.latitude] forKey:PREFS_LATITUDE];
        [_factualObjPrefs setValue:[NSNumber numberWithDouble:currentLocation.coordinate.longitude] forKey:PREFS_LONGITUDE];
        
    }
}


- (void) doFactualQuery { 
    
    _queryResult = nil;
    
    
    [self updateQueryLocation];
    
    FactualQuery* queryObject = [FactualQuery query];
    
    // set limit
    queryObject.limit = 50;
    
   
    // set geo location 
    CLLocationCoordinate2D coordinate = {
        [((NSNumber*)[_factualObjPrefs valueForKey:PREFS_LATITUDE]) doubleValue],
        [((NSNumber*)[_factualObjPrefs valueForKey:PREFS_LONGITUDE]) doubleValue]
    };
        
        
    // set geo filter 
    [queryObject setGeoFilter:coordinate radiusInMeters:[((NSNumber*)[_factualObjPrefs valueForKey:PREFS_RADIUS]) doubleValue]];
        
       
    // check if locality filter is on ... 
    if ([[_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_ENABLED] boolValue]) { 
        // see if locality value is present 
        NSString* localityFilterText = [_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_TEXT];
        if (localityFilterText.length != 0) { 
            [queryObject addRowFilter:[FactualRowFilter fieldName:
                                       [_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_TYPE] 
                                                          equalTo:localityFilterText]];
        }
    }
    
    // check if category filter is on ... 
    if ([[_factualObjPrefs valueForKey:PREFS_CATEGORY_FILTER_ENABLED] boolValue]) { 
        // see if locality value is present 
        NSString* categoryName = [_factualObjPrefs valueForKey:PREFS_CATEGORY_FILTER_TYPE];
        if (categoryName.length != 0) { 
            [queryObject addRowFilter:[FactualRowFilter fieldName:@"category" beginsWith:categoryName]];
        }
    }
    
    // figure out table to use ... 
    int selectedTableIndex = [[_factualObjPrefs valueForKey:PREFS_FACTUAL_TABLE] intValue];
    
    NSString* tableName = (selectedTableIndex == 0)?@"global" : @"restaurants-us";
    
    // mark start time
    _requestStartTime = [[NSDate date] timeIntervalSince1970];
    
    // start the request ... 
    _activeRequest = [[_factualObject queryTable:tableName optionalQueryParams:queryObject withDelegate:self] retain];
    
}


-(void) clearFactualReferences { 
	[_factualObjPrefs release];
    [_activeRequest release];
    [_queryResult release];

    
    _factualObjPrefs = nil;
    _activeRequest = nil;
    _queryResult= nil;
}


- (void) doFactualCafeQuery { 
    
    _queryResult = nil;
    
    
    [self updateQueryLocation];
    
    FactualQuery* queryObject = [FactualQuery query];
    
    // set limit
    queryObject.limit = 50;
    
    
#if 1
    // set geo location 
    CLLocationCoordinate2D coordinate = {
        [((NSNumber*)[_factualObjPrefs valueForKey:PREFS_LATITUDE]) doubleValue],
        [((NSNumber*)[_factualObjPrefs valueForKey:PREFS_LONGITUDE]) doubleValue]
    };
#else
    CLLocationCoordinate2D coordinate = {
        [((NSNumber*)[NSString stringWithFormat:@"%f",  37.44573]) doubleValue],
        [((NSNumber*)[NSString stringWithFormat:@"%f", -122.16145]) doubleValue]
    };
#endif
    
    // set geo filter 
//    [queryObject setGeoFilter:coordinate radiusInMeters:[((NSNumber*)[_factualObjPrefs valueForKey:PREFS_RADIUS]) doubleValue]];
    [queryObject setGeoFilter:coordinate radiusInMeters:SEARCH_RADIUS];

    
    // check if locality filter is on ... 
    if ([[_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_ENABLED] boolValue]) { 
        // see if locality value is present 
        NSString* localityFilterText = [_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_TEXT];
        if (localityFilterText.length != 0) { 
            [queryObject addRowFilter:[FactualRowFilter fieldName:
                                       [_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_TYPE] 
                                                          equalTo:localityFilterText]];
        }
    }
    
    // check if category filter is on ... 
    if ([[_factualObjPrefs valueForKey:PREFS_CATEGORY_FILTER_ENABLED] boolValue]) { 
        // see if locality value is present 
        NSString* categoryName = [_factualObjPrefs valueForKey:PREFS_CATEGORY_FILTER_TYPE];
        if (categoryName.length != 0) { 
            [queryObject addRowFilter:[FactualRowFilter fieldName:@"category" beginsWith:categoryName]];
        }
    }
    
    [queryObject addFullTextQueryTerms:@"coffee,tea, cafe", nil];

    // figure out table to use ... 
    int selectedTableIndex = [[_factualObjPrefs valueForKey:PREFS_FACTUAL_TABLE] intValue];
    
    NSString* tableName = (selectedTableIndex == 0)?@"global" : @"restaurants-us";
    
    // mark start time
    _requestStartTime = [[NSDate date] timeIntervalSince1970];
    
    // start the request ... 
    _activeRequest = [[_factualObject queryTable:tableName optionalQueryParams:queryObject withDelegate:self] retain];
    
}



- (void) doFactualRestaurantQuery { 
    
    _queryResult = nil;
    
    
    [self updateQueryLocation];
    
    FactualQuery* queryObject = [FactualQuery query];
    
    // set limit
    queryObject.limit = 50;
    
    
#if 1
    // set geo location 
    CLLocationCoordinate2D coordinate = {
        [((NSNumber*)[_factualObjPrefs valueForKey:PREFS_LATITUDE]) doubleValue],
        [((NSNumber*)[_factualObjPrefs valueForKey:PREFS_LONGITUDE]) doubleValue]
    };
#else
    CLLocationCoordinate2D coordinate = {
        [((NSNumber*)[NSString stringWithFormat:@"%f",  37.44573]) doubleValue],
        [((NSNumber*)[NSString stringWithFormat:@"%f", -122.16145]) doubleValue]
    };
#endif
    
    // set geo filter 
    //    [queryObject setGeoFilter:coordinate radiusInMeters:[((NSNumber*)[_factualObjPrefs valueForKey:PREFS_RADIUS]) doubleValue]];
    [queryObject setGeoFilter:coordinate radiusInMeters:SEARCH_RADIUS];
    
    
    // check if locality filter is on ... 
    if ([[_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_ENABLED] boolValue]) { 
        // see if locality value is present 
        NSString* localityFilterText = [_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_TEXT];
        if (localityFilterText.length != 0) { 
            [queryObject addRowFilter:[FactualRowFilter fieldName:
                                       [_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_TYPE] 
                                                          equalTo:localityFilterText]];
        }
    }
    
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"category" beginsWith:@"Food & Beverage"]];

    [queryObject addFullTextQueryTerms:@"restaurant", nil];
    
    // figure out table to use ... 
    int selectedTableIndex = [[_factualObjPrefs valueForKey:PREFS_FACTUAL_TABLE] intValue];
    
    NSString* tableName = (selectedTableIndex == 0)?@"global" : @"restaurants-us";
    
    // mark start time
    _requestStartTime = [[NSDate date] timeIntervalSince1970];
    
    // start the request ... 
    _activeRequest = [[_factualObject queryTable:tableName optionalQueryParams:queryObject withDelegate:self] retain];
    
}



- (void) doFactualNLQuery { 
    
    _queryResult = nil;
    [self updateQueryLocation];
    FactualQuery* queryObject = [FactualQuery query];
    
    // set limit
    queryObject.limit = 50;
    
    
#if 1
    // set geo location 
    CLLocationCoordinate2D coordinate = {
        [((NSNumber*)[_factualObjPrefs valueForKey:PREFS_LATITUDE]) doubleValue],
        [((NSNumber*)[_factualObjPrefs valueForKey:PREFS_LONGITUDE]) doubleValue]
    };
#else
    CLLocationCoordinate2D coordinate = {
        [((NSNumber*)[NSString stringWithFormat:@"%f",  37.44573]) doubleValue],
        [((NSNumber*)[NSString stringWithFormat:@"%f", -122.16145]) doubleValue]
    };
#endif
    
    // set geo filter 
    [queryObject setGeoFilter:coordinate radiusInMeters:SEARCH_RADIUS];
    
    
    // check if locality filter is on ... 
    if ([[_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_ENABLED] boolValue]) { 
        // see if locality value is present 
        NSString* localityFilterText = [_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_TEXT];
        if (localityFilterText.length != 0) { 
            [queryObject addRowFilter:[FactualRowFilter fieldName:
                                       [_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_TYPE] 
                                                          equalTo:localityFilterText]];
        }
    }
    
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"category" beginsWith:@"Arts, Entertainment & Nightlife"]];
    
    [queryObject addFullTextQueryTerms:@"bar,Lounges,Clubs,Movie,Theatres,Casinos,Adult Entertainment,Dance,Comedy,Jazz,Concert", nil];
    
    // figure out table to use ... 
    int selectedTableIndex = [[_factualObjPrefs valueForKey:PREFS_FACTUAL_TABLE] intValue];
    
    NSString* tableName = (selectedTableIndex == 0)?@"global" : @"restaurants-us";
    
    _requestStartTime = [[NSDate date] timeIntervalSince1970];
    _activeRequest = [[_factualObject queryTable:tableName optionalQueryParams:queryObject withDelegate:self] retain];
    
}




- (void) doFactualSearch: (NSString *) searchText { 
    
    _queryResult = nil;
    [self updateQueryLocation];
    FactualQuery* queryObject = [FactualQuery query];
    
    // set limit
    queryObject.limit = 50;
    
    
#if 1
    // set geo location 
    CLLocationCoordinate2D coordinate = {
        [((NSNumber*)[_factualObjPrefs valueForKey:PREFS_LATITUDE]) doubleValue],
        [((NSNumber*)[_factualObjPrefs valueForKey:PREFS_LONGITUDE]) doubleValue]
    };
#else
    CLLocationCoordinate2D coordinate = {
        [((NSNumber*)[NSString stringWithFormat:@"%f",  41.024641]) doubleValue],
        [((NSNumber*)[NSString stringWithFormat:@"%f", 28.973741]) doubleValue]
    };
#endif
    
    // set geo filter 
    [queryObject setGeoFilter:coordinate radiusInMeters:SEARCH_RADIUS];
    
    
    // check if locality filter is on ... 
    if ([[_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_ENABLED] boolValue]) { 
        // see if locality value is present 
        NSString* localityFilterText = [_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_TEXT];
        if (localityFilterText.length != 0) { 
            [queryObject addRowFilter:[FactualRowFilter fieldName:
                                       [_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_TYPE] 
                                                          equalTo:localityFilterText]];
        }
    }
    
//    [queryObject addRowFilter:[FactualRowFilter fieldName:@"category" beginsWith:@"Arts, Entertainment & Nightlife"]];
    
    [queryObject addFullTextQueryTerms:searchText, nil];
    
    // figure out table to use ... 
    int selectedTableIndex = [[_factualObjPrefs valueForKey:PREFS_FACTUAL_TABLE] intValue];
    
    NSString* tableName = (selectedTableIndex == 0)?@"global" : @"restaurants-us";
    
    _requestStartTime = [[NSDate date] timeIntervalSince1970];
    _activeRequest = [[_factualObject queryTable:tableName optionalQueryParams:queryObject withDelegate:self] retain];
    
}






- (void) doFactualShoppingQuery { 
    
    _queryResult = nil;
    [self updateQueryLocation];
    FactualQuery* queryObject = [FactualQuery query];
    
    // set limit
    queryObject.limit = 50;
    
    
#if 1
    // set geo location 
    CLLocationCoordinate2D coordinate = {
        [((NSNumber*)[_factualObjPrefs valueForKey:PREFS_LATITUDE]) doubleValue],
        [((NSNumber*)[_factualObjPrefs valueForKey:PREFS_LONGITUDE]) doubleValue]
    };
#else
    CLLocationCoordinate2D coordinate = {
        [((NSNumber*)[NSString stringWithFormat:@"%f",  37.44573]) doubleValue],
        [((NSNumber*)[NSString stringWithFormat:@"%f", -122.16145]) doubleValue]
    };
#endif
    
    // set geo filter 
    [queryObject setGeoFilter:coordinate radiusInMeters:SEARCH_RADIUS];
    
    
    // check if locality filter is on ... 
    if ([[_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_ENABLED] boolValue]) { 
        // see if locality value is present 
        NSString* localityFilterText = [_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_TEXT];
        if (localityFilterText.length != 0) { 
            [queryObject addRowFilter:[FactualRowFilter fieldName:
                                       [_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_TYPE] 
                                                          equalTo:localityFilterText]];
        }
    }
    
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"category" beginsWith:@"Shopping"]];
    
//    [queryObject addFullTextQueryTerms:@"bar,Lounges,Clubs,Movie,Theatres,Casinos,Adult Entertainment,Dance,Comedy,Jazz,Concert", nil];
    
    // figure out table to use ... 
    int selectedTableIndex = [[_factualObjPrefs valueForKey:PREFS_FACTUAL_TABLE] intValue];
    
    NSString* tableName = (selectedTableIndex == 0)?@"global" : @"restaurants-us";
    
    _requestStartTime = [[NSDate date] timeIntervalSince1970];
    _activeRequest = [[_factualObject queryTable:tableName optionalQueryParams:queryObject withDelegate:self] retain];
    
}

- (void) doFactualTravelQuery { 
    
    _queryResult = nil;
    [self updateQueryLocation];
    FactualQuery* queryObject = [FactualQuery query];
    
    // set limit
    queryObject.limit = 50;
    
    
#if 1
    // set geo location 
    CLLocationCoordinate2D coordinate = {
        [((NSNumber*)[_factualObjPrefs valueForKey:PREFS_LATITUDE]) doubleValue],
        [((NSNumber*)[_factualObjPrefs valueForKey:PREFS_LONGITUDE]) doubleValue]
    };
#else
    CLLocationCoordinate2D coordinate = {
        [((NSNumber*)[NSString stringWithFormat:@"%f",  37.44573]) doubleValue],
        [((NSNumber*)[NSString stringWithFormat:@"%f", -122.16145]) doubleValue]
    };
#endif
    
    // set geo filter 
    [queryObject setGeoFilter:coordinate radiusInMeters:SEARCH_RADIUS];
    
    
    // check if locality filter is on ... 
    if ([[_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_ENABLED] boolValue]) { 
        // see if locality value is present 
        NSString* localityFilterText = [_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_TEXT];
        if (localityFilterText.length != 0) { 
            [queryObject addRowFilter:[FactualRowFilter fieldName:
                                       [_factualObjPrefs valueForKey:PREFS_LOCALITY_FILTER_TYPE] 
                                                          equalTo:localityFilterText]];
        }
    }
    
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"category" beginsWith:@"Travel & Tourism"]];
    
    //    [queryObject addFullTextQueryTerms:@"bar,Lounges,Clubs,Movie,Theatres,Casinos,Adult Entertainment,Dance,Comedy,Jazz,Concert", nil];
    
    // figure out table to use ... 
    int selectedTableIndex = [[_factualObjPrefs valueForKey:PREFS_FACTUAL_TABLE] intValue];
    
    NSString* tableName = (selectedTableIndex == 0)?@"global" : @"restaurants-us";
    
    _requestStartTime = [[NSDate date] timeIntervalSince1970];
    _activeRequest = [[_factualObject queryTable:tableName optionalQueryParams:queryObject withDelegate:self] retain];
    
}





#pragma mark -
#pragma mark FactualAPIDelegate methods

- (void)requestDidReceiveInitialResponse:(FactualAPIRequest *)request {
    if (request == _activeRequest) {
//        MizoonLog(@"Recvd Response...");
    }
    
}

- (void)requestDidReceiveData:(FactualAPIRequest *)request { 
    if (request == _activeRequest) {
//        MizoonLog(@"Recvd Data...");
    }  
}


-(void) requestComplete:(FactualAPIRequest *)request failedWithError:(NSError *)error {
    if (_activeRequest == request) {
        [_activeRequest release];
        _activeRequest = nil;
        MizoonLog(@"Active request failed with Error:%@", [error localizedDescription]);
    }
}


-(void) requestComplete:(FactualAPIRequest *)request receivedQueryResult:(FactualQueryResult *)queryResultObj {
    
    if (_activeRequest == request) {
//        MizoonLog(@"Active request Completed with row count:%d TableId:%@ RequestTableId:%@", [_queryResult rowCount], _queryResult.tableId,request.tableId);
        
        // get time now ... 
        NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
        // figure out delta 
        NSTimeInterval delta = timeNow - _requestStartTime;
   
        MizoonLog(@"Request completed in: %.3f(s) Rows:%d/%d",delta,[queryResultObj rowCount],(int)[queryResultObj totalRows]);

        _queryResult = queryResultObj;  
        [_activeRequest release];
        _activeRequest = nil;
        
//        MizoonLog(@"Number of rows = %d", _queryResult.rowCount);
        
        
        MizoonLocation	*aLoc;
        
        if (self.fetchedData) {
            [fetchedData release];
            fetchedData = nil;
        }
        
        if ( _queryResult.rowCount ) {  
        
            self.fetchedData = [[NSMutableArray alloc] init];
        

            for (int i=0; i< _queryResult.rowCount; i++) {
                FactualRow* row = [_queryResult.rows objectAtIndex:i];

//                MizoonLog(@" %@", [row valueForName:@"name"]);
                
                aLoc = [MizoonLocation locationFromFactualObj:row ];

                [self.fetchedData addObject:aLoc];
                [aLoc release];
            }	            
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Data" object:(id)self];

    }
}

#endif

/************* END FACTUAL ****************/






@end
