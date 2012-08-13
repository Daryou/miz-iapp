//
//  ExtLocationViewController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 2/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ALocationViewController.h"
#import "PlacesViewController.h"
#import "AsyncImageView.h"
#import	"MizEntityConverter.h"
#import	"MizDataManager.h"
#import	"LocationDetailViewCell.h"
#import	"LocationToolsView.h"
#import	"Mizooner.h"
#import	"NearbyPeopleViewCell.h"


#define LOC_REVIEW_FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 300.0f
#define CELL_CONTENT_MARGIN 10.0f

#define LOCATION_INFO_FONT_SIZE	14

@interface ALocationViewController()  // private methods
//- (NSDictionary *) getLocationStream;
//- (void) setupExtLocationLinks: (UITableViewCell *) cell;
- (UITableViewCell *)tableView:(UITableView *)tableView locationInfoSection:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView locationReviewSection:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView locationToolsSection:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView locationVisitorSection:(NSIndexPath *)indexPath;
- (CGFloat) getReviewHeight;
- (void) assignVisitorValues:(NearbyPeopleViewCell *) cell atRow:(NSUInteger) row;
@end


@implementation ALocationViewController

@synthesize	rootViewController, numSections, hasVisitors, hasReviews;




// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
		self.view.frame = CGRectMake(0.0, 0, 320.0, 460.0);
		[self.view viewWithTag:kViewTableViewTag].frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 440.0);
		[self.view viewWithTag:kViewTableViewTag].backgroundColor = [UIColor clearColor];
		
		self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
		
	}
	return self;
}


- (void)dealloc {
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	MizoonLog(@"---------------> didReceiveMemoryWarning: ExtLocationView");

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[super viewDidUnload];
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	Mizoon *miz = [Mizoon sharedMizoon];
	MizoonLocation *theLocation = [miz getSelectedLocation];
	numSections = 2;
	
	if (theLocation.review && [theLocation.review length] > 1) {
		numSections++;
		hasReviews = YES;
	}
			
	
	if ([miz getVisitors]) {
		numSections++;
		hasVisitors = YES;
	}
	
    return numSections;                                                                                                       
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  

	NSUInteger section = [indexPath section];
	
	
//	Mizoon *miz = [Mizoon sharedMizoon];
//	MizoonLocation *theLocation = [miz getSelectedLocation];
	
	if (section == 0) 
		return 120.0;
	
	if (section == 1) 
		return 65.0;
	
	if (section == 2 && hasVisitors) 
		return	80.0;
	else 
		return [self getReviewHeight];
	

	if (section == 3) 
		return [self getReviewHeight];


	
//	switch (section) {
//		case 0:
//			return 120.0;
//			break;
//
//		case 1:
//			return 65.0;
//			break;
//			
//		case 2:
//		{
//			CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
//			CGSize size = [theLocation.review sizeWithFont:[UIFont systemFontOfSize:LOC_REVIEW_FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
//			CGFloat height = MAX(size.height, 44.0f);
//			
//			return height + (CELL_CONTENT_MARGIN * 2);
//			
//		}
//			
//		default:
//			break;
//	}
	return 150.0; //returns floating point which will be used for a cell row height at specified row index  
}  


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
//	return 1;
	
	if (section == 0)
		return 1;                                                                                                           
	
	if (section == 1)
		return 1;                                                                                                           
	
	if (section==2 && hasVisitors) 
		return	[[Mizoon sharedMizoon] getNumberOfVisitors];
		
    return 1;                                                                                                       
}


/*

- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section {

	Mizoon *miz = [Mizoon sharedMizoon];
	MizoonLocation *theLocation = [miz getSelectedLocation];
	
	if (!theLocation) {
		MizoonLog(@"tableView:TitleForHeaderInSection - placesView is nill!!"); 
		return nil;
	}
	
	switch (section) {
		case 0:
			return theLocation.name; 
		case 1:
			return @"Latest Review";                                                                                
		default:
			return theLocation.name;                                                                                

	}
}
*/

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
	
	if (section == 1) {
		headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 2.0);
		[customView addSubview:headerLabel];
		return nil;
	}

	if (section==2 && hasVisitors) {
		headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
		headerLabel.text = @"Recent Visitors"; 
		[customView addSubview:headerLabel];
		return customView;
	}
	
	headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
	headerLabel.text = @"Latest Review"; 
	[customView addSubview:headerLabel];
	return customView;
	
