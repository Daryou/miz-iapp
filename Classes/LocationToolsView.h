//
//  LocationToolsView.h
//  Mizoon
//
//  Created by Daryoush Paknad on 9/24/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LocationToolsView :UITableViewCell <UIScrollViewDelegate> {
	UIScrollView	*toolsScrolView;
	UIView			*tView;
	UIImageView		*leftArrow;
	UIImageView		*rightArrow;
	CGFloat			currentButtonX;
	UIView			*controllerView;
}

@property (nonatomic, retain) UIView *tView;
@property (nonatomic, retain) UIImageView *leftArrow;
@property (nonatomic, retain) UIImageView *rightArrow;

@property	CGFloat currentButtonX;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier controllerView: (UIView *) controller;

@end
