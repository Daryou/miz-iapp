//
//  CheckedinViewController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CheckedinViewController.h"
#import	"NearbyPeopleViewCell.h"
#import	"RootViewController.h"
#import	"PlacesViewController.h"
#import	"LocationToolsView.h"

#define CELL_CONTENT_WIDTH 220.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CHECKIN_THANKS	@"Thanks for visiting"
#define	CHECKIN_POINTS 20
#define	CHECKIN_POINTS_MSG @"\n\n20 points have been added to your check-in score."

//#define	CHECKIN_POINTS @" points have been added to your check-in score."

#define	CHECKIN_FIRST	@" \n\nYou are the first visitor at this location."


@interface CheckedinViewController (private) 
- (NSString *) getCheckinMessage;
- (void) displayVisitorInfo;
- (UITableViewCell *)tableView:(UITableView *)tableView whatsUpHere:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView locationTools:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView visitorsSection:(NSIndexPath *)indexPath;
@end


@implementation CheckedinViewController


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
 
		self.view.frame = CGRectMake(0.0, 0, 320.0, 460.0);
		[self.view viewWithTag:kViewTableViewTag].frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 440.0);
		[self.view viewWithTag:kViewTableViewTag].backgroundColor = [UIColor clearColor];
		self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	MizoonLog(@"---------------> didReceiveMemoryWarning: CheckedinView");

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark private

- (NSString *) getCheckinMessage
{
	NSString *checkinMsg;
	Mizoon *miz = [Mizoon sharedMizoon];
	MizoonLocation	*theLocation = [miz getSelectedLocation];
	MizDataManager *dm = [MizDataManager sharedDataManager];
	NSUInteger numPeople = dm.locationPeopleSize;

	if (numPeople) 
		checkinMsg = [NSString stringWithFormat:@"%@ %@. %d \nYour total check-in point is %d", CHECKIN_THANKS, theLocation.name,  CHECKIN_POINTS_MSG, [miz getMizoonerPoints]+CHECKIN_POINTS ];
	else 
		checkinMsg = [NSString stringWithFormat:@"%@ %@. %@ \nYour total check-in point is %d %@", CHECKIN_THANKS, theLocation.name,  CHECKIN_POINTS_MSG, [miz getMizoonerPoints]+CHECKIN_POINTS, CHECKIN_FIRST];
	
	return checkinMsg;
}

- (void) displayVisitorInfo {
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *rvc = delegate.rootViewController;
	
	[rvc prepareToDisplay:A_PERSON_VIEW];
	[rvc renderView:A_PERSON_VIEW fromView: CHECKED_IN_VIEW];
}


