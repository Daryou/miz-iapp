//
//  Mizoon.m
//  Mizoon
//
//  Created by Daryoush Paknad on 5/28/10.MizoonLog
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Mizoon.h"
#import	"MizDataManager.h"
#import	"MizoonUser.h"
#import	"LocationController.h"
#import "TwtOAuthEngine.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <CommonCrypto/CommonDigest.h>
#import	"Reachability.h"

@interface  Mizoon (Private)
- (void) initFacebook;
- (void) resetFB;
- (void) updateInterfaceWithReachability: (Reachability*) curReach;
- (void) reachabilityChanged: (NSNotification* )note;
@end

@implementation Mizoon
@synthesize	sPromoLid, sPromoRow, sPromoDict,redeemedCP, sPerson, sLocationNum, sLocation, fbSession, lastSelectedLid, selectedPost, twtOAuthEngine;
@synthesize	locSearchRes,operationQueue, tmpCheckin,networkConnection, clickedView,methodStart;

//#ifdef MIZOON_DEBUG
//@synthesize	methodStart;
//#endif

static Mizoon *sharedMizoon ;



// Initialize the singleton instance if needed and return
+ (Mizoon *)sharedMizoon {
    {
        if (!sharedMizoon)
            sharedMizoon = [[Mizoon alloc] init];
		
        return sharedMizoon;
    }
}



- (id)init {
    self = [super init];
//	Mizoon *mizoon = [Mizoon sharedMizoon];
	
	networkConnection = YES;
	
	// mizoon.com
//	mizoon.fbSession = [FBSession sessionForApplication:@"980847a60e6860599b46fe1e0c3fd727" secret:@"1c8faabd82313b46ddcbff9da982d938" delegate:self];
	
	// http://76.21.5.31/
//	mizoon.fbSession = [FBSession sessionForApplication:@"e831844e59eacb13748d86d52d6951cf" secret:@"33cdbaf0bb06f4b3b1a3645f432b5f40" delegate:self];

//	fbLoginButton.style = FBLoginButtonStyleWide;
//	[fbSession resume];
	
	
	
	[self initFacebook];

//	fbSession = [[Facebook alloc] initWithAppId:@"82156015133"];
//	NSArray *permissions = [[NSArray arrayWithObjects: @"publish_stream", @"offline_access", @"read_stream", nil] retain];
//	[fbSession authorize:permissions  delegate:self];
		

    

	
//    [fbSession requestWithGraphPath:@"/me/feed"   // or use page ID instead of 'me'
//                          andParams:params
//                      andHttpMethod:@"POST"
//                        andDelegate:self];
	
	
	[self initTwitter];
	
	NSOperationQueue * theQueue = [[NSOperationQueue alloc] init];
	self.operationQueue = theQueue;
	[theQueue release];
	
	// Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	
    //Change the host name here to change the server your monitoring
//	hostReach = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
//	[hostReach startNotifier];
//	[self updateInterfaceWithReachability: hostReach];
	
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[internetReach startNotifier];
	[self updateInterfaceWithReachability: internetReach];
	
//    wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
//	[wifiReach startNotifier];
//	[self updateInterfaceWithReachability: wifiReach];
	
//	coreMapView = [[MKMapView alloc] initWithFrame: CGRectMake(-100, -25, 2.0, 4.6)];//  self.view.bounds];
//	coreMapView.delegate = self;
//	coreMapView.showsUserLocation = YES;
//	coreMapView.zoomEnabled = YES;
//	[[self getRootViewController].view insertSubview:coreMapView atIndex:0];

    return self;
}



- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	MizoonLog(@"--MKMapView - LOC COORD lat=%f lon=%f Accu=%f", coreMapView.userLocation.location.coordinate.latitude,
		  coreMapView.userLocation.location.coordinate.longitude, coreMapView.userLocation.location.horizontalAccuracy);
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Have_Location_Coord" object:(id)self];
//	[MizDataManager sharedDataManager].currentLocation = coreMapView.userLocation.location;

}


//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
}



- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
    BOOL connectionRequired= [curReach connectionRequired];
    NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString = @"Access Not Available";
			networkConnection = NO;
            break;
        }
            
        case ReachableViaWWAN:
        {
            statusString = @"Reachable WWAN";
			networkConnection = YES;
            break;
        }
        case ReachableViaWiFi:
        {
			statusString= @"Reachable WiFi";
			networkConnection = YES;
            break;
		}
    }
    if(connectionRequired)
    {
        statusString= [NSString stringWithFormat: @"%@, Connection Required", statusString];
		networkConnection = NO;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Required" message:@"Please check yor network connection." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[[Mizoon sharedMizoon] hideLoadMessage ];

    }
	MizoonLog(@"**************************************************** %@", statusString);
}


- (void)dealloc {
    [super dealloc];
}


+ (id)alloc {
	//	@synchronized(self)
    {
        NSAssert(sharedMizoon == nil, @"Attempted to allocate a second instance of a singleton.");
        sharedMizoon = [super alloc];
        return sharedMizoon;
    }
}

+ (id)copy {
	//	@synchronized(self)
    {
        NSAssert(sharedMizoon == nil, @"Attempted to copy the singleton.");
        return sharedMizoon;
    }
}



+ (Mizoon *)sharedMizooner {
    if (!sharedMizoon) {
        sharedMizoon = [[Mizoon alloc] init];
    }
	
    return sharedMizoon;
}


#pragma mark helper


/*
 * Piggy backs on the iphone_stats table which includes the following fields: 
 * uuid, app_version, language, os_version, sys_name and name
 * uuid is set to the module name (e,g, facebook)
 * app_version to "username"
 * language=en_US
 * os_version=4.2
 * sys_name to an error number
 * name to the description of the error
 */