//
//	switch (section) {
//		case 0:	// create the parent view that will hold header Label
////			customView.frame = CGRectMake(10.0, 70.0, 300.0, 44.0);
//	
//			headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
//			headerLabel.text = theLocation.name;
//			[customView addSubview:headerLabel];
//			break;
//		case 1:
//			headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 2.0);
////			headerLabel.text = @"Learn More"; 
//			[customView addSubview:headerLabel];
//			return nil;
//			break;	
//			
//		case 2:
//			//			customView.frame = CGRectMake(10.0, 370.0, 300.0, 44.0);
//			
//			headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
//			headerLabel.text = @"Latest Review"; 
//			[customView addSubview:headerLabel];
//			break;			
//	}
//	return customView;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44.0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger sec = [indexPath section];
	
	if (sec == 0) 
		return [self tableView: tableView locationInfoSection: indexPath];

	if (sec == 1) 
		return [self tableView: tableView locationToolsSection: indexPath];

	if (sec == 2 && hasVisitors) 
		return [self tableView: tableView locationVisitorSection: indexPath];
	else 
		return [self tableView: tableView locationReviewSection: indexPath];

	if (sec == 3) 
		return [self tableView: tableView locationReviewSection: indexPath];
	
	

//	
//	switch (sec) {
//		case 0:
//			return [self tableView: tableView locationInfoSection: indexPath];
//
//		case 1:
//			return [self tableView: tableView locationToolsSection: indexPath];
//			
//			
//		case 2:
//			return [self tableView: tableView locationReviewSection: indexPath];
//			
//		default:
//			break;
//	}
//	return [self tableView: tableView locationInfoSection: indexPath];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{ 	
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	
	if (section == 2 && hasVisitors) {
		[[Mizoon sharedMizoon] setSelectedVisitor: row];
		[[[Mizoon sharedMizoon] getRootViewController] renderView:A_PERSON_VIEW fromView: PEOPLE_VIEW];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}



#pragma mark private

