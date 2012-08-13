//
//  PostsViewPhotoCell.m
//  Mizoon
//
//  Created by Daryoush Paknad on 3/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PostsViewPhotoCell.h"

#define	PHOTO_HEIGHT	100

@implementation PostsViewPhotoCell




- (id)initWithStyle:(UITableViewCellStyle) style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		messageLabel.frame = CGRectMake(LEFT_OFFSET, 20, LABEL_WIDTH-80, MESSAGE_HEIGHT+25);
		messageLabel.numberOfLines = 3;
		postInfoLabel.frame = CGRectMake(LEFT_OFFSET, 75, LABEL_WIDTH-80, MESSAGE_HEIGHT);
		postInfoLabel.lineBreakMode = UILineBreakModeCharacterWrap;
//		NSLog(@"-------- New photo cell");
		
    }
	
    return self;
}



- (void)dealloc {
    [asyncPhoto release];
//	[messageLabel release];

    [super dealloc];
}



- (void)setPhoto: (NSString *) photoLink {
	if (asyncPhoto) {
		[asyncPhoto release];
	}
	asyncPhoto = [[AsyncImageView alloc] initWithFrame:CGRectMake(200, 0, 90, PHOTO_HEIGHT)];
	asyncPhoto.tag = kPostPhotoTag;
	
//	NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@/?q=api/scale/&h=%d&image=/%@", MIZOON_HOST, PHOTO_HEIGHT, photoLink];
	NSString *imageUrl = [NSString stringWithFormat: @"%@/?q=api/scale/&h=%d&image=/%@", MIZOON_HOST, PHOTO_HEIGHT, photoLink];


	NSURL *url = [[NSURL alloc] initWithString:imageUrl];
	[asyncPhoto loadImageFromURL:url  withStyle: UIActivityIndicatorViewStyleGray];
	[self.contentView addSubview:asyncPhoto];
	[url release];
}


@end
