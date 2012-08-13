//
//  LocationToolsView.m
//  Mizoon
//
//  Created by Daryoush Paknad on 9/24/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import "LocationToolsView.h"
#import	"Constants.h"
#import <MapKit/MapKit.h>


#define BUTTONS_ORIGIN_X	10
#define	BUTTON_GAPS			10

#define BUTTONS_Y			2
#define BUTTONS_WIDTH		50
#define BUTTONS_HEIGHT		50

static CGFloat  verticalScroll;

@interface LocationToolsView()  //private
- (void) setupLocationButtons;
- (IBAction) mapLocation;
- (IBAction) checkin;
- (IBAction) websiteView;
- (IBAction) callLocation;
- (IBAction) moreInfo;
- (IBAction) postMessage;
- (int) getNumberOfButtons; 
@end



@implementation LocationToolsView

@synthesize currentButtonX, leftArrow, rightArrow, tView;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier controllerView: (UIView *) controller 
{
	int numButtons;
	
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		self.selectionStyle = UITableViewCellSelectionStyleGray;
		self.backgroundColor = [UIColor colorWithRed:120/255.0 green:120/255.0 blue:120/255.0 alpha:1.0];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		numButtons = [self getNumberOfButtons];
		CGFloat	scrollViewWidth = (numButtons * BUTTONS_WIDTH + numButtons * BUTTON_GAPS);
		
		
		toolsScrolView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, 5, 260, 55)];
		toolsScrolView.delegate = self;
		toolsScrolView.backgroundColor = [UIColor grayColor];
		
		toolsScrolView.contentSize = CGSizeMake(scrollViewWidth, toolsScrolView.frame.size.height);
		toolsScrolView.contentOffset = CGPointMake(0, 0);
		toolsScrolView.clipsToBounds = YES;
		toolsScrolView.bounces = YES;
		toolsScrolView.pagingEnabled = NO;
		toolsScrolView.showsVerticalScrollIndicator = NO;
		toolsScrolView.showsHorizontalScrollIndicator = NO;
		toolsScrolView.scrollEnabled = YES; 	
		toolsScrolView.delaysContentTouches = YES;
		
		
		leftArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-l.png"]];
		rightArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-r.png"]];   
		
		leftArrow.hidden = YES;
		rightArrow.hidden = NO;
		
		// Set the frame
		[leftArrow setFrame:CGRectMake(2, 25, 10, 12)];
		[rightArrow setFrame:CGRectMake(287, 25, 10, 12)];
		
		
		tView = [[UIScrollView alloc] initWithFrame:CGRectMake(1, 0, scrollViewWidth, toolsScrolView.frame.size.height)];
		tView.userInteractionEnabled = YES;
	
		[self.contentView addSubview:leftArrow];
		[self.contentView addSubview:rightArrow];

		[self setupLocationButtons];

        [toolsScrolView addSubview:tView];

		[self.contentView addSubview:toolsScrolView];

    }
    return self;
}


- (void)dealloc 
{
	[leftArrow	release];
	[rightArrow	release];
	[tView	release];
	
    [super dealloc];
}



#pragma mark private



- (int) getNumberOfButtons 
{
	MizoonLocation	 *theLocation = [[Mizoon sharedMizoon] getSelectedLocation];	
	CheckinInfo *cInfo = [MizDataManager sharedDataManager].checkedinLoc;
	int numButtons = 3;  // more info, visitors and post buttons
	
	if ( !(cInfo->lat == theLocation.latitude && cInfo->lon == theLocation.longitude ) )   // check-in
		numButtons++;
	
	if ( [theLocation.website length] != 0) 
		numButtons++;
	
	if ( [theLocation.phone length] != 0) 
		numButtons++;

	if ( theLocation.numVisitors > 0) 
		numButtons++;
	
	if ( theLocation.latitude != 0) // map
		numButtons++;

	return numButtons;
}


