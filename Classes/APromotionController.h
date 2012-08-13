//
//  APromotionController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 5/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import	"LocationDetailView.h"
#import	"CouponLinksView.h"
#import	"APromoView.h"

@interface APromotionController : UIViewController <UIScrollViewDelegate> {
	UIScrollView		*scrollView;
	UIView				*content;
//	LocationDetailView	*locInfoView;
	CouponLinksView		*couponLinksView;
	APromoView			*aPromoView;
	
	
	UIToolbar			*toolbar;
	BOOL				redeemed;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *content;
@property (nonatomic, retain) CouponLinksView *couponLinksView;
//@property (nonatomic, retain) LocationDetailView *locInfoView;
@property (nonatomic, retain) APromoView *aPromoView;
@property (nonatomic, retain) UIToolbar *toolbar;

@end
