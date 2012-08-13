//
//  LocationDetailViewCell.m
//  Mizoon
//
//  Created by Daryoush Paknad on 8/15/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import "LocationDetailViewCell.h"
#import	"Constants.h"


#define BUTTONS_ORIGIN_X	10
#define	BUTTON_GAPS			90

#define BUTTONS_Y			90
#define BUTTONS_WIDTH		80
#define BUTTONS_HEIGHT		40

//
//@interface LocationDetailViewCell()  //private
//- (void) setupLocationButtons;
//- (IBAction) mapLocation;
//- (IBAction) checkin;
//- (IBAction) websiteView;
//- (IBAction) callLocation;
//-(IBAction) moreInfo;
//@end




@implementation LocationDetailViewCell
@synthesize	currentButtonX, addressLbl, cityStateLbl, categoryLbl, iconView, controllerView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier controllerView: (UIView *) controller {
	
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {

//		Mizoon *miz = [Mizoon sharedMizoon];
//		MizoonLocation	 *theLocation = [miz getSelectedLocation];	

		self.selectionStyle = UITableViewCellSelectionStyleGray;
		self.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
		self.selectionStyle = UITableViewCellSelectionStyleNone;

		self.currentButtonX = BUTTONS_ORIGIN_X;
		
		addressLbl = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 10.0, 220.0, 18.0)];
		addressLbl.textAlignment = UITextAlignmentLeft;
		addressLbl.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];
		[self.contentView addSubview:addressLbl];
		[addressLbl	release];

		cityStateLbl = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 35.0, 220.0, 18.0)];
		cityStateLbl.textAlignment = UITextAlignmentLeft;
		cityStateLbl.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];
		[self.contentView addSubview:cityStateLbl];
		[cityStateLbl	release];
		
		
//		if ( theLocation.latitude != 0) {
//			UIButton *mapButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//			mapButton.frame = CGRectMake(250, 37, 50, 18);
//			mapButton.titleLabel.font = [UIFont italicSystemFontOfSize: 12];
//			[mapButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//			[mapButton setTitle:@"(map)" forState:UIControlStateNormal];
//			//		[mapButton setImage:[UIImage imageNamed:@"map-button.png"] forState:UIControlStateNormal];
//			[mapButton addTarget:self action:@selector(mapLocation) forControlEvents:UIControlEventTouchUpInside];
//			[self.contentView addSubview:mapButton];
//			[mapButton release];		
//		}
		
		categoryLbl = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 55.0, 220.0, 18.0)];
		categoryLbl.textAlignment = UITextAlignmentLeft;
		categoryLbl.font = [UIFont systemFontOfSize:12];
		[self.contentView addSubview:categoryLbl];
		[categoryLbl release];
		
		iconView = [[[UIImageView alloc] initWithFrame:CGRectMake(5.0, 10.0, 60.0, 60.0)] autorelease];
		[self.contentView addSubview:iconView];
		//		[iconView release];
		
