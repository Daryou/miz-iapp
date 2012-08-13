//
//  PostsViewCell.m
//  Mizoon
//
//  Created by Daryoush Paknad on 3/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import	"PostsViewCell.h"
#import	"MizEntityConverter.h"


@interface PostsViewCell (private)
- (void)addImage;
- (void)addNameLabel;
- (void)addMessageLabel;
- (void)addPostInfoLabel;
- (void)addActivityIndicator;
@end




@implementation PostsViewCell


- (id)initWithStyle:(UITableViewCellStyle) style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
        [self addImage];
		[self addNameLabel];
        [self addMessageLabel];
		[self addPostInfoLabel];
		
        [self addActivityIndicator];
    }
	
    return self;
}



- (void)dealloc {
    [asyncImage release];
	[nameLabel release];
    [messageLabel release];
	[postInfoLabel release];
	
    [activityIndicator release];
    [super dealloc];
}


- (void)prepareForReuse{
	[super prepareForReuse]; 
	
	nameLabel.text = messageLabel.text = postInfoLabel.text = nil;
	nameLabel.textColor = [UIColor blackColor];
}



- (void)setImage: (NSString *) imageLink {
	if (asyncImage) {
		[asyncImage release];
	}
	asyncImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
	asyncImage.tag = kPersonPictureTag;
		
	NSString *imageUrl = [NSString stringWithFormat:@"%@/%@", MIZOON_HOST, imageLink];
	NSURL *url = [[NSURL alloc] initWithString:imageUrl];
	[asyncImage loadImageFromURL:url  withStyle: UIActivityIndicatorViewStyleGray];
	[self.contentView addSubview:asyncImage];
	
	[url release];   //released when asyncImage is freed
}

- (void)setName:(NSString *) name {
	nameLabel.text = name;
}


- (void)setMessage:(NSString *) msg {
	
	MizEntityConverter *entityCnvt = [[MizEntityConverter alloc] init];
	NSString *cleanMsg = [entityCnvt convertEntiesInString:msg];
	
	messageLabel.text = cleanMsg;
	
	[cleanMsg release];
	[entityCnvt release];
}


- (void)setPostInfo:(NSString *) pubInfo {
	MizEntityConverter *entityCnvt = [[MizEntityConverter alloc] init];
	NSString *cleanInfo = [entityCnvt convertEntiesInString:pubInfo];

	postInfoLabel.text = cleanInfo;
	[cleanInfo release];
	[entityCnvt release];
}



- (void)runSpinner:(BOOL)value {
	gettingMore = value;
	
    if (gettingMore) {
        activityIndicator.hidden = NO;
        [activityIndicator startAnimating];
		
    } else {
        activityIndicator.hidden = YES;
		
        if ([activityIndicator isAnimating]) {
            [activityIndicator stopAnimating];
        }
		
	}
}


#pragma mark Private methods


- (void)addImage {
//	//	asyncImage = [[[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)] autorelease];
//	asyncImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
//	asyncImage.tag = kPersonPictureTag;
//
//	[self.contentView addSubview:asyncImage];
}

- (void)addNameLabel {
    CGRect rect = CGRectMake(LEFT_OFFSET, 0, LABEL_WIDTH, NAME_HEIGHT);
	
    nameLabel = [[UILabel alloc] initWithFrame:rect];
    nameLabel.font = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
    nameLabel.highlightedTextColor = [UIColor whiteColor];
    nameLabel.backgroundColor = [UIColor clearColor];
	
    [self.contentView addSubview:nameLabel];
}



- (void)addMessageLabel {
    CGRect rect = CGRectMake(LEFT_OFFSET, 30, LABEL_WIDTH, MESSAGE_HEIGHT);
	
    messageLabel = [[UILabel alloc] initWithFrame:rect];
	messageLabel.numberOfLines = 0;
    messageLabel.font = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
	messageLabel.textAlignment = UITextAlignmentLeft;
    messageLabel.highlightedTextColor = [UIColor whiteColor];
    messageLabel.backgroundColor = [UIColor clearColor];
	
    [self.contentView addSubview:messageLabel];
}



- (void)addPostInfoLabel {
    CGRect rect = CGRectMake(LEFT_OFFSET, 50, LABEL_WIDTH, MESSAGE_HEIGHT);
	
    postInfoLabel = [[UILabel alloc] initWithFrame:rect];
    postInfoLabel.font = [UIFont boldSystemFontOfSize:POSTINFO_FONT_SIZE];
	postInfoLabel.textAlignment = UITextAlignmentLeft;
    postInfoLabel.highlightedTextColor = [UIColor whiteColor];
    postInfoLabel.backgroundColor = [UIColor clearColor];
	
    [self.contentView addSubview:postInfoLabel];
}


- (void)addActivityIndicator {
    CGRect rect = CGRectMake(self.frame.origin.x + self.frame.size.width - 35, 10, 20, 20);
	
	
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:rect];
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    activityIndicator.hidden = YES;
	
    [self.contentView addSubview:activityIndicator];
}




@end
