//
//  LocationInfoView.m
//  Mizoon
//
//  Created by Daryoush Paknad on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocationDetailView.h"
#import	"MizoonLocation.h"


#define LEFT_CONTENT_OFFSET	70
#define	CONTENT_WIDTH		280
#define	LINE_HEIGHT			18
#define BUTTONS_X			10
#define BUTTONS_Y			120
#define	BUTTONS_WIDTH		80
#define	BUTTONS_HEIGHT		20


@interface LocationDetailView (private)
	- (void) initLabels;
	- (void) setLocationValues: (MizoonLocation *) location;
	-(IBAction) checkinLocation;
@end

@implementation LocationDetailView
@synthesize	nameLbl, addressLbl, cityLbl, catLbl, asyncImage, phoneBtn, websiteBtn, checkinBtn, nextBtnX;


- (id)initWithFrame:(CGRect)frame mizLocation: (MizoonLocation *) location {
   
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];

		
//		// Add 5 px of padding to the mainView bounds
//		CGRect borderFrame = CGRectInset(self.bounds, -5, -5);
//		UIView *borderView = [[UIView alloc] initWithFrame:borderFrame];
//		borderView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:.5];
//
//		[self addSubview:borderView];
//		[self	sendSubviewToBack:borderView];
//
//		
		nextBtnX = BUTTONS_X;
		
		[self initLabels];

		if (location) {
			[self setLocationValues: location];
		}
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
//	UIGraphicsBeginImageContext(CGSizeMake(theSizeOf, yourTextView));
//	
//	CGContextSetLineWidth(UIGraphicsGetCurrentContext, 3.0); //or whatever width you want
//	CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0); 
//	CGContextStrokeRect(UIGraphicsGetCurrentContext, CGContextGetClipBoundingBox(UIGraphicsGetCurrentContext)); //Note, you may need to set the clip bounding box first.  That's CGContextClipToRect(UIGraphicsGetCurrentContext, theRectOfYourUITextField);
//	
//	UIImage *backgroundImage = (UIImage *)UIGraphicsGetImageFromCurrentImageContext();
//	[self addSubview:backgroundImage];
//	[backgroundImage release];
//	
//	UIGraphicsEndImageContext();
}

- (void) setLocName: (NSString *) name {
	
	MizDataManager *md = [MizDataManager sharedDataManager];
	
	nameLbl.text = name;
	
	// if the checkin button has already been created, return
	if (checkinBtn) 
		return;
	
	// don't display the check in button if the user is already checked in this location
	if ( md.checkedin && [md  userIsInThisPlace: (NSString *) name latitude:0 longitude: 0] ) 
		return;
	
	// Create a checkin button
	checkinBtn = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	checkinBtn.frame = CGRectMake( nextBtnX, BUTTONS_Y , BUTTONS_WIDTH, BUTTONS_HEIGHT);
	checkinBtn.backgroundColor = [UIColor grayColor];
	[checkinBtn setTitle:@"Check In" forState:UIControlStateNormal];
	//		[checkinBtn buttonType: UIButtonTypeCustom];
	[checkinBtn setTitle:@"Check In" forState:UIControlEventTouchDown];
	[checkinBtn addTarget:self action:@selector(checkinLocation) forControlEvents:UIControlEventTouchUpInside];	
	[self addSubview:checkinBtn];
	nextBtnX += 90;
//	[checkinBtn release];		
}
						 
						 
- (void) setAddress: (NSString *) address {
	addressLbl.text = address;
}
- (void) setCity: (NSString *) city {
	cityLbl.text = city;
}
- (void) setCategory: (NSString *) cat {
	catLbl.text = cat;
}

- (void) setPhone: (NSString *) phoneNum {
	
	if (!phoneNum) 
		return;
	
	if (!phoneBtn) {
		phoneBtn = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		phoneBtn.frame = CGRectMake(nextBtnX, BUTTONS_Y , BUTTONS_WIDTH, BUTTONS_HEIGHT);
		phoneBtn.backgroundColor = [UIColor grayColor];
		[phoneBtn setTitle:@"Call" forState:UIControlStateNormal];
		//		[phoneBtn buttonType: UIButtonTypeCustom];
		[phoneBtn setTitle:@"Call" forState:UIControlEventTouchDown];
		[phoneBtn addTarget:self action:@selector(checkinLocation) forControlEvents:UIControlEventTouchUpInside];	
		[self addSubview:phoneBtn];
		nextBtnX += 90;
	}
}

