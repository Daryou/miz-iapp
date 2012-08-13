//
//  LocationDetailViewCell.h
//  Mizoon
//
//  Created by Daryoush Paknad on 8/15/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LocationDetailViewCell : UITableViewCell {
	UILabel		*cityStateLbl;
	UILabel		*addressLbl;
	UILabel		*categoryLbl;
	UIImageView *iconView;
		
	CGFloat		currentButtonX;
	UIView		*controllerView;
}

@property (nonatomic, retain) UILabel		*cityStateLbl;
@property (nonatomic, retain) UILabel		*addressLbl;
@property (nonatomic, retain) UILabel		*categoryLbl;
@property (nonatomic, retain) UIImageView	*iconView;
@property (nonatomic, retain) UIView	*controllerView;
@property	CGFloat currentButtonX;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier controllerView: (UIView *) controller;

@end