- (void) postError: (NSString *) name withErrNum:(NSString *) errNum andErrDesc: (NSString *) errDesc
{
	NSDate *theDate = [NSDate date];
	NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
//	[dateFormat setDateStyle:NSDateFormatterShortStyle];

	[dateFormat setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"];

	NSString *dateString = [dateFormat stringFromDate:theDate];
	MizoonLog(@"Date: %@", dateString);
	
	NSString *mizoonStatUrl = [[NSString alloc] initWithFormat:@"%@/?q=iphone_stats", MIZOON_HOST];
	
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:mizoonStatUrl]
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:30.0];
	
	[theRequest setHTTPMethod:@"POST"];
	[theRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
	//create the body
	NSMutableData *postBody = [NSMutableData data];
	
	NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
	NSString *user = [userData stringForKey:kUsername];

	
	
	[postBody appendData:[[NSString stringWithFormat:@"device_uuid=%@&app_version=%@&language=%@&os_version=%@&sys_name=%@&name=%@", 
						   name,
						   user,
						   @"en_US",
						   @"4.2",
						   errNum,
						   errDesc] dataUsingEncoding:NSUTF8StringEncoding]];

	
	
#ifdef MIZOON_DEBUG	
	NSString *htmlStr = [[[NSString alloc] initWithData:postBody encoding:NSUTF8StringEncoding] autorelease];
	MizoonLog(@"htmlStr- %@", htmlStr);
#endif
	[theRequest setHTTPBody:postBody];
	
	NSURLConnection *conn=[[[NSURLConnection alloc] initWithRequest:theRequest delegate:self]autorelease];
	
	if (conn)  {  
		MizoonLog(@"Request was scheduled to post");
	}   
	else {  
		MizoonLog(@"Failed to create a connection!");
	}  	
	
	[mizoonStatUrl release];
}



- (void) networkConnectionAlert
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"Please check your phone network connection" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[[Mizoon sharedMizoon] hideLoadMessage ];
}

- (BOOL) hasNetworkConnection
{
	return networkConnection;
}


- (NSString *) getApplicationKey
{
	NSMutableString* key = [NSMutableString string]; 

//	[key appendString: [MizDataManager sharedDataManager].sessionId];
	[key appendString:[self getUserName]];
	[key appendString: MIZOON_APP_SECRET];

	return [self md5HexDigest:key];
}

- (NSString*)md5HexDigest:(NSString*)input {
	const char* str = [input UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, strlen(str), result);
	
	NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
	for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
		[ret appendFormat:@"%02x",result[i]];
	}
	return ret;
}


- (void) showLoadMessage: (NSString *) message 
{
	RootViewController *rvc = [self getRootViewController];

	[rvc renderLoadMessage:message];
}

- (void) hideLoadMessage 
{
	RootViewController *rvc = [self getRootViewController];
	
	[rvc hideLoadMessage];
}

- (RootViewController *) getRootViewController {
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	return  delegate.rootViewController;
}


- (void) updateLocation
{	
//	dm.currentLocation = nil;
	MizoonLog(@"----------updateLocation MapKit user loc.lat=%f lon=%f", coreMapView.userLocation.location.coordinate.latitude, coreMapView.userLocation.location.coordinate.longitude);

	[[self getRootViewController].locationController getLocation];
}
	
- (BOOL) needToFetchData: (MizoonDataTypes) dataType 
{
	MizDataManager *md = [MizDataManager sharedDataManager];
	NSTimeInterval locationAge = -[md.currentLocation.timestamp timeIntervalSinceNow];

//	MizoonLog(@"needToFetch - currentLocationAge=%f lastfetched=%f", locationAge, [md.placesLastFetch timeIntervalSinceNow]);
	
	switch (dataType) {
		case PlacesData:
			if ( !md.placesList || (locationAge > ([md.placesLastFetch timeIntervalSinceNow] + 180)) )   // assume that the user will not travel far in 3 minutes
				return YES;
			return NO;
			
		case NearbyPeopleData:
			if ( !md.nearbyPeopleSize || (locationAge >  ([md.peopleLastFetch timeIntervalSinceNow] + 180)) )   // assume that the user will not travel far in 3 minutes
				return YES;
			return NO;
			
		case LocationsWithPromoData:
			if ( !md.locationsWithPromos || (locationAge > ([md.promosLastFetch timeIntervalSinceNow] + 180)) )   // assume that the user will not travel far in 3 minutes
				return YES;
			return NO;
									
		case NearbySalesData:
			if ( !md.promotions || (locationAge > ([md.placesLastFetch timeIntervalSinceNow]+ 180)) )   // assume that the user will not travel far in 3 minutes
				return YES;
			return NO;
						
		case NearbyPostsData:
			if ( !md.nearbyPosts || (locationAge > ([md.postsLastFetch timeIntervalSinceNow] + 180)) )   // assume that the user will not travel far in 3 minutes
				return YES;
			return NO;
						
		case NearbyCafeData:
			if ( !md.cafeList || (locationAge > ([md.cafesLastFetch timeIntervalSinceNow]+ 180)) )   // assume that the user will not travel far in 3 minutes
				return YES;
			return NO;			
			
		case NearbyRestaurantData:
			if ( !md.restaurantList || (locationAge > ([md.restaurantsLastFetch timeIntervalSinceNow]+ 180)) )   // assume that the user will not travel far in 3 minutes
				return YES;
			return NO;		
			
		case NearbyNLData:
			if ( !md.nightLifeList || (locationAge > ([md.nightLastFetch timeIntervalSinceNow] + 180)))   // assume that the user will not travel far in 3 minutes
				return YES;
			return NO;		
			
		case NearbyShoppingData:
			if ( !md.shoppingList || (locationAge > ([md.shopsLastFetch timeIntervalSinceNow] + 180)))   // assume that the user will not travel far in 3 minutes
				return YES;
			return NO;		

		case NearbyLodgingData:
			if ( !md.lodgingList || (locationAge > ([md.lodgeLastFetch timeIntervalSinceNow] + 180)) )   // assume that the user will not travel far in 3 minutes
				return YES;
			return NO;					
			
		default:
			break;
	}
	
	return YES;
}