//		[self setupLocationButtons];
//		controllerView = controller;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}
//
//
//#pragma mark private
//
//- (void) setupLocationButtons {
//
//	Mizoon *miz = [Mizoon sharedMizoon];
//	MizoonLocation	 *theLocation = [miz getSelectedLocation];	
//	MizDataManager *dm = [MizDataManager sharedDataManager];
//	CheckinInfo *cInfo = dm.checkedinLoc;
//	
//	if ( !(cInfo->lat == theLocation.latitude && cInfo->lon == theLocation.longitude ) ) {
//		UIButton *checkInButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//		[checkInButton setImage:[UIImage imageNamed:@"check-in-button.png"] forState:UIControlStateNormal];
//		checkInButton.frame = CGRectMake(currentButtonX, BUTTONS_Y , BUTTONS_WIDTH, BUTTONS_HEIGHT);
//		[checkInButton addTarget:self action:@selector(checkin) forControlEvents:UIControlEventTouchUpInside];	
//		[self.contentView addSubview:checkInButton];
//		[checkInButton release];
//		currentButtonX += 90;
//	}
//	
//	if ( [theLocation.website length] != 0) {
//		UIButton *websiteButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//		websiteButton.frame = CGRectMake(currentButtonX , BUTTONS_Y, BUTTONS_WIDTH, BUTTONS_HEIGHT);
//		[websiteButton setImage:[UIImage imageNamed:@"website-button.png"] forState:UIControlStateNormal];
//		[websiteButton addTarget:self action:@selector(websiteView) forControlEvents:UIControlEventTouchUpInside];
//		[self.contentView addSubview:websiteButton];
//		[websiteButton release];	
//		currentButtonX += 90;
//	}
//	
//	if ( [theLocation.phone length] != 0) {
//		UIButton *phoneButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//		phoneButton.frame = CGRectMake(currentButtonX, BUTTONS_Y , BUTTONS_WIDTH, BUTTONS_HEIGHT);
//		[phoneButton setImage:[UIImage imageNamed:@"call-button.png"] forState:UIControlStateNormal];
//		[phoneButton addTarget:self action:@selector(callLocation) forControlEvents:UIControlEventTouchUpInside];
//		[self.contentView addSubview:phoneButton];
//		[phoneButton release];	
//		currentButtonX += 90;
//	}
//		
//	UIButton *moreButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//	moreButton.frame = CGRectMake(currentButtonX, BUTTONS_Y , BUTTONS_WIDTH, BUTTONS_HEIGHT);
//	[moreButton setImage:[UIImage imageNamed:@"more-button.png"] forState:UIControlStateNormal];
//	[moreButton addTarget:self action:@selector(moreInfo) forControlEvents:UIControlEventTouchUpInside];
//	[self.contentView addSubview:moreButton];
//	[moreButton release];	
//	currentButtonX += 90;
//	
//}
//
//
//
//
//-(IBAction) mapLocation {
//	
//	Mizoon	*miz = [Mizoon sharedMizoon];
//	MizoonLocation *theLocation = [miz getSelectedLocation];
//	RootViewController *rvc = [miz getRootViewController];
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
//}
//
//
//
//
//-(IBAction) websiteView {
//	Mizoon *miz = [Mizoon sharedMizoon];
//	MizoonLocation *theLocation = [miz getSelectedLocation];
//	RootViewController *rvc = [miz getRootViewController];
//
//	
//	NSURL *url = [NSURL URLWithString:theLocation.website];
//	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//		
//	[rvc renderView:WEBSITE_VIEW fromView:EXTERNAL_LOCATION_VIEW];
//	[rvc.websiteView loadRequest:requestObj];
//}
//
//
//
//-(IBAction) moreInfo {
//	Mizoon *miz = [Mizoon sharedMizoon];
//	MizoonLocation *theLocation = [miz getSelectedLocation];
//	RootViewController *rvc = [miz getRootViewController];
//	
//	NSString *urlStr = [NSString stringWithFormat:@"http://www.google.com/search?q=%@ %@ %@ %@ review", theLocation.name, theLocation.address, theLocation.city, theLocation.state];
//	NSString *encodedUrlString = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//	NSURL *url = [NSURL URLWithString:encodedUrlString];
//	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//	
//	[rvc renderView:WEBSITE_VIEW fromView:EXTERNAL_LOCATION_VIEW];
//	[rvc.websiteView loadRequest:requestObj];
//}
//
//
//
//-(IBAction) callLocation {
//	Mizoon *miz = [Mizoon sharedMizoon];
//	MizoonLocation *theLocation = [miz getSelectedLocation];
//
//	NSString *phoneURL  = [[NSString alloc] initWithFormat:@"tel://%@", theLocation.phone];
//	
//	NSLog(@"Phone - %@", phoneURL);
//	NSString *cleanPhone = [phoneURL stringByReplacingOccurrencesOfString:@"(" withString:@""];
//	cleanPhone = [cleanPhone stringByReplacingOccurrencesOfString:@")" withString:@""];
//	cleanPhone = [cleanPhone stringByReplacingOccurrencesOfString:@"-" withString:@""];
//	cleanPhone = [cleanPhone stringByReplacingOccurrencesOfString:@"." withString:@""];
//	cleanPhone = [cleanPhone stringByReplacingOccurrencesOfString:@" " withString:@""];
//
////	NSCharacterSet *charactersToRemove =[[ NSCharacterSet characterSetWithCharactersInString:@"0123456789" ] invertedSet ];
////	NSCharacterSet *charactersToRemove =[ NSCharacterSet characterSetWithCharactersInString:@"()-. " ];
////	NSString *trimmedReplacement =	[ theLocation.phone stringByTrimmingCharactersInSet:charactersToRemove ];
////	NSLog(@"Phone - %@", trimmedReplacement);
//
//	
//	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:cleanPhone]];
//	
//	[phoneURL release];
//}
//
//
//-(IBAction) checkin {
//	Mizoon *miz = [Mizoon sharedMizoon];
//	RootViewController *rvc = [miz getRootViewController];
//	
//	
//	[rvc renderView:SHARE_CHECKIN_VIEW fromView:EXTERNAL_LOCATION_VIEW];
//}
//
//




@end
