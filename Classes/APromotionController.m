//
//  APromotionController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 5/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "APromotionController.h"
#import	"PromosController.h"
#import "APromoView.h"
#import	"MizDataManager.h"
#import	"CouponLinksView.h"



@interface APromotionController (private)
-(void) initToolBar;
- (void) sizeContent;
- (void) checkinLocation;
- (void) redeemCoupon;
@end


@implementation APromotionController
@synthesize	couponLinksView, aPromoView, content, scrollView, toolbar;



 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	

	Mizoon *miz = [Mizoon  sharedMizoon];
	NSDictionary *aPromo = [miz getSelectedPromo]; 

    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

		redeemed = NO;
		
		content = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 420.0)];
//		couponLinksView = [[CouponLinksView alloc] initWithFrame:CGRectMake(0.0, 50.0, 310, 30) mizLocation: [miz getSelectedLocation]];

		// APromoView is the webView 
		aPromoView = [[APromoView alloc] initWithFrame: CGRectMake(5.0, TOP_BAR_WITH + 5, 310.0, 415.0) promoDict: aPromo];


		
		
		[content addSubview:aPromoView];
//		[content addSubview:couponLinksView];

		[content setNeedsLayout];
		[content sizeToFit];
		

		[self.view addSubview:content];


    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
   	Mizoon *miz = [Mizoon  sharedMizoon];
	NSDictionary *thePromo = [miz getSelectedPromo]; 
	
	[super viewDidLoad];
		
	if ([miz isCoupon:thePromo]) {
		[self initToolBar];
	}
	
	[self sizeContent];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	MizoonLog(@"---------------> didReceiveMemoryWarning: APromotion");

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	return;
}


- (void)dealloc {
    [super dealloc];
	[toolbar release];
	[aPromoView	release];
	[content	release];
}


#pragma mark private

-(void) initToolBar {
	
	MizDataManager *md = [MizDataManager sharedDataManager];
	Mizoon *miz = [Mizoon sharedMizoon];	
	MizoonLocation *theLocation  = [miz getSelectedLocation];
	NSDictionary *thePromo = [miz getSelectedPromo]; 

	// don't display the check in button if the user is already checked in this location and has redeemed the coupon
	if ( md.checkedin && [md  userIsInThisPlace: theLocation.name latitude:0 longitude: 0] && [miz.redeemedCP isEqualToString:[thePromo valueForKey:@"prid"]]) 
		return;
	
	toolbar = [UIToolbar new];
	[toolbar sizeToFit];
	
	toolbar.frame = CGRectMake(0.0, 420.0, 320.0, 40.0);
	toolbar.barStyle = UIBarStyleBlack;
	toolbar.translucent = YES;
	
	// image has to be 20X20 with alpha channel
	UIImage		*photoImg = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"camera-icon3" ofType:@"png"]];
	
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	if ( md.checkedin && [md  userIsInThisPlace: theLocation.name latitude:0 longitude: 0] ) {
		UIBarButtonItem *redeemButton = [[UIBarButtonItem alloc] initWithTitle:@"Redeem coupon" style:UIBarButtonItemStyleBordered target:self action:@selector(redeemCoupon)];
		[toolbar setItems:[NSArray arrayWithObjects: flexibleSpace, redeemButton,flexibleSpace,nil]];
		[redeemButton	release];
	} else  {
		UIBarButtonItem *checkinButton = [[UIBarButtonItem alloc] initWithTitle:@"Checkin to redeem coupon" style:UIBarButtonItemStyleBordered target:self action:@selector(checkinLocation)];
		[toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, checkinButton,flexibleSpace,nil]];
		[checkinButton	release];
	}
	
	[photoImg release];
	[flexibleSpace release];
		
	[self.view addSubview:toolbar];	
}


-(void) checkinLocation {
	
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *rvc = delegate.rootViewController;
	MizDataManager *md = [MizDataManager sharedDataManager];
	Mizoon *miz = [Mizoon  sharedMizoon];
	
	[md checkinMizoonLoc: [miz getSelectedLocation]];
	
	NSString *alertMsg = [NSString stringWithFormat:@"You are checked in at \n %@ \n Use the Redeem Button below to redeem your coupon", [miz getSelectedLocation].name];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:alertMsg delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[rvc renderView:A_PROMOTION_VIEW fromView:PROMOTIONS_VIEW];
}


-(void) redeemCoupon {
	
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *rvc = delegate.rootViewController;
	MizDataManager *md = [MizDataManager sharedDataManager];
	Mizoon *miz = [Mizoon sharedMizoon];
	
	NSDictionary *thePromo = miz.sPromoDict; 
	
	[md redeemCoupon:[thePromo valueForKey:@"prid"] fromLocation: [thePromo valueForKey:@"lid"]];
	
	[rvc renderView:REDEEMED_VIEW fromView:PROMOTIONS_VIEW];
}





#pragma mark helper

- (void) sizeContent {
//	MizoonLog(@"Content width=%f  height=%f", content.frame.size.width, content.frame.size.height);
	[scrollView setContentSize: CGSizeMake(content.frame.size.width, content.frame.size.height)];
}


#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sView {
	CGPoint p = sView.contentOffset;
	MizoonLog(@"x = %f, y - %f", p.x, p.y);
}




@end