#pragma mark User 

- (void) setMizoonerPoints: (NSUInteger) points 
{
	NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
	MizoonUser *user = [MizoonUser sharedMizooner];

	MizoonLog(@"setMizoonerPoints - total points=%d", points);
	
	user.points = points;
	[userData setInteger:points forKey:kUserPoints];
}
	

- (NSUInteger) getMizoonerPoints
{
	MizoonUser *user = [MizoonUser sharedMizooner];
	
	return user.points;
}



- (BOOL) isUserFBAuthenticated {
	MizDataManager *md = [MizDataManager sharedDataManager];
	Mizoon *miz = [Mizoon sharedMizoon];
	
//	if (md.isFBAuthenticatedUser && miz.fbSession && [miz.fbSession isConnected]) {
	if (md.isFBAuthenticatedUser && miz.fbSession ) {
		return YES;
	}
	return NO;
}


- (NSString *) getUserName 
{
	NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
	return[userData stringForKey:kUsername];
}


- (NSString *) getUserPassword
{
	MizDataManager *md = [MizDataManager sharedDataManager];
	NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:kUsername];
	return [md getMizPasswordFromKeychainWithUsername: user];
}


- (float) getUserlat 
{
	return [MizDataManager sharedDataManager].currentLocation.coordinate.latitude;
}


- (float) getUserlon 
{
	return [MizDataManager sharedDataManager].currentLocation.coordinate.longitude;
}


- (void) setSelectedPerson: (NSUInteger) row {
			
	sPerson = row;
	NSDictionary *personDict = [self getSelectedPersonDict];
	
	if (!personDict) 
		return;

	if (sPersonProfile)			//when APersonViewController is switched, the profile object is freed   XXXX
		[sPersonProfile release];			//XXXX
		
	sPersonProfile = [[MizoonerProfiles alloc] initWithDictionary:personDict];	
}


- (void) setSelectedVisitor: (NSUInteger) row {
	
	sPerson = row;
	NSMutableArray *visitors = [self getVisitors];
	
	if (!visitors) 
		return;
	
	Mizooner *visitor = [visitors objectAtIndex:row];
	MizoonerProfiles *profiles = visitor.profile;
	
	sPersonProfile = [profiles retain];	
}





- (void) setSelectedPersonFromDict: (NSDictionary *) personDict {
		
	if (!personDict) 
		return;
		
	if (sPersonProfile) 
		[sPersonProfile release];
	
	sPersonProfile = [[MizoonerProfiles alloc] initWithDictionary:personDict];	
}


- (NSDictionary *) getSelectedPersonDict {
	
	MizDataManager	*md = [MizDataManager sharedDataManager];
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *rvc = delegate.rootViewController;
	NSArray *people;
	
	if ([rvc isInViewStack:CHECKED_IN_VIEW]) {
		people = md.locationPeople;
	} else {
		people = md.nearbyPeople;
	}
		 
//	if (rvc.prevView == CHECKED_IN_VIEW) {
//		people = md.locationPeople;
//	} else {
//		people = md.nearbyPeople;
//	}

	if (!people)
		return NULL;
	
	return [people	objectAtIndex:self.sPerson];
}


- (MizoonerProfiles *) getSelectedPersonProfile
{
	return sPersonProfile;
}


- (NSString *) getSelectedPersonUName {
	
	if ( sPersonProfile ) 
		return	[sPersonProfile  getProfileAttrValue: PERSON_USER_NAME];
	
	return NULL;
}



- (NSString *) getSelectedPersonUID {
	
	if ( sPersonProfile ) 
		return	[sPersonProfile  getProfileAttrValue: PERSON_UID];
	
	return NULL;
}


#pragma mark Promotions 



- (BOOL) isCoupon: (NSDictionary *) thePromo {
	
	if ([[thePromo valueForKey:@"type"] isEqualToString:@"promo"]) 
		return FALSE;
	return TRUE;
}

- (NSDictionary *) getSelectedPromo {
	return self.sPromoDict; 
}


#pragma mark Posts 

- (NSArray *) getPosts
{
	MizDataManager *dm = [MizDataManager sharedDataManager];

	return dm.nearbyPosts;                                                                               
}



- (NSDictionary *) getSelectedPost 
{
	return (NSDictionary *)[[self getPosts] objectAtIndex: self.selectedPost];                                              
}



#pragma mark Location


- (NSMutableArray *) getVisitors
{
	MizDataManager *md = [MizDataManager sharedDataManager];
	
	return md.visitorList;
}


- (NSInteger) getNumberOfVisitors
{
	return [[MizDataManager sharedDataManager].visitorList count];
}


- (NSMutableArray *) nearbyLocations
{
	MizDataManager *md = [MizDataManager sharedDataManager];
	
	return md.placesList;
}


- (NSMutableArray *) nearbyCafes 
{
	MizDataManager *md = [MizDataManager sharedDataManager];
	
	return md.cafeList;
}


- (NSMutableArray *) nearbyRestaurnats
{
	MizDataManager *md = [MizDataManager sharedDataManager];
	
	return md.restaurantList;
}


- (NSMutableArray *) nearbyNightLife
{
	MizDataManager *md = [MizDataManager sharedDataManager];
	
	return md.nightLifeList;
}