- (void) setWebsite: (NSString *) websiteURL {
	
	if (!websiteURL) 
		return;
		
	if (!websiteBtn) {
		websiteBtn = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		websiteBtn.frame = CGRectMake(nextBtnX, BUTTONS_Y , BUTTONS_WIDTH, BUTTONS_HEIGHT);
		websiteBtn.backgroundColor = [UIColor grayColor];
		[websiteBtn setTitle:@"Website" forState:UIControlStateNormal];
		//		[websiteBtn buttonType: UIButtonTypeCustom];
		[websiteBtn setTitle:@"Website" forState:UIControlEventTouchDown];
		[websiteBtn addTarget:self action:@selector(checkinLocation) forControlEvents:UIControlEventTouchUpInside];	
		[self addSubview:websiteBtn];
		nextBtnX += 90;
	}
}


- (void) setLocImage: (NSString *) image {
	
//	NSLog(@"The location image = %@", image);
	NSString *imageUrl;
	
	if (asyncImage) {
		[asyncImage release];
	}
	asyncImage = [[[AsyncImageView alloc] initWithFrame:CGRectMake(5, 10, 50, 50)] autorelease];
	asyncImage.tag = kPersonPictureTag;
	
	if ([image characterAtIndex:0] == '/') 
		imageUrl = [[NSString alloc] initWithFormat:@"%@%@", MIZOON_HOST, image];
	else 
		imageUrl = [[NSString alloc] initWithFormat:@"%@/%@", MIZOON_HOST, image];

    NSURL *url = [[NSURL alloc] initWithString:imageUrl];
	[asyncImage loadImageFromURL:url  withStyle: UIActivityIndicatorViewStyleGray];
	[self addSubview:asyncImage];

	[imageUrl release];
	[url	release];
}

- (void)dealloc {
    [super dealloc];
	[nameLbl release];
	[addressLbl release];
	[cityLbl release];
	[catLbl release];
	[checkinBtn release];
	[websiteBtn release];
	[phoneBtn release];
	[asyncImage	release];
}


#pragma mark private


-(IBAction) checkinLocation {
	
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *rvc = delegate.rootViewController;
	MizDataManager *md = [MizDataManager sharedDataManager];
	Mizoon *miz = [Mizoon  sharedMizoon];
	
	[md checkinMizoonLoc: [miz getSelectedLocation]];

	[rvc renderView:CHECKED_IN_VIEW fromView:A_PROMOTION_VIEW];
}





- (void) initLabels {
	
	nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_CONTENT_OFFSET, 10, CONTENT_WIDTH, LINE_HEIGHT)];
	nameLbl.tag = kLocNameTag;
	nameLbl.textAlignment = UITextAlignmentLeft;
	nameLbl.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];
	[self addSubview:nameLbl];
	
	addressLbl = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_CONTENT_OFFSET, 35, CONTENT_WIDTH, LINE_HEIGHT)];
	addressLbl.tag = kLocAddressTag;
	addressLbl.textAlignment = UITextAlignmentLeft;
	addressLbl.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];
	[self addSubview:addressLbl];
	
	cityLbl = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_CONTENT_OFFSET, 50, CONTENT_WIDTH, LINE_HEIGHT)];
	cityLbl.tag = kLocCityStateZipTag;
	cityLbl.textAlignment = UITextAlignmentLeft;
	cityLbl.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];
	[self addSubview:cityLbl];
	
	catLbl = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_CONTENT_OFFSET, 70, CONTENT_WIDTH, LINE_HEIGHT)];
	catLbl.tag = kLocCategoryTag;
	catLbl.textAlignment = UITextAlignmentLeft;
	catLbl.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];
	[self addSubview:catLbl];
}	


- (void) setLocationValues: (MizoonLocation *) location {
	[self setLocName:location.name];
	[self setAddress:location.address];
	[self setLocImage:location.image];
	[self setCity:location.city];
	[self setCategory:location.category];
	[self setPhone:location.phone];
	[self setWebsite:location.website];
}
	
@end