- (void) setupLocationButtons
{
	
	Mizoon *miz = [Mizoon sharedMizoon];
	MizoonLocation	 *theLocation = [miz getSelectedLocation];	
	MizDataManager *dm = [MizDataManager sharedDataManager];
	CheckinInfo *cInfo = dm.checkedinLoc;
	int gap = BUTTONS_WIDTH + BUTTON_GAPS;
	
	if ( ![miz isTemporaryCheckedin] && !(cInfo->lat == theLocation.latitude && cInfo->lon == theLocation.longitude ) ) {
		UIButton *checkInButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[checkInButton setImage:[UIImage imageNamed:@"check-in-icon.png"] forState:UIControlStateNormal];
		checkInButton.frame = CGRectMake(currentButtonX, BUTTONS_Y , BUTTONS_WIDTH, BUTTONS_HEIGHT);
		[checkInButton addTarget:self action:@selector(checkin) forControlEvents:UIControlEventTouchUpInside];	
		[tView addSubview:checkInButton];
		[checkInButton release];
		currentButtonX += gap;
	}
	
	if ( [theLocation.website length] != 0) {
		UIButton *websiteButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		websiteButton.frame = CGRectMake(currentButtonX , BUTTONS_Y, BUTTONS_WIDTH, BUTTONS_HEIGHT);
		[websiteButton setImage:[UIImage imageNamed:@"website-icon.png"] forState:UIControlStateNormal];
		[websiteButton addTarget:self action:@selector(websiteView) forControlEvents:UIControlEventTouchUpInside];
		[tView addSubview:websiteButton];
		[websiteButton release];	
		currentButtonX += gap;
	}
	
	if ( [theLocation.phone length] != 0) {
		UIButton *phoneButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		phoneButton.frame = CGRectMake(currentButtonX, BUTTONS_Y , BUTTONS_WIDTH, BUTTONS_HEIGHT);
		[phoneButton setImage:[UIImage imageNamed:@"call-icon.png"] forState:UIControlStateNormal];
		[phoneButton addTarget:self action:@selector(callLocation) forControlEvents:UIControlEventTouchUpInside];
		[tView addSubview:phoneButton];
		[phoneButton release];	
		currentButtonX += gap;
	}
	
	if ( theLocation.latitude != 0) {
		UIButton *phoneButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		phoneButton.frame = CGRectMake(currentButtonX, BUTTONS_Y , BUTTONS_WIDTH, BUTTONS_HEIGHT);
		[phoneButton setImage:[UIImage imageNamed:@"map-icon.png"] forState:UIControlStateNormal];
		[phoneButton addTarget:self action:@selector(mapLocation) forControlEvents:UIControlEventTouchUpInside];
		[tView addSubview:phoneButton];
		[phoneButton release];	
		currentButtonX += gap;
	}
	// map

	
	UIButton *moreButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	moreButton.frame = CGRectMake(currentButtonX, BUTTONS_Y , BUTTONS_WIDTH, BUTTONS_HEIGHT);
	[moreButton setImage:[UIImage imageNamed:@"i-icon.png"] forState:UIControlStateNormal];
	[moreButton addTarget:self action:@selector(moreInfo) forControlEvents:UIControlEventTouchUpInside];
	[tView addSubview:moreButton];
	[moreButton release];	
	currentButtonX += gap;
	
	
	UIButton *visitorsButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	visitorsButton.frame = CGRectMake(currentButtonX, BUTTONS_Y , BUTTONS_WIDTH, BUTTONS_HEIGHT);
	[visitorsButton setImage:[UIImage imageNamed:@"visitors-icon.png"] forState:UIControlStateNormal];
	[visitorsButton addTarget:self action:@selector(visitors) forControlEvents:UIControlEventTouchUpInside];
	[tView addSubview:visitorsButton];
	[visitorsButton release];	
	currentButtonX += gap;
	
	
	UIButton *postButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	postButton.frame = CGRectMake(currentButtonX, BUTTONS_Y , BUTTONS_WIDTH, BUTTONS_HEIGHT);
	[postButton setImage:[UIImage imageNamed:@"loc-posts-icon.png"] forState:UIControlStateNormal];
	[postButton addTarget:self action:@selector(postMessage) forControlEvents:UIControlEventTouchUpInside];
	[tView addSubview:postButton];
	[postButton release];	
	currentButtonX += gap;
}

-(IBAction) xxx {
	MizoonLog(@"PUSHED");
}




- (IBAction) visitors 
{
//	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	Mizoon	*miz = [Mizoon sharedMizoon];

	[miz showLoadMessage: @"Searching..."];

	[self performSelector:@selector(loadVisitors) withObject:nil afterDelay:0.1];			 
}


- (void) loadVisitors
{
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	Mizoon	*miz = [Mizoon sharedMizoon];

	if ( ![[MizDataManager sharedDataManager] fetchVisitors:[miz getSelectedLocation]]) {
		
		[miz hideLoadMessage];
		
//		[self performSelector:@selector(noVisitors) withObject:nil afterDelay:0.5];			 

		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
														 message:@"No one has checked in here yet."
														delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		
		[alert	release];
		return;
	}
	
	[miz hideLoadMessage];
	
	MizoonLog(@"postMessage");
	// if the EXTERNAL_LOCATION_VIEW is already at the top of the view stack pop it (renderView only pushes a view to the
	// view stack if it is not already at the top
	
	[rvc prepareToReleadALocation];
	[rvc renderView:EXTERNAL_LOCATION_VIEW fromView: MAIN_VIEW];
	
}

- (IBAction) postMessage 
{
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	
	
	MizoonLog(@"postMessage");
	[rvc renderView:NEW_POST_VIEW fromView: EXTERNAL_LOCATION_VIEW];
}


