/*
 *  Constants.h
 *  Mizoon
 *
 *  Created by Daryoush Paknad on 3/17/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
#import	"MizoonAppDelegate.h"
#import	"RootViewController.h"
#import	"MizDataManager.h"
#import	"Mizoon.h"


/************* BUILD VARIABLES ****************/
#define	HORIZONTAL_ACCURACY 250
//#define HORIZONTAL_ACCURACY 80

#define MIZOON_DEBUG

#define	MIZOON_COM_SERVER
//#define MIZOONER_COM_SERVER
//#define	LOCAL_SERVER

/***********************************************/

#define PULL_REFRESH	1

#define  LOCATION_DETECTION_TIMEOUT	30  // timeout during after click on the main page 
#define	RELOAD_TIMEOUT	30				// timeout during reload 

#define kOAuthConsumerKey		@"mmwV0iBey5RT2mxppYyVw"		
#define kOAuthConsumerSecret	@"BAFj4CD6WL9r7OGFxteVVv15OQFfU6tN80vIMiKaZg"	
#define	GEO_API_KEY				@"J3E8C0odXG"


#define MIZOON_FONT				@"Helvetica"
#define MIZOON_FONT_BOLD		@"Helvetica-Bold"
#define MIZOON_FONT_ITALIC		@"Helvetica-Oblique"
#define MIZOON_FONT_BOLD_ITALIC	@"Helvetica-BoldOblique"
#define LOCATION_INFO_FONT_SIZE	14

#define MAX_STATUS_LENGTH		140
#define	TOP_BAR_WITH			44.0

#define ANYONE_PICTURE			@"anyone"

#define	kViewTableViewTag		100