- (NSMutableArray *) nearbyShopping 
{
	MizDataManager *md = [MizDataManager sharedDataManager];
	
	return md.shoppingList;
}

- (NSMutableArray *) nearbyLodging
{
	MizDataManager *md = [MizDataManager sharedDataManager];
	
	return md.lodgingList;
}


- (void) setSelectedLocation:(NSDictionary *) locationDict {
	
	if (self.sLocation) {
//		MizoonLog(@"1111 retain count for selectedLocations is %lx", [self.sLocation retainCount]);
		
		[self.sLocation release];
	}
	
	self.sLocation = [[MizoonLocation alloc] initLocation:locationDict];
//	MizoonLog(@"333 retain count for selectedLocations is %lx", [self.sLocation retainCount]);
}


- (void) setSelectedLocationAtRow: (NSUInteger) row {
	MizDataManager *dm = [MizDataManager sharedDataManager];
#ifdef GET_DATA_FROM_MIZOON	
	NSDictionary *placesDict = (NSDictionary *)[dm.nearbyPlaces objectAtIndex:row];

	
	if (self.sLocation) {
		//		MizoonLog(@"1- ========================sLocation ref count=%d", [sLocation retainCount]);
		self.sLocation = nil;
		//		MizoonLog(@"2- ========================sLocation ref count=%d", [sLocation retainCount]);
		
		//		[self.sLocation release];
	}
	
	self.sLocation = [[MizoonLocation alloc] initLocation:placesDict];
#else
	if (self.sLocation) 
		self.sLocation = nil;
	
	self.sLocation = [dm.placesList objectAtIndex:row];
#endif
}


- (void) setSelectedLocationFromArray: (NSArray *) locations atIndex: (NSUInteger) row {	
	self.sLocation = [[locations objectAtIndex:row] retain];
}


- (MizoonLocation *) getSelectedLocation {
	return sLocation;
}

- (MizoonLocation *) getNthLocation: (NSUInteger) row 
{
#ifdef GET_DATA_FROM_MIZOON	
	MizDataManager *dm = [MizDataManager sharedDataManager];
	
	NSDictionary *locationDict = (NSDictionary *)[dm.nearbyPlaces objectAtIndex:row];
	
	return [[MizoonLocation alloc] initLocation:locationDict];
#else
	return [[self nearbyLocations] objectAtIndex:row];
#endif
}


- (void) checkinSelectedLocation {
	MizDataManager *md = [MizDataManager sharedDataManager];
	
	[md checkinMizoonLoc: [self getSelectedLocation]];
}


- (void) checkinWithMessage: (NSString *) message {
	
	MizDataManager *md = [MizDataManager sharedDataManager];
	
	[md checkinLocaton: [self getSelectedLocation] withMessage: message];
}


- (void) temporaryCheckin 
{
	MizDataManager *md = [MizDataManager sharedDataManager];

	tmpCheckin = TRUE;
	
	// invalidate the location people; it is used in the checkedinView controller to render visitors
	md.locationPeopleSize = 0;
//	[md.locationPeople release];
	md.locationPeople = nil;
}


- (void) resetTmpCheckin {
	tmpCheckin = FALSE;
}


- (BOOL) isTemporaryCheckedin {
	return tmpCheckin;
}


- (NSString *) getIconForLoction: (NSString *) name catrgory: (NSString *) type subType: (NSString *) subType 
{
	int i, j, size, typesSize;
	NSString *types, *typeItem;
	NSArray *typesArray;
	
	NSArray *categoryList = [NSArray arrayWithObjects: _COFFEE, _RESTAURANT, _BAR, _TRAVEL, _PARK, _ARCH, _ART,
							 _EDUCATION, _MOVE, _ENTERTAINMENT, _PHARMACY, _HEALTH, _HOTEL, _PET, _SHOPPING, _SPORTS, _AIRPORT, _PARKING,
							 _POST_OFFICE, _TRAIN, _STADIUM, _APRTMENTS, _ZOO, _BANK,_COVENTION_CENTER, _RELIGIOUS_CENTER,
							 _PARTY, _SERVICE, _AUTOMOTIVE, _SCISSORS, nil];
	
	size = [categoryList count];

	for ( i=0; i < size; i++ ) {
		types = (NSString *) [categoryList objectAtIndex:i];
		typesArray = [types componentsSeparatedByString:@"-"];
		
		typesSize = [typesArray count];
		
		for ( j=0; j < typesSize-1; j++ ) {   // the last item in the array is the icon name
			
			typeItem = (NSString *) [typesArray objectAtIndex:j];
		
			if	( [name rangeOfString:typeItem options:NSCaseInsensitiveSearch].length != 0 ) 
				return (NSString *) [typesArray objectAtIndex:typesSize-1];

			if	( [subType rangeOfString:typeItem options:NSCaseInsensitiveSearch].length != 0 ) 
				return (NSString *) [typesArray objectAtIndex:typesSize-1];

			if	( [type rangeOfString:typeItem options:NSCaseInsensitiveSearch].length != 0 ) 
				return (NSString *) [typesArray objectAtIndex:typesSize-1];
			

//			
//			if	(([name rangeOfString:typeItem options:NSCaseInsensitiveSearch].length != 0) || 
//				 ([subType rangeOfString:typeItem options:NSCaseInsensitiveSearch].length != 0) ||
//				 ([type rangeOfString:typeItem options:NSCaseInsensitiveSearch].length != 0) )
//			
//				return (NSString *) [typesArray objectAtIndex:typesSize-1];
		}
	}
	return @"services.png";
}

