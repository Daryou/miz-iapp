//
//  CouponLinksView.m
//  Mizoon
//
//  Created by Daryoush Paknad on 5/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CouponLinksView.h"
#import	"MizoonLocation.h"
#import	"MizDataManager.h"
#import	"PromosController.h"

#define LEFT_CONTENT_OFFSET	70
#define	CONTENT_WIDTH		280
#define	LINE_HEIGHT			18
#define BUTTONS_X			5
#define BUTTONS_Y			5
#define	BUTTONS_WIDTH		80
#define	BUTTONS_HEIGHT		20


@interface CouponLinksView (private)
- (void) setCouponLinkValues;
- (IBAction) checkinLocation;
- (IBAction) redeemCoupon;
//- (NSDictionary *) getThePromo;
@end

@implementation CouponLinksView
@synthesize	 nameBtn, redeemBtn, checkinBtn;


- (id)initWithFrame:(CGRect)frame mizLocation: (MizoonLocation *) loc {
	
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
		
		location = loc;
		if (location) {
			[self setCouponLinkValues];
		}
		
    }
    return self;
}


- (void)drawRect:(CGRect)rect {

}

- (void) setLocName: (NSString *) name {
	
	MizDataManager *md = [MizDataManager sharedDataManager];
	Mizoon *miz = [Mizoon sharedMizoon];	
	NSDictionary *thePromo = miz.sPromoDict; 

		
	if (!name) 
		return;
	
	if (!nameBtn) {
		nameBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		nameBtn.frame = CGRectMake(8.0, BUTTONS_Y , 150.0, BUTTONS_HEIGHT);
//		nameBtn.backgroundColor = [UIColor grayColor];
		[nameBtn setTitle:name  forState:UIControlStateNormal];
		nameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		[nameBtn setTitle:name  forState:UIControlEventTouchDown];
		[nameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[nameBtn addTarget:self action:@selector(checkinLocation) forControlEvents:UIControlEventTouchUpInside];	
		[self addSubview:nameBtn];
	}
	
	// if the checkin button has already been created, return
	if (checkinBtn || ![miz isCoupon:thePromo]) 
		return;
	
	// don't display the check in button if the user is already checked in this location
	if ( md.checkedin && [md  userIsInThisPlace: (NSString *) name latitude:0 longitude: 0] ) 
		return;
	
	// Create a checkin button
	checkinBtn = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	checkinBtn.frame = CGRectMake( 160.0, BUTTONS_Y , 150.0, BUTTONS_HEIGHT);
	[checkinBtn setTitle:@"Checkin to redeem" forState:UIControlStateNormal];
	[checkinBtn setTitle:@"Checkin to redeem" forState:UIControlEventTouchDown];
	[checkinBtn addTarget:self action:@selector(checkinLocation) forControlEvents:UIControlEventTouchUpInside];	
	[self addSubview:checkinBtn];
}


- (void) setRedeem {
	
	Mizoon *miz = [Mizoon sharedMizoon];	
	NSDictionary *thePromo = miz.sPromoDict; 
	
	if (checkinBtn || [miz.redeemedCP isEqualToString:[thePromo valueForKey:@"prid"]] || ![miz isCoupon:thePromo]) 
		return;
	
	if (!redeemBtn) {
		redeemBtn = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		redeemBtn.frame = CGRectMake(220.0, BUTTONS_Y , BUTTONS_WIDTH, BUTTONS_HEIGHT);
		redeemBtn.backgroundColor = [UIColor grayColor];
		[redeemBtn setTitle:@"Redeem" forState:UIControlStateNormal];
		[redeemBtn setTitle:@"Redeem" forState:UIControlEventTouchDown];
		[redeemBtn addTarget:self action:@selector(redeemCoupon) forControlEvents:UIControlEventTouchUpInside];	
		[self addSubview:redeemBtn];
	}
}

- (void)dealloc {
    [super dealloc];

	[checkinBtn release];
	[redeemBtn release];
	[nameBtn release];
}


#pragma mark private


-(IBAction) checkinLocation {
	
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *rvc = delegate.rootViewController;
	MizDataManager *md = [MizDataManager sharedDataManager];
	Mizoon *miz = [Mizoon  sharedMizoon];

	[md checkinMizoonLoc: [miz getSelectedLocation]];
	
	[rvc renderView:A_PROMOTION_VIEW fromView:PROMOTIONS_VIEW];
}


-(IBAction) redeemCoupon {
	
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *rvc = delegate.rootViewController;
	MizDataManager *md = [MizDataManager sharedDataManager];
	Mizoon *miz = [Mizoon sharedMizoon];
	
	NSDictionary *thePromo = miz.sPromoDict; 

	[md redeemCoupon:[thePromo valueForKey:@"prid"] fromLocation: [thePromo valueForKey:@"lid"]];
	
	[rvc renderView:REDEEMED_VIEW fromView:PROMOTIONS_VIEW];
}



- (void) setCouponLinkValues {
	[self setLocName:location.name];
	[self setRedeem];
}

@end

