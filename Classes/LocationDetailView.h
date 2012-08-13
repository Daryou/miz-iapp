//
//  LocationInfoView.h
//  Mizoon
//
//  Created by Daryoush Paknad on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"AsyncImageView.h"

@interface LocationDetailView : UIView {
	UILabel			*nameLbl;
	UILabel			*addressLbl;
	UILabel			*cityLbl;
	UILabel			*catLbl;
	UIButton		*checkinBtn;
	UIButton		*phoneBtn;
	UIButton		*websiteBtn;
	AsyncImageView	*asyncImage;
	int				nextBtnX;
}


@property (nonatomic, retain) UILabel *nameLbl;
@property (nonatomic, retain) UILabel *addressLbl;
@property (nonatomic, retain) UILabel *cityLbl;
@property (nonatomic, retain) UILabel *catLbl;
@property (nonatomic, retain) AsyncImageView *asyncImage;
@property (nonatomic, retain) UIButton *checkinBtn;
@property (nonatomic, retain) UIButton *phoneBtn;
@property (nonatomic, retain) UIButton *websiteBtn;
@property int nextBtnX;

- (id)initWithFrame:(CGRect)frame mizLocation: (MizoonLocation *) location;
- (void) setLocName: (NSString *) name;
- (void) setAddress: (NSString *) address;
- (void) setCity: (NSString *) city;
- (void) setCategory: (NSString *) cat;
- (void) setLocImage: (NSString *) image;
- (void) setWebsite: (NSString *) websiteURL;
- (void) setPhone: (NSString *) phoneNum;

@end