//
////- (UIImage *) getImageForLocCatrgory: (NSString *) type subType: (NSString *) subType {
//- (UIImage *) getImageForLoction: (NSString *) name catrgory: (NSString *) type subType: (NSString *) subType 
//{
//	DebugLog(@"getImageForLoction - %@ category=%@ sub=%@", name, type, subType);
//	
//	if	(([name rangeOfString:PHARMACY_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"pharmacy-icon.png"];
//	if	(([type rangeOfString:PHARMACY_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"pharmacy-icon.png"];
//	if	(([subType rangeOfString:PHARMACY_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"pharmacy-icon.png"];
//	
//	
//	if	(([name rangeOfString:EDUCATION_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:SCHOOL_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:UNIVERSITY_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:COLLAGE_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"education-icon.png"];
//	if	(([type rangeOfString:EDUCATION_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:SCHOOL_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:UNIVERSITY_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:COLLAGE_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"education-icon.png"];
//	if	(([subType rangeOfString:EDUCATION_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:SCHOOL_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:UNIVERSITY_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:COLLAGE_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"education-icon.png"];
//	
//
//	if	(([name rangeOfString:HEALTH_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:HOSPITAL_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:NURSE_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:DOCTOR_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:CLINIC_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"health-icon.png"];
//	if	(([type rangeOfString:HEALTH_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:HOSPITAL_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:NURSE_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:DOCTOR_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:CLINIC_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"health-icon.png"];
//	if	(([subType rangeOfString:HEALTH_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:HOSPITAL_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:NURSE_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:DOCTOR_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:CLINIC_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"health-icon.png"];
//	
//	
//	// NEED ICON
//	if	(([name rangeOfString:SERVICES_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"services-icon.png"];
//	if	(([type rangeOfString:SERVICES_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"services-icon.png"];
//	if	(([subType rangeOfString:SERVICES_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"services-icon.png"];
//	
//	
//	if	(([name rangeOfString:AIRPORT_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"airport-icon.png"];
//	if	(([type rangeOfString:AIRPORT_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"airport-icon.png"];
//	if	(([subType rangeOfString:AIRPORT_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"airport-icon.png"];
//	
//	
//	
//	if	(([name rangeOfString:PARKING_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"parking-icon.png"];
//	if	(([type rangeOfString:PARKING_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"parking-icon.png"];
//	if	(([subType rangeOfString:PARKING_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"parking-icon.png"];
//	
//	
//	if	(([name rangeOfString:POST_OFFICE_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"post-office-icon.png"];
//	if	(([type rangeOfString:POST_OFFICE_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"post-office-icon.png"];
//	if	(([subType rangeOfString:POST_OFFICE_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"post-office-icon.png"];
//	
//	if	(([name rangeOfString:THEATER_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"movie-icon.png"];
//	if	(([type rangeOfString:THEATER_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"movie-icon.png"];
//	if	(([subType rangeOfString:THEATER_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"movie-icon.png"];
//		
//	if	(([name rangeOfString:ENTERTAINMENT_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"entertainment-icon.png"];
//	if	(([type rangeOfString:ENTERTAINMENT_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"entertainment-icon.png"];
//	if	(([subType rangeOfString:ENTERTAINMENT_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"entertainment-icon.png"];
//	
//	  
//	if	(([name rangeOfString:TRAIN_STATION_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"train-station-icon.png"];
//	if	(([type rangeOfString:TRAIN_STATION_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"train-station-icon.png"];
//	if	(([subType rangeOfString:TRAIN_STATION_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"train-station-icon.png"];
//	
//	
//	if	(([name rangeOfString:STADIUM_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"stadium-icon.png"];
//	if	(([type rangeOfString:STADIUM_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"stadium-icon.png"];
//	if	(([subType rangeOfString:STADIUM_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"stadium-icon.png"];
//	
//	
//	if	(([name rangeOfString:ZOO_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"zoo-icon.png"];
//	if	(([type rangeOfString:ZOO_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"zoo-icon.png"];
//	if	(([subType rangeOfString:ZOO_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"zoo-icon.png"];
//	
//	if	(([name rangeOfString:BANK_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"bank-icon.png"];
//	if	(([type rangeOfString:BANK_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"bank-icon.png"];
//	if	(([subType rangeOfString:BANK_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"bank-icon.png"];
//	
//	
//	if	(([name rangeOfString:COVENTION_CENTER_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"conv-center-icon.png"];
//	if	(([type rangeOfString:COVENTION_CENTER_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"conv-center-icon.png"];
//	if	(([subType rangeOfString:COVENTION_CENTER_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"conv-center-icon.png"];
//	
//	
//	if	(([name rangeOfString:RELIGIOUS_CENTER_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"religious-icon.png"];
//	if	(([type rangeOfString:RELIGIOUS_CENTER_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"religious-icon.png"];
//	if	(([subType rangeOfString:RELIGIOUS_CENTER_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"religious-icon.png"];
//
//	
//	if	(([name rangeOfString:RESTAURANT_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:CATERING_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:EATERY_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:FOOD_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"food-icon.png"];
//	if	(([type rangeOfString:RESTAURANT_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:CATERING_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:EATERY_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:FOOD_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"food-icon.png"];	
//	if	(([subType rangeOfString:RESTAURANT_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:CATERING_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:EATERY_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:FOOD_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"food-icon.png"];
//	
//	
//	
//	if	(([name rangeOfString:COFFEE_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:CAFE_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"coffee-icon.png"];
//	if	(([type rangeOfString:COFFEE_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:CAFE_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"coffee-icon.png"];
//	if	(([subType rangeOfString:COFFEE_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:CAFE_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"coffee-icon.png"];
//	
//	if	(([name rangeOfString:TRAVEL_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"travel-icon.png"];
//	if	(([type rangeOfString:TRAVEL_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"travel-icon.png"];
//	if	(([subType rangeOfString:TRAVEL_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"travel-icon.png"];
//	
//	if	(([name rangeOfString:PARK_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"parks-icon.png"];
//	if	(([type rangeOfString:PARK_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"parks-icon.png"];
//	if	(([subType rangeOfString:PARK_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"parks-icon.png"];
//	
//	if	(([name rangeOfString:ARCH_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"architecture-icon.png"];
//	if	(([type rangeOfString:ARCH_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"architecture-icon.png"];
//	if	(([subType rangeOfString:ARCH_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"architecture-icon.png"];
//	
//
//	if	(([name rangeOfString:SHOPPING_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"shopping-icon.png"];
//	if	(([type rangeOfString:SHOPPING_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"shopping-icon.png"];
//	if	(([subType rangeOfString:SHOPPING_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"shopping-icon.png"];
//	
//	
//	if	(([name rangeOfString:APARTMENTS_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:CONDO_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:REALESTATE_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"office-icon.png"];
//	if	(([type rangeOfString:APARTMENTS_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:CONDO_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:REALESTATE_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"office-icon.png"];
//	if	(([subType rangeOfString:APARTMENTS_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:CONDO_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:REALESTATE_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"office-icon.png"];	
//	
//	// NEED ICON
//	if	(([name rangeOfString:HOTELS_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:MOTEL_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:INN_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"hotel-icon.png"];
//	if	(([type rangeOfString:HOTELS_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:MOTEL_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:INN_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"hotel-icon.png"];
//	if	(([subType rangeOfString:HOTELS_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:MOTEL_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:INN_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"hotel-icon.png"];	
//		
//	
////	if	(([name rangeOfString:ENTERTAINMENT_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
////		 ([name rangeOfString:MOVIE_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
////		 ([name rangeOfString:THEATER_TYPE options:NSCaseInsensitiveSearch].length != 0) )
////		return [UIImage imageNamed:@"entertainment-icon.png"];
////	if	(([type rangeOfString:ENTERTAINMENT_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
////		 ([type rangeOfString:MOVIE_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
////		 ([type rangeOfString:THEATER_TYPE options:NSCaseInsensitiveSearch].length != 0) )
////		return [UIImage imageNamed:@"entertainment-icon.png"];
////	if	(([subType rangeOfString:ENTERTAINMENT_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
////		 ([subType rangeOfString:MOVIE_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
////		 ([subType rangeOfString:THEATER_TYPE options:NSCaseInsensitiveSearch].length != 0) )
////		return [UIImage imageNamed:@"entertainment-icon.png"];
////	
//	if	(([name rangeOfString:EDUCATION_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:SCHOOL_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:UNIVERSITY_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:COLLAGE_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"education-icon.png"];
//	if	(([type rangeOfString:EDUCATION_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:SCHOOL_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:UNIVERSITY_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:COLLAGE_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"education-icon.png"];
//	if	(([subType rangeOfString:EDUCATION_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:SCHOOL_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:UNIVERSITY_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:COLLAGE_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"education-icon.png"];
//	
//	// NEED ICON
//	if	(([name rangeOfString:PET_STORE_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"zoo-icon.png"];
//	if	(([type rangeOfString:PET_STORE_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"zoo-icon.png"];
//	if	(([subType rangeOfString:PET_STORE_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"zoo-icon.png"];
//
//	if	(([name rangeOfString:BAR_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([name rangeOfString:PUB_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"nightlife-icon.png"];
//	if	(([type rangeOfString:BAR_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([type rangeOfString:PUB_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"nightlife-icon.png"];
//	if	(([subType rangeOfString:BAR_TYPE options:NSCaseInsensitiveSearch].length != 0) ||
//		 ([subType rangeOfString:PUB_TYPE options:NSCaseInsensitiveSearch].length != 0) )
//		return [UIImage imageNamed:@"nightlife-icon.png"];
//	
//	if	(([name rangeOfString:ART_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"xarts-icon.png"];
//	if	(([type rangeOfString:ART_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"xarts-icon.png"];
//	if	(([subType rangeOfString:ART_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"xarts-icon.png"];
//	
//	if	(([name rangeOfString:PARTY_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"nightlife-icon.png"];
//	if	(([type rangeOfString:PARTY_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"nightlife-icon.png"];
//	if	(([subType rangeOfString:PARTY_TYPE options:NSCaseInsensitiveSearch].length != 0))
//		return [UIImage imageNamed:@"nightlife-icon.png"];
//	
//	
//	
//	return [UIImage imageNamed:@"services-icon.png"];
//}
//



