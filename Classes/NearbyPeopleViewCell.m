//
//  NearbyPeopleViewCell.m
//  Mizoon
//
//  Created by Daryoush Paknad on 3/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NearbyPeopleViewCell.h"
#import	"MizEntityConverter.h"

#define MAIN_FONT_SIZE	12

#define LEFT_OFFSET		70
#define	LABEL_WIDTH		220
#define	PROFILE_HEIGHT	15
#define	NAME_HEIGHT		30

@interface NearbyPeopleViewCell (private)
- (void) addImage;
- (void)addNameLabel;
- (void)addP1Label;
- (void)addP2Label;
- (void)addP3Label;
- (void)addActivityIndicator;
@end


@implementation NearbyPeopleViewCell
//@synthesize	nameLabel, p1Label, p2Label, p3Label, asyncImage, activityIndicator;


- (id)initWithStyle:(UITableViewCellStyle) style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		UIImage *accessoryImage = [UIImage imageNamed:@"orange-arrow.png"];
		UIImageView *accessoryImageView = [[UIImageView alloc] initWithImage:accessoryImage];
		self.accessoryView = accessoryImageView;
		[accessoryImageView release];
		
		self.selectionStyle = UITableViewCellSelectionStyleGray;

        [self addImage];
		[self addNameLabel];
        [self addP1Label];
		[self addP2Label];
        [self addP3Label];

        [self addActivityIndicator];
		nextProfile = kPersonProfile1Tag;
    }
	
    return self;
}

	
- (void)dealloc 
{
//	NSLog(@"0 -dealloc - refcount=%d", [asyncImage retainCount]);

    [asyncImage release];
	[nameLabel release];
	[p1Label release];
	[p2Label release];
	[p3Label release];
    [activityIndicator release];
	
	[super dealloc];
}


- (void)prepareForReuse{
	[super prepareForReuse]; 

	nameLabel.text = p1Label.text = p2Label.text = p3Label.text = nil;
	nextProfile = kPersonProfile1Tag;
	nameLabel.textColor = [UIColor blackColor];
}


- (void)setImage: (NSString *) imageLink 
{
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


- (void)setProfile:(NSString *) attr withValue: (NSString *) value 
{
	if (!attr) 
		return;
		
	UILabel *profileLabel = (UILabel *) [self.contentView viewWithTag: nextProfile];
	
	NSString *av = [[NSString alloc] initWithFormat:@"%@  %@", attr, value];
	
	MizEntityConverter *entityCnvt = [[MizEntityConverter alloc] init];
	NSString *cleanAV = [entityCnvt convertEntiesInString:av];
	
//	NSLog(@"Profile tag = %d   av= %@", nextProfile, cleanAV);

	profileLabel.text = cleanAV;
	[av release];
	[cleanAV release];
	[entityCnvt release];
	
	nextProfile++;
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
//	asyncImage = [[[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)] autorelease];
//	asyncImage.tag = kPersonPictureTag;

//	AsyncImageView *pImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
//	pImage.tag = kPersonPictureTag;
//	asyncImage = pImage;
//	[self.contentView addSubview:asyncImage];
//	[pImage release];
}


- (void)addNameLabel {
    CGRect rect = CGRectMake(LEFT_OFFSET, 0, LABEL_WIDTH, NAME_HEIGHT);
	
    nameLabel = [[UILabel alloc] initWithFrame:rect];
	nameLabel.font = [UIFont fontWithName:MIZOON_FONT_BOLD size:MAIN_FONT_SIZE+4];
    nameLabel.highlightedTextColor = [UIColor whiteColor];
    nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.tag = kPersonNameTag;
//	[nameLabel setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.0]];

    [self.contentView addSubview:nameLabel];
}



- (void)addP1Label {
    CGRect rect = CGRectMake(LEFT_OFFSET, 30, LABEL_WIDTH, PROFILE_HEIGHT);
	
    p1Label = [[UILabel alloc] initWithFrame:rect];
    p1Label.font = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
	p1Label.textAlignment = UITextAlignmentLeft;
    p1Label.highlightedTextColor = [UIColor whiteColor];
    p1Label.backgroundColor = [UIColor clearColor];
	p1Label.tag = kPersonProfile1Tag;
	
    [self.contentView addSubview:p1Label];
}



- (void)addP2Label {
    CGRect rect = CGRectMake(LEFT_OFFSET, 45, LABEL_WIDTH, PROFILE_HEIGHT);
	
    p2Label = [[UILabel alloc] initWithFrame:rect];
    p2Label.font = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
	p2Label.textAlignment = UITextAlignmentLeft;
    p2Label.highlightedTextColor = [UIColor whiteColor];
    p2Label.backgroundColor = [UIColor clearColor];
	p2Label.tag = kPersonProfile2Tag;
	
    [self.contentView addSubview:p2Label];
}



- (void)addP3Label {
    CGRect rect = CGRectMake(LEFT_OFFSET, 60, LABEL_WIDTH, PROFILE_HEIGHT);
	
    p3Label = [[UILabel alloc] initWithFrame:rect];
    p3Label.font = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
	p3Label.textAlignment = UITextAlignmentLeft;
    p3Label.highlightedTextColor = [UIColor whiteColor];
    p3Label.backgroundColor = [UIColor clearColor];
	p3Label.tag = kPersonProfile3Tag;
	
    [self.contentView addSubview:p3Label];
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
