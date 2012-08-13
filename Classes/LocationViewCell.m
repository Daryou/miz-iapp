//
//  LocationViewCell.m
//  Mizoon
//
//  Created by Daryoush Paknad on 8/14/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import "LocationViewCell.h"
#import	"Constants.h"


@implementation LocationViewCell
@synthesize	nameLbl, addressLbl, categoryLbl, iconView, location;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		self.selectionStyle = UITableViewCellSelectionStyleGray;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
		self.backgroundColor = [UIColor	grayColor];
		UIImage *accessoryImage = [UIImage imageNamed:@"orange-arrow.png"];
		UIImageView *accessoryImageView = [[UIImageView alloc] initWithImage:accessoryImage];
		self.accessoryView = accessoryImageView;
		[accessoryImageView release];
		
		
		
		nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 220, 18)];
		nameLbl.textAlignment = UITextAlignmentLeft;
		nameLbl.font = [UIFont fontWithName:MIZOON_FONT_BOLD size:LOCATION_INFO_FONT_SIZE];

		[self.contentView addSubview:nameLbl];
		[nameLbl release];
		
		addressLbl = [[UILabel alloc] initWithFrame:CGRectMake(70, 30, 220, 18)];
		addressLbl.textAlignment = UITextAlignmentLeft;
		addressLbl.font = [UIFont fontWithName:MIZOON_FONT size:LOCATION_INFO_FONT_SIZE];

		[self.contentView addSubview:addressLbl];
		[addressLbl	release];
		
//		categoryLbl = [[UILabel alloc] initWithFrame:CGRectMake(70, 60, 220, 18)];
//		categoryLbl.textAlignment = UITextAlignmentLeft;
//		categoryLbl.font = [UIFont fontWithName:MIZOON_FONT size:12];
//
//		[self.contentView addSubview:categoryLbl];
//		[categoryLbl release];
//		
		iconView = [[[UIImageView alloc] initWithFrame:CGRectMake(5, 10.01, 50.0, 50.0)] autorelease];
		[self.contentView addSubview:iconView];
//		NSLog(@"1 - Ref count = %d", [iconView retainCount]);
//		[iconView release];
//		NSLog(@"2 - Ref count = %d", [iconView retainCount]);

    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[super dealloc];
}


@end