-(IBAction) mapLocation {
	
	Mizoon	*miz = [Mizoon sharedMizoon];
//	MizoonLocation *theLocation = [miz getSelectedLocation];
	RootViewController *rvc = [miz getRootViewController];
	
	[rvc renderView:PLACE_MAP_VIEW fromView:EXTERNAL_LOCATION_VIEW];
	return;
//	
//	//	http://maps.google.com/maps/api/staticmap?&size=320x480&key=MAPS_API_KEY&mobile=true&sensor=false&markers=color:blue|label:S|37.448942,-122.15841&zoom=15
//	
//	NSString *latlon = [NSString stringWithFormat:@"%f,%f", theLocation.latitude, theLocation.longitude];
//	NSString *mapURL = [NSString stringWithFormat: @"http://maps.google.com/maps?ll=%@&z=18", [latlon stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]; 
//	
//	
//	//	NSString *mapURL = [NSString stringWithFormat: @"http://maps.google.com/maps/api/staticmap?&size=320x480&key=MAPS_API_KEY&mobile=true&sensor=false&zoom=15&markers=color:red|label:S|%@", [latlon stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]; 
//	//	NSString *mapURL = [NSString stringWithFormat: @"http://maps.google.com/maps?&size=320x480&key=ABQIAAAAJn0H2rkkYlNbbrA2bfr0AhT2yXp_ZAY8_ufC3CFXhHIE1NvwkxQ7jTD7eI-tXkWk2QEfoKxLYNcs7g&mobile=true&sensor=false&zoom=15&markers=color:red|label:S|%@", [latlon stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]; 
//	
//	//	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapURL]];	
//	
//	//Create a URL object.
//	NSURL *url = [NSURL URLWithString:mapURL];
//	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//	
//	[rvc renderView:WEBSITE_VIEW fromView:EXTERNAL_LOCATION_VIEW];
//	[rvc.websiteView loadRequest:requestObj];
}




-(IBAction) websiteView {
	Mizoon *miz = [Mizoon sharedMizoon];
	MizoonLocation *theLocation = [miz getSelectedLocation];
	
	[[Mizoon sharedMizoon] showLoadMessage: @"Loading..."];
	verticalScroll = TOP_BAR_WITH;  // web view's y coord
	[self performSelector:@selector(loadWebView:) withObject:theLocation.website afterDelay:0.5];			 
}


- (void) loadWebView: (NSString	*) theUrl
{
	Mizoon *miz = [Mizoon sharedMizoon];
	RootViewController *rvc = [miz getRootViewController];
	
	NSURL *url = [NSURL URLWithString:theUrl];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	
	[rvc websiteViewWithRequest:requestObj yScroll: verticalScroll ];
	
	[rvc renderView:WEBSITE_VIEW fromView:EXTERNAL_LOCATION_VIEW];
}	



-(IBAction) moreInfo {
	Mizoon *miz = [Mizoon sharedMizoon];
	MizoonLocation *theLocation = [miz getSelectedLocation];
	
	NSString *urlStr = [NSString stringWithFormat:@"http://www.google.com/m/search?q=%@ %@ %@ %@ review", theLocation.name, theLocation.address, theLocation.city, theLocation.state];
	NSString *encodedUrlString = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[Mizoon sharedMizoon] showLoadMessage: @"Loading..."];
	verticalScroll =  -50.0;  // web view's y coord;  roll up the google stuf at top of the page

	[self performSelector:@selector(loadWebView:) withObject:encodedUrlString afterDelay:0.5];			 
}



-(IBAction) callLocation {
	Mizoon *miz = [Mizoon sharedMizoon];
	MizoonLocation *theLocation = [miz getSelectedLocation];
	
	NSString *phoneURL  = [[NSString alloc] initWithFormat:@"tel://%@", theLocation.phone];
	
	MizoonLog(@"Phone - %@", phoneURL);
	NSString *cleanPhone = [phoneURL stringByReplacingOccurrencesOfString:@"(" withString:@""];
	cleanPhone = [cleanPhone stringByReplacingOccurrencesOfString:@")" withString:@""];
	cleanPhone = [cleanPhone stringByReplacingOccurrencesOfString:@"-" withString:@""];
	cleanPhone = [cleanPhone stringByReplacingOccurrencesOfString:@"." withString:@""];
	cleanPhone = [cleanPhone stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	//	NSCharacterSet *charactersToRemove =[[ NSCharacterSet characterSetWithCharactersInString:@"0123456789" ] invertedSet ];
	//	NSCharacterSet *charactersToRemove =[ NSCharacterSet characterSetWithCharactersInString:@"()-. " ];
	//	NSString *trimmedReplacement =	[ theLocation.phone stringByTrimmingCharactersInSet:charactersToRemove ];
	//	MizoonLog(@"Phone - %@", trimmedReplacement);
	
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:cleanPhone]];
	
	[phoneURL release];
}


-(IBAction) checkin {
	Mizoon *miz = [Mizoon sharedMizoon];
	RootViewController *rvc = [miz getRootViewController];
	
	
	[rvc renderView:SHARE_CHECKIN_VIEW fromView:EXTERNAL_LOCATION_VIEW];
}


#pragma mark UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	// Are we at the left of the scrollview ?
	if (scrollView.contentOffset.x < scrollView.contentSize.width - scrollView.frame.size.width)
		rightArrow.hidden = NO;
	else
		rightArrow.hidden = YES;
	
	// Are we in the middle of scrollview ?
	if (scrollView.contentOffset.x > 0)
		leftArrow.hidden = NO;
	else
		leftArrow.hidden = YES;  
}


@end