- (CGFloat) getReviewHeight
{
	MizoonLocation *theLocation = [[Mizoon sharedMizoon] getSelectedLocation];

	CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
	CGSize size = [theLocation.review sizeWithFont:[UIFont systemFontOfSize:LOC_REVIEW_FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	CGFloat height = MAX(size.height, 44.0f);
	
	return height + (CELL_CONTENT_MARGIN * 2);
}



- (UITableViewCell *)tableView:(UITableView *)tableView locationInfoSection:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"ExtLocationInfo";
	NSString *fullAddress;
	Mizoon	*miz = [Mizoon sharedMizoon];
	MizoonLocation *aLocation = [miz getSelectedLocation]; 

	LocationDetailViewCell *cell = (LocationDetailViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		cell = [[[LocationDetailViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier controllerView: self.view] autorelease];
    }
		
	
	cell.addressLbl.text = aLocation.name;
	cell.categoryLbl.text = aLocation.category;
	
	
	if (aLocation.zip && ([aLocation.zip compare:@"0"] != NSOrderedSame)) {
		
		if (aLocation.state)
			fullAddress = [NSString stringWithFormat:@"%@, %@ %@", aLocation.city, aLocation.state, aLocation.zip ];
		else {
			fullAddress = [NSString stringWithFormat:@"%@ %@", aLocation.city, aLocation.zip ];
		}
		
	} else	{
		if (aLocation.state)
			fullAddress = [NSString stringWithFormat:@"%@, %@", aLocation.city,  aLocation.state];
		else 
			fullAddress = [NSString stringWithFormat:@"%@", aLocation.city];
	}

	
	
//	
//	if (aLocation.zip) {
//		if ([aLocation.zip compare:@"0"] == NSOrderedSame) {
//			if (aLocation.state)
//				fullAddress = [NSString stringWithFormat:@"%@, %@", aLocation.city, aLocation.state];
//			else 
//				fullAddress = [NSString stringWithFormat:@"%@", aLocation.city];
//		} else {
//			if (aLocation.state)
//				fullAddress = [NSString stringWithFormat:@"%@, %@ %@", aLocation.city, aLocation.state, aLocation.zip ];
//			else {
//				fullAddress = [NSString stringWithFormat:@"%@ %@", aLocation.city, aLocation.zip ];
//		}
//		
//	} else {
//		if (aLocation.state)
//			fullAddress = [NSString stringWithFormat:@"%@, %@", aLocation.city,  aLocation.state];
//		else 
//			fullAddress = [NSString stringWithFormat:@"%@", aLocation.city];
//	}
		
	cell.cityStateLbl.text = fullAddress;
	
	
//	UIImage *icon = [miz getImageForLocCatrgory: aLocation.category];
//	cell.iconView.image = icon;

//	UIImage *icon = [miz getImageForLoction: aLocation.name catrgory: aLocation.category subType: aLocation.subCategory]; 

	cell.iconView.image = [UIImage imageNamed:aLocation.icon];

	
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView locationVisitorSection:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"LocationVisitorCell";
		
	NearbyPeopleViewCell *cell = (NearbyPeopleViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[[NearbyPeopleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
	} 
	
	// Set up the cell...
	[self assignVisitorValues:cell atRow:[indexPath row]];
	
	return cell;
}




//- (void) assignRowValues:(UITableViewCell *) cell atRow:(NSUInteger) row 
- (void) assignVisitorValues:(NearbyPeopleViewCell *) cell atRow:(NSUInteger) row 
{
	int i=0;	
	NSMutableArray *visitors = [[Mizoon sharedMizoon] getVisitors];
	Mizooner *visitor = (Mizooner *) [visitors objectAtIndex:row];
	MizoonerProfiles *profiles = visitor.profile;
	
	[cell setImage:[profiles getProfileAttrValue: PERSON_PICTURE]];
	[cell setName:visitor.name];
	
	 NSString *value = [profiles getProfileAttrValue: SEX];
	 if (value) {
		[cell setProfile:SEX withValue:value];
		 i++;
	 }
	 value = [profiles getProfileAttrValue: RELATIONSHIP_STATUS];
	 if (value) {
		 [cell setProfile:RELATIONSHIP_STATUS withValue:value];
		 i++;
	 }
	 value = [profiles getProfileAttrValue: INTERESTED_IN];
	 if (value) {
		 [cell setProfile:INTERESTED_IN withValue:value];
		 i++;
	 }
	 value = [profiles getProfileAttrValue: LOOKING_FOR];
	 if ( i<3 && value) {
		 [cell setProfile:LOOKING_FOR withValue:value];
		 i++;
	 }
	 value = [profiles getProfileAttrValue: ABOUT_ME];
	 if ( i<3 && value) {
		 [cell setProfile:ABOUT_ME withValue:value];
		 i++;
	 }	 
	 value = [profiles getProfileAttrValue: NETWORKING];
	 if ( i<3 && value) {
		 [cell setProfile:NETWORKING withValue:value];
		 i++;
	 }
	 value = [profiles getProfileAttrValue: ACTIVITIES];
	 if ( i<3 && value) {
		 [cell setProfile:ACTIVITIES withValue:value];
		 i++;
	 }
	 value = [profiles getProfileAttrValue: FAVORITE_MUSIC];
	 if ( i<3 && value) {
		 [cell setProfile:FAVORITE_MUSIC withValue:value];
		 i++;
	 }	 
	 value = [profiles getProfileAttrValue: FAVORITE_QUOTES];
	 if ( i<3 && value) {
		 [cell setProfile:FAVORITE_QUOTES withValue:value];
		 i++;
	 }
	 value = [profiles getProfileAttrValue: FAVORITE_BOOKS];
	 if ( i<3 && value) {
		 [cell setProfile:FAVORITE_BOOKS withValue:value];
		 i++;
	 }
	 value = [profiles getProfileAttrValue: FAVORITE_TV];
	 if ( i<3 && value) {
		 [cell setProfile:FAVORITE_TV withValue:value];
		 i++;
	 }	
}


	

- (UITableViewCell *)tableView:(UITableView *)tableView locationToolsSection:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"ToolsLocationInfo";
	
	LocationToolsView *cell = (LocationToolsView *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		cell = [[[LocationToolsView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier controllerView: self.view] autorelease];
    }
    return cell;
}



- (UITableViewCell *)tableView:(UITableView *)tableView locationReviewSection:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"ExtLocationInfo";

	Mizoon *miz = [Mizoon sharedMizoon];
	MizoonLocation	*theLocation = [miz getSelectedLocation];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	//	if (sec != 0)
	//		return cell;
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		CGRect addressVR = CGRectMake(60, 10, 220, 18);
		UILabel *addressValue = [[UILabel alloc] initWithFrame:addressVR];
		addressValue.tag = kLocAddressTag;
		addressValue.textAlignment = UITextAlignmentLeft;
		//		addressValue.font = [UIFont systemFontOfSize:10];
		[cell.contentView addSubview:addressValue];
		[addressValue release];
		
		UILabel *reviewLable = [[UILabel alloc] initWithFrame:CGRectZero];
		reviewLable.tag = kLocReviewTag;
		[reviewLable setLineBreakMode:UILineBreakModeWordWrap];
		[reviewLable setMinimumFontSize:LOC_REVIEW_FONT_SIZE];
		[reviewLable setNumberOfLines:0];
		[reviewLable setFont:[UIFont systemFontOfSize:LOC_REVIEW_FONT_SIZE]];
		
		[cell.contentView addSubview:reviewLable];
		[reviewLable release];
		
		
		
    }
	
	UILabel *review = (UILabel *) [cell.contentView viewWithTag: kLocReviewTag];
	review.text = theLocation.review;
	
	CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
	CGSize size = [theLocation.review sizeWithFont:[UIFont systemFontOfSize:LOC_REVIEW_FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	
	[review setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, 44.0f))];
	
    return cell;
}



@end