#ifdef MIZOON_DEBUG
#define DebugLog(s, ...) \
NSLog(@"[%p %@:%d] %@", \
self, \
[[NSString stringWithUTF8String:__FILE__] lastPathComponent], \
__LINE__, \
[NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define DebugLog(s, ...)
#endif

#ifdef MIZOON_DEBUG
#define MizoonLog(s, ...)  NSLog(@"%@", [NSString stringWithFormat:(s),##__VA_ARGS__])
#else
#define MizoonLog(s, ...)
#endif




#ifdef	LOCAL_NETWORK_SERVER 
#define MIZOON_HOST				@"http://192.168.1.102"
#define	MIZOON_XMLRPC_SERVER	@"http://192.168.1.102/?q=services/xmlrpc"
#define	MIZOON_RESTFUL_SERVER	@"http://192.168.1.102"
#define	MIZOON_SERVER			@"http://192.168.1.102"
#endif


#ifdef	NO_CONNECTION
#define MIZOON_HOST				@"http://192.168.1.502"
#define	MIZOON_XMLRPC_SERVER	@"http://192.168.1.502/?q=services/xmlrpc"
#define	MIZOON_RESTFUL_SERVER	@"http://192.168.1.502"
#define	MIZOON_SERVER			@"http://192.168.1.502"
#endif

#ifdef LOCAL_SERVER
#define MIZOON_HOST				@"http://76.21.5.31" 
#define	MIZOON_XMLRPC_SERVER	@"http://76.21.5.31/?q=services/xmlrpc"
#define	MIZOON_RESTFUL_SERVER	@"http://76.21.5.31"
#define	MIZOON_SERVER			@"http://76.21.5.31"
#endif


#ifdef MIZOON_COM_SERVER
#define MIZOON_HOST				@"http://www.mizoon.com" 
#define	MIZOON_XMLRPC_SERVER	@"http://www.mizoon.com/?q=services/xmlrpc"
#define	MIZOON_RESTFUL_SERVER	@"http://www.mizoon.com"
#define	MIZOON_SERVER			@"http://www.mizoon.com"
#endif


#ifdef MIZOONER_COM_SERVER
#define MIZOON_HOST				@"http://www.mizooner.com" 
#define	MIZOON_XMLRPC_SERVER	@"http://www.mizooner.com/?q=services/xmlrpc"
#define	MIZOON_RESTFUL_SERVER	@"http://www.mizooner.com"
#define	MIZOON_SERVER			@"http://www.mizooner.com"
#endif

#define FB_APP_ID				@"82156015133"
#define FB_ACCESS_TOKEN_KEY		@"facebook-accessToken"
#define	FB_EXPIRATION_DATE_KEY	@"facebook-expirationDate"

#define MIZOON_APP_SECRET		@"121606290724-AMzIOzRoao#n-NA52-PK47"

#define	MAIN_VIEW				0
#define PLACES_VIEW				1
#define	EXTERNAL_LOCATION_VIEW	2
#define	PEOPLE_VIEW				3
#define	LOGIN_VIEW				4
#define YELLOW_VIEW				5
#define REG_LOGIN_VIEW			6
#define SIGN_IN_VIEW			7
#define REGISTER_VIEW			8
#define SETTINGS_VIEW			9
#define	INIT_VIEW				10
#define	POSTS_VIEW				11
#define	A_POST_VIEW				12
#define	NEW_POST_VIEW			14
#define	CHECKED_IN_VIEW			15
#define LOCATIONS_WITH_PROMOTIONS_VIEW	16
#define	PROMOTIONS_VIEW			17
#define	A_PROMOTION_VIEW		18
#define	REDEEMED_VIEW			19
#define	A_PERSON_VIEW			20
#define	SEND_MESSAGE_VIEW		21
#define	SHARE_CHECKIN_VIEW		22
#define	MAP_VIEW				23
#define	WEBSITE_VIEW			24
#define	CALL_VIEW				25
#define	CREATE_LOCTION_VIEW		27
#define	NEW_LOCATION_VIEW		28
#define	PLACE_MAP_VIEW			29
#define	CAFE_VIEW				30
#define	RESTAURANT_VIEW			31
#define	NIGHTLIFE_VIEW			32
#define	SHOPPING_VIEW			33
#define	LODGING_VIEW			34
#define	EXTERNAL_VIEW			300


#define TEST_VIEW				200


#define	kLocationInfoTag	0
#define kLocNameTag			1
#define kLocAddressTag		2
#define kLocImageTag		3
#define kLocCityTag			4
#define kLocStateTag		6
#define kLocZipTag			7
#define kLocReviewTag		8
#define kLocCityStateZipTag	9
#define kLocCategoryTag		10
#define	kLocActionViewsTag	11
#define kLocationIconTag	12

#define	kPersonNameTag		12
#define	kPersonLocationTag	14

#define	kPersonProfile1Tag	15    // profile tags need to be sequential
#define	kPersonProfile2Tag	16
#define	kPersonProfile3Tag	17
#define	kPersonProfile4Tag	18
#define	kPersonProfile5Tag	19
#define	kPersonProfile6Tag	20

#define	kPersonPictureTag	21
#define	kPieSpinnerTag		22
#define	kPostPhotoTag		23
#define	kCheckinMessageTag	24
#define	kExpirationTag		25
#define	kPromoDescTag		26


#define	kSocialMediaTag		30

#define kIconViewTag		31

#define kJoinButtonTag		32

#define	kMorePersonTag		100
#define	kMorePostsTag		110
#define	kMoreSalesTag		120
#define	kMoreCouponsTag		130
#define	kMorePlacesTag		200
#define	kAsyncImageTag		300


#define	kLoginErrorTag		500

#define	DEFAULT_RADIUS			5
#define NUM_PEOPLE_TO_FETCH		20
#define NUM_PEOPLE_TO_REFEtCH	10

#define NUM_POSTS_TO_FETCH		15
#define NUM_POSTS_TO_REFEtCH	10


#define	MAX_NUM_POSTS_TO_DISPLAY	60



/*
 * icon association strings;  
 * keywords are seperated by "-"  
 * the last entry is the name of the icon
 * If any of the keywords are part of (sub-string) of the name, category or sub-category of a place, the icon is associated with the place
 * Make sure the image/icon name does not contain a "-"
 * add new entries to categoryList in Mizoon.m (getIconForLoction)
 */
#define	_RESTAURANT			@"restaurant-food-catering-eatery-food.png"
#define	_BAR				@"wine-beer-lounge- bar - pub -bar.png"
#define _COFFEE				@"coffee-cafe-coffee.png"
#define _TRAVEL				@"travel-travel.png"
#define	_PARK				@"park-parks.png"
#define	_ARCH				@"architecture-architecture.png"
#define _ART				@" art -arts.png"
#define _EDUCATION			@"education-school-university-collage-education.png"
#define _ENTERTAINMENT		@"entertainment-entertainment.png"
#define _MOVE				@"movie-theater-movie.png"
#define _HEALTH				@"health-hospital-doctor-clinic-nurse-health.png"
#define _APRTMENTS			@"apartment-condo-estate-office.png"
#define _HOTEL				@"hotel-motel- inn -hotel.png"
#define _PET				@" pet -zoo.png"
#define _SHOPPING			@"shopping-antiques-fashion-clothing-furniture-jewelry-watches-accessories-toy-shopping.png"
#define	_AIRPORT			@"airport-airport.png"
#define	_PARKING			@"parking-parking.png"
#define	_PHARMACY			@"drugstores-medicine-pharmacy.png"
#define	_POST_OFFICE		@"postal-post_office.png"
#define	_TRAIN				@"trains-railroads-train.png"
#define	_STADIUM			@"stadiums-arenas-stadium.png"
#define	_ZOO				@"zoos-zoo.png"
#define	_BANK				@"banks-financial-accountants-tax-broker-stock-insurance-bank.png"
#define	_COVENTION_CENTER   @"convention centers-meeting-halls-conv_center.png"
#define	_RELIGIOUS_CENTER	@"religious-christian-spiritual-mosque-synagogue-buddhists-religion.png"
#define _PARTY				@"party-party.png"
#define	_SERVICE			@"servic-services.png"
#define	_SPORTS				@"sports-outdoors-recreation-gym-sport.png"
#define	_AUTOMOTIVE			@"automotive- car -gas stations-motor-automotive-taxi-limos-chauffers-automotive.png"
#define	_SCISSORS 			@"barber-hair-tailor-sewing-scissor.png"



#define	RESTAURANT_TYPE		@"restaurant"
#define	FOOD_TYPE			@"food"
#define	CATERING_TYPE		@"catering"
#define EATERY_TYPE			@"eatery"

#define	BAR_TYPE			@" bar "
#define	PUB_TYPE			@" pub "

#define	COFFEE_TYPE			@"coffee"
#define	CAFE_TYPE			@"cafe"


#define	TRAVEL_TYPE			@"travel"

#define	PARK_TYPE			@"park"

#define	ARCH_TYPE			@"architecture"

#define	ART_TYPE			@" art "

#define	EDUCATION_TYPE		@"education"
#define	SCHOOL_TYPE			@"school"
#define	UNIVERSITY_TYPE		@"university"
#define	COLLAGE_TYPE		@"collage"

#define ENTERTAINMENT_TYPE	@"entertainment"
#define MOVIE_TYPE			@"movie"
#define THEATER_TYPE		@"theater" //	  movie-theaters concert-halls-and-theaters


#define	HEALTH_TYPE			@"health"
#define	HOSPITAL_TYPE		@"hospital"
#define	DOCTOR_TYPE			@"doctor"
#define CLINIC_TYPE			@"clinic"
#define NURSE_TYPE			@"nurse"

#define	SERVICES_TYPE		@"service"

#define	APARTMENTS_TYPE		@"apartment"
#define	CONDO_TYPE			@"condo"
#define	REALESTATE_TYPE		@"estate"


#define	HOTELS_TYPE			@"hotel"
#define	MOTEL_TYPE			@"motel"
#define	INN_TYPE			@" inn "


#define PET_STORE_TYPE		@" pet "

#define SHOPPING_TYPE		@"shopping"

#define	AIRPORT_TYPE		@"airport"
#define	PARKING_TYPE		@"parking"
#define	PHARMACY_TYPE		@"drugstores"  //medicine
#define	POST_OFFICE_TYPE	@"postal"
#define	TRAIN_STATION_TYPE	@"trains"  //railroads-and-trains
#define	STADIUM_TYPE		@"stadiums" // stadiums-and-arenas
#define	ZOO_TYPE			@"zoos"
#define	BANK_TYPE			@"banks" //financial:banks
#define	COVENTION_CENTER_TYPE	@"convention centers" //convention-centers-and-meeting-halls
#define	RELIGIOUS_CENTER_TYPE	@"religious" // christians spiritual:mosques spiritual:synagogues spiritual:buddhists
#define PARTY_TYPE			@"party"

