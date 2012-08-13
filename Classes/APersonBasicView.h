//
//  APersonBasicView.h
//  Mizoon
//
//  Created by Daryoush Paknad on 6/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"Constants.h"
#import	"Mizoon.h"
#import "MizoonerProfiles.h"
#import	"MizDataManager.h"
#import	"AsyncImageView.h"

@interface APersonBasicView : UIView {
	UILabel			*uNameLbl;
	UILabel			*profile1Lbl;
	UILabel			*profile2Lbl;
	UILabel			*profile3Lbl;
	UILabel			*profile4Lbl;

	UIButton		*msgBtn;
	UIButton		*friendBtn;
	UIButton		*websiteBtn;
	
	AsyncImageView	*asyncImage;
	int				nextBtnX;
}


@property (nonatomic, retain) UILabel *uNameLbl;
@property (nonatomic, retain) UILabel *profile1Lbl;
@property (nonatomic, retain) UILabel *profile2Lbl;
@property (nonatomic, retain) UILabel *profile3Lbl;
@property (nonatomic, retain) UILabel *profile4Lbl;

@property (nonatomic, retain) AsyncImageView *asyncImage;

@property (nonatomic, retain) UIButton *msgBtn;
@property (nonatomic, retain) UIButton *friendBtn;
@property (nonatomic, retain) UIButton *websiteBtn;
@property int nextBtnX;

//- (id)initWithFrame:(CGRect)frame personProfile: (NSDictionary *) aPersonDict;
- (id)initWithFrame:(CGRect)frame personProfile: (MizoonerProfiles *) profiles;
- (void) setProfileValues: (MizoonerProfiles *) profiles;


@end


