//
//  NearbyPeopleViewCell.h
//  Mizoon
//
//  Created by Daryoush Paknad on 3/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	"AsyncImageView.h"
#import	"Constants.h"


@interface NearbyPeopleViewCell : UITableViewCell {
    NSDictionary *post;
	
	AsyncImageView	*asyncImage;
    UILabel			*nameLabel;
    UILabel			*p1Label;			// profile labels
	UILabel			*p2Label;
    UILabel			*p3Label;

    UIActivityIndicatorView *activityIndicator;
	
	BOOL	gettingMore;
	int		nextProfile;
}

//@property (nonatomic, retain) UILabel *nameLabel;
//@property (nonatomic, retain) UILabel *p1Label;
//@property (nonatomic, retain) UILabel *p2Label;
//@property (nonatomic, retain) UILabel *p3Label;
//@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
//@property (nonatomic, retain) AsyncImageView *asyncImage;

- (void)setImage: (NSString *) imageLink;
- (void)setName:(NSString *) name;
- (void)setProfile:(NSString *) attr withValue: (NSString *) value;
- (void)runSpinner:(BOOL)value;

@end
