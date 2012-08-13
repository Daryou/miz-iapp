//
//  LocationViewCell.h
//  Mizoon
//
//  Created by Daryoush Paknad on 8/14/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"MizoonLocation.h"

@interface LocationViewCell : UITableViewCell {
	UILabel		*nameLbl;
	UILabel		*addressLbl;
	UILabel		*categoryLbl;
	UIImageView *iconView;
	
	MizoonLocation *location;
}

@property (nonatomic, retain) UILabel		*nameLbl;
@property (nonatomic, retain) UILabel		*addressLbl;
@property (nonatomic, retain) UILabel		*categoryLbl;
@property (nonatomic, retain) UIImageView	*iconView;
@property (nonatomic, retain) MizoonLocation	*location;

@end
