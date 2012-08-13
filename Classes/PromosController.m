//
//  PromosController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PromosController.h"
#import	"Constants.h"
#import	"AsyncImageView.h"
#import	"MizEntityConverter.h"

@implementation PromosController
@synthesize	selectedRow, selectedLid, selectedPrid;





// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
//		self.view.frame = CGRectMake(0.0, 0, 320.0, 480.0);
//		[self.view viewWithTag:kViewTableViewTag].frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 440.0);
//		[self.view viewWithTag:kViewTableViewTag].backgroundColor = [UIColor whiteColor];
//		
//		self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
//		
	}
	return self;
}


 - (void)viewWillAppear:(BOOL)animated {
	 
	 [super viewWillAppear:animated];
	 
	 MizDataManager *md = [MizDataManager sharedDataManager];
	 NSDictionary *aPromo = [md.promotions objectAtIndex:0]; 
	 
	 if ( md.promoSize == 1 && [[aPromo valueForKey:@"type"] isEqualToString:@"full_coupon"] )
		 MizoonLog(@"Load the UIWebView stuff instead");
	 else 
		 MizoonLog(@"Load the promo list");
 }
 



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.frame = CGRectMake(0.0, 0, 320.0, 480.0);
	[self.view viewWithTag:kViewTableViewTag].frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 440.0);
	[self.view viewWithTag:kViewTableViewTag].backgroundColor = [UIColor whiteColor];
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
	[self.view bringSubviewToFront:[self.view viewWithTag:kViewTableViewTag]];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	MizoonLog(@"---------------> didReceiveMemoryWarning: PromosController");

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}




#pragma mark Table view methods



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  	
	MizDataManager *md = [MizDataManager sharedDataManager];
	NSDictionary *aPromo = [md.promotions objectAtIndex:0]; 

	NSUInteger section = [indexPath section];

	if ( section == 0 ) {
		if ( md.promoSize == 1 && [[aPromo valueForKey:@"type"] isEqualToString:@"full_coupon"] )
			MizoonLog(@"Need to get the height for the coupon");

		return 100.0;
	}
	
	return 0;
}  

//
//
//- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section 
//{
//#if 1
//	Mizoon *miz=[Mizoon sharedMizoon];
//	MizoonLocation *theLocation = [miz getSelectedLocation];
//	
//	if ( section == 0 ) 
//		return theLocation.name;
//	
//	return @"Sales, Coupons and Propmotions";   
//#else
//	MizDataManager *md = [MizDataManager sharedDataManager];
//	NSDictionary *aPromo = [md.promotions objectAtIndex:1]; 
//	
//	if ( section == 0 ) 
//		return [aPromo valueForKey:@"loc_name"];
//		
//	return @"Sales, Coupons and Propmotions";   
//#endif
//}




- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	Mizoon *miz = [Mizoon sharedMizoon];
	MizoonLocation *theLocation = [miz getSelectedLocation];
	
	UIView* customView = [[UIView alloc] initWithFrame:CGRectZero];
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:16];
	
	if (section == 0) {
		headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
		headerLabel.text = theLocation.name;
		[customView addSubview:headerLabel];
		return customView;
	}
		
	headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
	headerLabel.text = @"Sales, Coupons and Propmotions"; 
	[customView addSubview:headerLabel];
	return customView;
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	MizDataManager *md = [MizDataManager sharedDataManager];
	
	return md.promoSize;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellPromo";
	
	MizDataManager	*md = [MizDataManager sharedDataManager];
	NSDictionary *promo = [md.promotions objectAtIndex:indexPath.row]; 
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		UIImage *accessoryImage = [UIImage imageNamed:@"orange-arrow.png"];
		UIImageView *accessoryImageView = [[UIImageView alloc] initWithImage:accessoryImage];
		cell.accessoryView = accessoryImageView;
		[accessoryImageView release];
		
		UILabel *promoDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 220, 18)];
		promoDescLabel.tag = kPromoDescTag;
		promoDescLabel.textAlignment = UITextAlignmentLeft;
		promoDescLabel.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];
		[cell.contentView addSubview:promoDescLabel];
		[promoDescLabel release];
				
		UILabel *expLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 70, 220, 18)];
		expLabel.tag = kExpirationTag;
		expLabel.textAlignment = UITextAlignmentLeft;
		expLabel.font = [UIFont systemFontOfSize:12];
		[cell.contentView addSubview:expLabel];
		[expLabel release];
		
		UIImageView *iconView = [[[UIImageView alloc] initWithFrame:CGRectMake(10, 15.0, 50.0, 50.0)] autorelease];
		iconView.tag = kLocationIconTag;
		[cell.contentView addSubview:iconView];
	}
    
	// Set up the cell...      
	
	/*
	NSString *image = [promo valueForKey:@"img"];
	
	AsyncImageView* asyncImage = [[[AsyncImageView alloc] initWithFrame: CGRectMake(10, 15, 50, 50)] autorelease];
	asyncImage.tag = kLocImageTag;
	NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", MIZOON_HOST, image];
    NSURL *url = [[NSURL alloc] initWithString:imageUrl];
	[asyncImage loadImageFromURL:url];
	[cell.contentView addSubview:asyncImage];
	*/
	
	UIImageView *iconView = (UIImageView *) [cell.contentView viewWithTag: kLocationIconTag];
	NSString *type = [promo valueForKey:@"type"];
	if ([type isEqualToString:@"promo"]) 
		iconView.image = [UIImage imageNamed:@"promo.jpg"];
	else
		iconView.image = [UIImage imageNamed:@"coupon-1.png"];
	
	
	UILabel *promoDescLabel = (UILabel *) [cell.contentView viewWithTag: kPromoDescTag];
	promoDescLabel.text = [promo valueForKey:@"name"];

	NSDate *expiration = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[[promo valueForKey:@"expiration"] doubleValue]];
	NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormat setDateStyle:NSDateFormatterShortStyle];
	NSString *dateString = [dateFormat stringFromDate:expiration];
//	MizoonLog(@"Date: %@", dateString);
	
	
	UILabel *expLabel = (UILabel *) [cell.contentView viewWithTag: kExpirationTag];
	NSString *expires = [[NSString alloc] initWithFormat:@"Expiration: %@", dateString];
	
	expLabel.text = expires;
	[expires release];
//	[dateFormat release];
//	[expiration release];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Mizoon *miz = [Mizoon sharedMizoon];
	MizDataManager	*md = [MizDataManager sharedDataManager];
	NSDictionary *aPromo = [md.promotions objectAtIndex:indexPath.row]; 
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *rvc = delegate.rootViewController;
	
	miz.sPromoLid = self.selectedLid = [[aPromo valueForKey:@"lid"] intValue];
	self.selectedPrid = [[aPromo valueForKey:@"prid"] intValue];
	miz.sPromoRow = self.selectedRow = [indexPath row];
	miz.sPromoDict = aPromo;
	
	[rvc renderView:A_PROMOTION_VIEW fromView: PROMOTIONS_VIEW];
}



@end