#pragma mark Table view methods


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
//	headerLabel.font = [UIFont fontWithName:MIZOON_FONT size:16];
	headerLabel.font = [UIFont boldSystemFontOfSize:16];
	
	switch (section) {
		case 0:	// create the parent view that will hold header Label
			//			customView.frame = CGRectMake(10.0, 70.0, 300.0, 44.0);
			
			headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
			headerLabel.text = theLocation.name;
			[customView addSubview:headerLabel];
			break;

		case 1:
			return nil;

		case 2:
			//			customView.frame = CGRectMake(10.0, 370.0, 300.0, 44.0);
			
			headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
			headerLabel.text = @"Visitors"; 
			[customView addSubview:headerLabel];
			break;	
	}
	return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  
{  
	NSUInteger section = [indexPath section];
//	NSString *message;
	NSString *fullMsg;
	MizDataManager *dm = [MizDataManager sharedDataManager];
	NSUInteger numPeople = dm.locationPeopleSize;


//	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//	RootViewController *rvc = delegate.rootViewController;
//	PlacesViewController *placesView = rvc.placesViewController;   	
//	NSArray *places = dm.nearbyPlaces;                                                                               
	
//	Mizoon *miz = [Mizoon sharedMizoon];
//	MizoonLocation	*theLocation = [miz getSelectedLocation];

//	NSDictionary * stream = [places objectAtIndex:placesView.selectedRow];  
	
	switch (section) {
		case 0:
			fullMsg = [self getCheckinMessage];

			CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
			CGSize size = [fullMsg sizeWithFont:[UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
			CGFloat height = MAX(size.height, 44.0f);
			
			return height + (CELL_CONTENT_MARGIN * 2);

		case 1:
			return 65.0;
						
		case 2:
			if (numPeople == 0) {
				return 0;
			} else {
				return 90.0;
			}
			
		default:
			break;
	}
	return 90.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	MizDataManager *dm = [MizDataManager sharedDataManager];
	NSUInteger numPeople = dm.locationPeopleSize;

	if (numPeople == 0) 
		return 2;
	
	return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	MizDataManager *dm = [MizDataManager sharedDataManager];
		
	switch (section) {
		case 0:
			return 1;
		case 1:
			return 1;
		case 2:
			return  dm.locationPeopleSize;
		default:
			break;
	}
	return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = [indexPath section];
	
	if (section == 0) 
		return [self tableView: tableView whatsUpHere: indexPath];

	if (section == 1) 
		return [self tableView: tableView locationTools: indexPath];
	
	return [self tableView: tableView visitorsSection: indexPath];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 	
	NSUInteger row = [indexPath row];
	Mizoon *miz = [Mizoon sharedMizoon];

	if (indexPath.section == 0) 
		return;

	RootViewController *rvc = [miz getRootViewController];
	rvc.prevView = CHECKED_IN_VIEW;  // setSelectedPerson uses the prevView to get the appropriate dictionary from the dm (a vistor on the CHECKEDIN page or a nearbyPerson
	
	[miz setSelectedPerson: row];

	[self displayVisitorInfo];
}


- (void) tableView:(UITableView *) tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *) indexPath {

}



- (UITableViewCell *)tableView:(UITableView *)tableView visitorsSection:(NSIndexPath *)indexPath {
	MizDataManager *dm = [MizDataManager sharedDataManager];
	NSUInteger row = [indexPath row];
	
    static NSString *CellIdentifier = @"VisitorsCell";	
	
	NearbyPeopleViewCell *cell = (NearbyPeopleViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	cell = [[[NearbyPeopleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	/*
	if (cell) {
//		AsyncImageView* oldImage = (AsyncImageView*) [cell.contentView viewWithTag:kPersonPictureTag];
//		[oldImage removeFromSuperview];
//		[cell release];
		[cell cleanPeopleCell];
	} else {
		cell = [[[NearbyPeopleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
*/
	/*
	if (cell == nil) {
		cell = [[[NearbyPeopleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			
	} else {
		AsyncImageView* oldImage = (AsyncImageView*) [cell.contentView viewWithTag:kPersonPictureTag];
		[oldImage removeFromSuperview];
	}
		*/
	
	// Set up the cell...
	NSDictionary *stream = (NSDictionary *)[dm.locationPeople objectAtIndex:row];
	NSString *image = [stream valueForKey:@"pic"];
	
	[cell setImage:image];
	[cell setName:[stream valueForKey:@"name"]];
	[cell setProfile:[stream valueForKey:@"a01"] withValue:[stream valueForKey:@"v01"]];
	[cell setProfile:[stream valueForKey:@"a02"] withValue:[stream valueForKey:@"v02"]];
	[cell setProfile:[stream valueForKey:@"a03"] withValue:[stream valueForKey:@"v03"]];
	
	
	return cell;
}



- (UITableViewCell *)tableView:(UITableView *)tableView locationTools:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"toolsCell";

	LocationToolsView *cell = (LocationToolsView *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		cell = [[[LocationToolsView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier controllerView: self.view] autorelease];
    }
    return cell;
}



- (UITableViewCell *)tableView:(UITableView *)tableView whatsUpHere:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"WhatsUp";
	//	MizDataManager *dm = [MizDataManager sharedDataManager];
	//	NSUInteger numPeople = dm.locationPeopleSize;
	Mizoon *miz = [Mizoon sharedMizoon];
	MizoonLocation	*theLocation = [miz getSelectedLocation];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UILabel *msgLable = [[UILabel alloc] initWithFrame:CGRectZero];
		[msgLable setNumberOfLines:0];
		msgLable.tag = kCheckinMessageTag;
		msgLable.textAlignment = UITextAlignmentLeft;
		[msgLable setLineBreakMode:UILineBreakModeWordWrap];
		msgLable.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];
		
		[cell.contentView addSubview:msgLable];
		[msgLable release];
		
		UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 10.0, 60.0, 60.0)];
		iconView.tag = kIconViewTag;
		
		[cell.contentView addSubview:iconView];
		
    }
	
	NSString *fullMsg;
	fullMsg = [self getCheckinMessage];
	
	//	if (numPeople) 
	//		fullMsg = [NSString stringWithFormat:@"%@ %@. \n\n %d %@", CHECKIN_THANKS, theLocation.name, [miz getMizoonerPoints], CHECKIN_POINTS];
	//	else 
	//		fullMsg = [NSString stringWithFormat:@"%@ %@. \n\n %d%@", CHECKIN_THANKS, theLocation.name, [miz getMizoonerPoints], CHECKIN_POINTS, CHECKIN_FIRST];
	
	UILabel *message = (UILabel *) [cell.contentView viewWithTag: kCheckinMessageTag];
	message.text =  fullMsg;  	
	
	CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
	CGSize size = [fullMsg sizeWithFont:[UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	[message setFrame:CGRectMake(CELL_CONTENT_MARGIN + 60, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, 44.0f))];
	
	
	UIImageView *iconView = (UIImageView *) [cell.contentView viewWithTag: kIconViewTag];
	//	UIImage *icon = [miz getImageForLocCatrgory: theLocation.category];
//	UIImage *icon = [miz getImageForLoction: theLocation.name catrgory: theLocation.category subType: theLocation.subCategory]; 
//	iconView.image = icon;

	iconView.image = [UIImage imageNamed:theLocation.icon];

	
	/******************************
	 MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	 RootViewController *rvc = delegate.rootViewController;
	 PlacesViewController *placesView = rvc.placesViewController;   	
	 NSArray *places = dm.nearbyPlaces;                                                                               
	 
	 NSDictionary * stream = [places objectAtIndex:placesView.selectedRow];  
	 
	 
	 NSString *image = [stream valueForKey:@"image"];
	 CGRect imageVR = CGRectMake(5, 10, 40, 40);	
	 AsyncImageView* asyncImage = [[[AsyncImageView alloc] initWithFrame:imageVR] autorelease];
	 asyncImage.tag = kLocImageTag;
	 NSString *imageUrl = [NSString stringWithFormat:@"%@%@", MIZOON_HOST, image];
	 NSURL *url = [[NSURL alloc] initWithString:imageUrl];
	 [asyncImage loadImageFromURL:url];
	 [cell.contentView addSubview:asyncImage];
	 
	 
	 NSString *fullMsg;
	 if (numPeople) 
	 fullMsg = [NSString stringWithFormat:@"%@ %@. %@", CHECKIN_THANKS, [stream valueForKey:@"loc_name"], CHECKIN_POINTS];
	 else 
	 fullMsg = [NSString stringWithFormat:@"%@ %@. %@%@", CHECKIN_THANKS, [stream valueForKey:@"loc_name"], CHECKIN_POINTS, CHECKIN_FIRST];
	 
	 UILabel *message = (UILabel *) [cell.contentView viewWithTag: kCheckinMessageTag];
	 message.text =  fullMsg;  //[stream valueForKey:@"address"];
	 
	 
	 CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
	 CGSize size = [fullMsg sizeWithFont:[UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	 [message setFrame:CGRectMake(CELL_CONTENT_MARGIN + 60, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, 44.0f))];
	 
	 //	[fullMsg release];
	 ****/	
    return cell;
}





@end
