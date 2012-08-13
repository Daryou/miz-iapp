//
//  CouponLinksView.h
//  Mizoon
//
//  Created by Daryoush Paknad on 5/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"MizoonLocation.h"

@interface CouponLinksView : UIView {
	UIButton		*checkinBtn;
	UIButton		*nameBtn;
	UIButton		*redeemBtn;
	MizoonLocation	*location;
}

@property (nonatomic, retain) UIButton *checkinBtn;
@property (nonatomic, retain) UIButton *nameBtn;
@property (nonatomic, retain) UIButton *redeemBtn;

- (id)initWithFrame:(CGRect)frame mizLocation: (MizoonLocation *) loc;
- (void) setLocName: (NSString *) name;
- (void) setRedeem;

@end
