//
//  PostsViewCell.h
//  Mizoon
//
//  Created by Daryoush Paknad on 3/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	"AsyncImageView.h"
#import	"Constants.h"


#define MAIN_FONT_SIZE		12
#define POSTINFO_FONT_SIZE	10


#define LEFT_OFFSET		60
#define	LABEL_WIDTH		220
#define	MESSAGE_HEIGHT	15
#define	NAME_HEIGHT		30



@interface PostsViewCell : UITableViewCell {
    NSDictionary *post;
	
	AsyncImageView	*asyncImage;
    UILabel			*nameLabel;
    UILabel			*messageLabel;			// profile labels
	UILabel			*postInfoLabel;
	
    UIActivityIndicatorView *activityIndicator;
	
	BOOL	gettingMore;
}


- (void)setImage: (NSString *) imageLink;
- (void)setName:(NSString *) name;
- (void)setMessage:(NSString *) message;
- (void)setPostInfo:(NSString *) postInfo;


- (void)runSpinner:(BOOL)value;

@end