#pragma mark FBConnect helpers

- (void) initFacebook
{
	fbSession = [[Facebook alloc] initWithAppId:FB_APP_ID];
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	fbSession.accessToken = [prefs objectForKey:FB_ACCESS_TOKEN_KEY];
	fbSession.expirationDate = [prefs objectForKey:FB_EXPIRATION_DATE_KEY];
	
	if ([fbSession isSessionValid] == NO) {
		[MizDataManager sharedDataManager].isFBAuthenticatedUser = FALSE;
	} else {
		[MizDataManager sharedDataManager].isFBAuthenticatedUser = TRUE;
	}
}

- (void) mizFBLogin
{
	if (!fbSession) 
		fbSession = [[Facebook alloc] initWithAppId:FB_APP_ID];

	NSArray *permissions = [[NSArray arrayWithObjects: @"publish_stream", @"offline_access", @"read_stream", nil] retain];
	[fbSession authorize:permissions  delegate:self];
}

- (void) resetFB
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:nil forKey:FB_ACCESS_TOKEN_KEY];
	[defaults setObject:nil forKey:FB_EXPIRATION_DATE_KEY];
	[defaults setBool:FALSE forKey:kIsFBAuthenticated];
	[defaults synchronize];
	
	if (fbSession) 
		fbSession = nil;
	
	[MizDataManager sharedDataManager].isFBAuthenticatedUser = FALSE;
}


- (void) mizFBLogout
{
//	if (fbSession) {
		[fbSession logout:self];
		[self resetFB];
//	}
}

#pragma mark FBConnect delegate


///////////////////////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(FBRequest *)request
{
	MizoonLog( @"requestLoading -- >>>>>>>");
}

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
	MizoonLog( @"didReceiveResponse -- >>>>>>>");
}

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data
{
	MizoonLog( @"didLoadRawResponse -- >>>>>>>");
}


/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result 
{
//	if ([request.method isEqualToString:@"facebook.fql.query"]) 
	if ([request.httpMethod isEqualToString:@"facebook.fql.query"]) 

	{
		NSArray* users = result;
		NSDictionary* user = [users objectAtIndex:0];
		NSString* name = [user objectForKey:@"name"];
		MizoonLog( @"Logged in as %@", name);
		[self postError: @"facebook" withErrNum:@"Logged in:" andErrDesc: name];
//	} else if ([request.method isEqualToString:@"facebook.users.setStatus"]) {
	} else if ([request.httpMethod isEqualToString:@"facebook.users.setStatus"]) {

		NSString* success = result;
		if ([success isEqualToString:@"1"]) {
			MizoonLog( @"Status successfully set"); 
			[self postError: @"facebook" withErrNum:@"20" andErrDesc: [NSString stringWithFormat:@"Status successfullty set. result=%@", success]];

		} else {
			MizoonLog( @"Problem setting status"); 
			[self postError: @"facebook" withErrNum:@"22" andErrDesc: [NSString stringWithFormat:@"Problem setting status. result=%@", success]];
		}
//	} else if ([request.method isEqualToString:@"facebook.photos.upload"]) {
	} else if ([request.httpMethod isEqualToString:@"facebook.photos.upload"]) {

		NSDictionary* photoInfo = result;
		NSString* pid = [photoInfo objectForKey:@"pid"];
		MizoonLog( @"Uploaded with pid %@", pid);
	}
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error 
{
	MizoonLog( @"Error(%d) %@", error.code, error.localizedDescription);
	
	if (error.code == 10000) {
		[self resetFB];
	}
	
	if (request.httpMethod) {

//		[self postError: @"facebook" withErrNum:@"Mizoon: request didFailWithError" andErrDesc: [NSString stringWithFormat:@"Error(%d) %@ -- method=%@", error.code, error.localizedDescription, request.method]];
		[self postError: @"facebook" withErrNum:@"Mizoon: request didFailWithError" andErrDesc: [NSString stringWithFormat:@"Error(%d) %@ -- method=%@", error.code, error.localizedDescription, request.httpMethod]];


	} else {
		[self postError: @"facebook" withErrNum:@"Mizoon: request didFailWithError" andErrDesc: [NSString stringWithFormat:@"Error(%d) %@", error.code, error.localizedDescription]];
	}
}


/* FBSessionDelegate */

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin 
{
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:fbSession.accessToken forKey:FB_ACCESS_TOKEN_KEY];
    [defaults setObject:fbSession.expirationDate forKey:FB_EXPIRATION_DATE_KEY];
	[defaults setBool:TRUE forKey:kIsFBAuthenticated];
    [defaults synchronize];
	
	[MizDataManager sharedDataManager].isFBAuthenticatedUser = TRUE;
	
	int topView = [rvc topView];
	
	[rvc removeView:topView];
	[rvc renderView: topView fromView: INIT_VIEW];
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled 
{
	MizoonLog( @"fbDidNotLogin---------------");
	[self resetFB];
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout 
{
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	int topView = [rvc topView];

	[self resetFB];

	[rvc removeView:topView];
	[rvc renderView: topView fromView: INIT_VIEW];
}

- (void)fbDialogLogin:(NSString*)token expirationDate:(NSDate*)expirationDate
{
	MizoonLog( @"fbDialogLogin---------------");
}

- (void)fbDialogNotLogin:(BOOL)cancelled
{
	MizoonLog( @"fbDialogNotLogin---------------");
}





- (void)setFBStatus:(NSString *)statusString atLocation: (MizoonLocation *) location {
	
	NSString *statusMessage;
	
	if (![self isUserFBAuthenticated]) 
		return;
	
	if (statusString) {
		statusMessage = [NSString stringWithFormat:@"%@ \n@ %@ (%@, %@)", 
						 statusString,  location.name, location.city, location.state];
	} else {
		statusMessage = [NSString stringWithFormat:@" Checked in @ %@ (%@, %@)", 
						 location.name, location.city, location.state];
	}
	

	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   statusMessage,@"message",
//								   @"Suck it!",@"name",
//								   @"http://www.bushmackel.com/2010/01/11/facebook-development-sucks/", @"link",
//								   @"http://www.flatblackfilms.com/finger.JPG", @"picture",
								   nil];	
	
	[fbSession requestWithGraphPath:@"/me/feed"   // or use page ID instead of 'me'
							  andParams:params
						  andHttpMethod:@"POST"
							andDelegate:self];
	
	

	
//	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//							statusMessage, @"status",
//							@"true", @"status_includes_verb",
//							nil];
//	[[FBRequest requestWithDelegate:self] call:@"facebook.users.setStatus" params:params];
}


- (void)postFBStatus:(NSString *)statusMessage 
{
	if (![self isUserFBAuthenticated]) 
		return;

	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   statusMessage,@"message",
//								   @"Suck it!",@"name",
//								   @"http://www.bushmackel.com/2010/01/11/facebook-development-sucks/", @"link",
//								   @"http://www.flatblackfilms.com/finger.JPG", @"picture",
								   nil];	
	
	[fbSession requestWithGraphPath:@"/me/feed"   // or use page ID instead of 'me'
							  andParams:params
						  andHttpMethod:@"POST"
							andDelegate:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////


/*
- (void)session:(FBSession*)session didLogin:(FBUID)uid 
{
	MizDataManager *md = [MizDataManager sharedDataManager];
	NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];	
	
	if (md.isFBAuthenticatedUser) 
		return;
	
	********************
	 FBPermissionDialog* dialog = [[[FBPermissionDialog alloc] initWithSession:fbSession] autorelease];
	 dialog.delegate = self;
	 dialog.permission = @"read_stream, publish_stream, read_friendlists, photo_upload";
	 [dialog show];
	 ********************
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	md.isFBAuthenticatedUser = YES;
	
	[userData	setBool:TRUE forKey:kIsFBAuthenticated];
	
	[self postError: @"facebook" withErrNum:@"FB login" andErrDesc: [NSString stringWithFormat:@"user=%@",  [userData stringForKey:kUsername]]];


//    [self performSelectorInBackground:@selector(displayView) withObject:nil ];
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"MZ_Post_FB_Login" object:(id)md];
	
    [pool release];    
}

- (void) displayView
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	RootViewController *rvc = [ [Mizoon sharedMizoon] getRootViewController];
	int viewID = [rvc topView];
	[rvc renderView:viewID fromView:SHARE_CHECKIN_VIEW];
	[pool release];    
}


- (void)sessionDidLogout:(FBSession*)session {
	MizDataManager *md = [MizDataManager sharedDataManager];
	NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
	
	md.isFBAuthenticatedUser = NO;
	
	[userData	setBool:FALSE forKey:kIsFBAuthenticated];
}



- (BOOL) isLoggedInFB 
{	
	if (![self isUserFBAuthenticated]) 
		return NO;
	
//	if ( !([Mizoon sharedMizoon].fbSession && [Mizoon sharedMizoon].fbSession.sessionKey))
	if ( !([Mizoon sharedMizoon].fbSession))

		return NO;

	return YES;
}


- (void)setFBStatus:(NSString *)statusString atLocation: (MizoonLocation *) location {
	
	NSString *statusMessage;
	
	if (![self isLoggedInFB]) 
		return;
	
	if (statusString) {
		statusMessage = [NSString stringWithFormat:@"%@ \n@ %@ (%@, %@)", 
								   statusString,  location.name, location.city, location.state];
	} else {
		statusMessage = [NSString stringWithFormat:@" Just checked in @ %@ (%@, %@)", 
								   location.name, location.city, location.state];
	}


	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							statusMessage, @"status",
							@"true", @"status_includes_verb",
							nil];
	[[FBRequest requestWithDelegate:self] call:@"facebook.users.setStatus" params:params];
}


- (void)postFBStatus:(NSString *)statusMessage 
{
	if (![self isUserFBAuthenticated]) 
		return;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							statusMessage, @"status",
							@"true", @"status_includes_verb",
							nil];
	[[FBRequest requestWithDelegate:self] call:@"facebook.users.setStatus" params:params];
}

*/


#pragma mark Twitter 

- (void) initTwitter
{
	if (!twtOAuthEngine) {
		twtOAuthEngine = [[TwtOAuthEngine alloc] initOAuthWithDelegate: self];
		twtOAuthEngine.consumerKey = kOAuthConsumerKey;
		twtOAuthEngine.consumerSecret = kOAuthConsumerSecret;
		
		if (!twtOAuthEngine.OAuthSetup) 
			[twtOAuthEngine requestRequestToken];
		
		[twtOAuthEngine isAuthorized];
	}
}

- (BOOL) isLoggedInTwitter 
{	
	return [MizDataManager sharedDataManager].isTwtAuthenticatedUser;
}

- (void) twitterLogout
{	
	[[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kIsTwtAuthenticated];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"authData"];
	[MizDataManager sharedDataManager].isTwtAuthenticatedUser = NO;
	
//	[twtOAuthEngine release];
	twtOAuthEngine = nil;
	[self initTwitter];
}


- (void) twitterLogin: (NSString *) data
{	
	[[NSUserDefaults standardUserDefaults] setObject: data forKey: @"authData"];
	[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsTwtAuthenticated];
	[MizDataManager sharedDataManager].isTwtAuthenticatedUser = YES;
}



- (void)postToTwitter:(NSString *)message  
{
	if ([self isLoggedInTwitter]) 
		[twtOAuthEngine sendUpdate: message];
}

- (void)postToTwitter:(NSString *)statusString atLocation: (MizoonLocation *) location
{
	NSString *statusMessage;
	
	if (![self isLoggedInTwitter]) 
		return;
	
	if (statusString) {
		statusMessage = [NSString stringWithFormat:@"%@ (@ %@-%@,%@)", 
						 statusString,  location.name, location.city, location.state];
	} else {
		statusMessage = [NSString stringWithFormat:@"Just checked in @ %@ (%@,%@)", 
						location.name, location.city, location.state];
	}
	
	[twtOAuthEngine sendUpdate: statusMessage];
}

#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username 
{
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
//	[defaults setObject: data forKey: @"authData"];
//	[defaults	setBool:TRUE forKey:kIsTwtAuthenticated];

	[self twitterLogin: data];
	[defaults synchronize];
	
	int topView = [rvc topView];
	
	switch (topView) {
		case SETTINGS_VIEW:
			[rvc reloadSetup];
			break;
		case SHARE_CHECKIN_VIEW:
			[rvc reloadConfirmCheckin];
			break;
		default:
			[rvc reloadSetup];
			break;
	}
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username 
{
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}



@end
