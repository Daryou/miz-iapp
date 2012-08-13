//
//  APersonViewController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 5/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "APersonViewController.h"
#import	"NearbyPeopleViewCell.h"

#import	"MizoonerProfiles.h"

@interface APersonViewController (private)
- (UITableViewCell *)basicPersonInfo:(UITableView *)tableView forPersonAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)personalProfileInfo:(UITableView *)tableView forPersonAtIndexPath:(NSIndexPath *)indexPath;
@end

@implementation APersonViewController
@synthesize	profile, personalView, basicView;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
		Mizoon *miz = [Mizoon sharedMizoon];
//		NSDictionary *personDict = [miz getSelectedPersonDict];

		self.view.frame = CGRectMake(0.0, 0, 320.0, 480.0);
		[self.view viewWithTag:kViewTableViewTag].frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 440.0);
		[self.view viewWithTag:kViewTableViewTag].backgroundColor = [UIColor clearColor];
		self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];

        // Custom initialization
//		profile = [[MizoonerProfiles alloc] initWithDictionary:personDict];	
		profile = [[miz getSelectedPersonProfile] retain];

		hasPersonal = [profile hasPersonalAttributes];
		personalView = [ [APersonProfileView alloc] initWithFrame:CGRectMake(5.0, 5.0, 290.0, 150.0) personalProfile:profile];
		[personalView setPersonalProfileValues:profile];

//		[profile printProfiles];
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
//	[self.view viewWithTag:kViewTableViewTag].backgroundColor = [UIColor clearColor];
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
	MizoonLog(@"---------------> didReceiveMemoryWarning: APersonView");

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[profile release];
	[basicView release];
	[personalView release];
}




#pragma mark Table view methods


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
	
	
	switch ([indexPath section]) {
		case 0:
			return 180.0;
		case 1:{
			float height = [personalView getProfileHeight:profile];
//			MizoonLog(@"Height = %f", height);
			return height+40.0;
		}
		default:
			return 80.0;
	}
	return 80.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//	Mizoon *miz = [Mizoon sharedMizoon];
//	NSDictionary *personDict = [miz getSelectedPersonDict];
//	
//	if (!personDict) {
//		return 1;
//	}
	
	if (hasPersonal) {
		return 2;
	}
	
	return 1;
	
//	NSUInteger numAtt = [[personDict valueForKey:@"num_attrs"] intValue];
//	
//	if (numAtt == 0) 
//		return 1;
//	
//	return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}


/*
- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section {
	
	switch (section) {
		case 0:
			return @"First section"; 
		case 1:
			return @"Second section";                                                                                
		default:
			return  @"WTF";                                                                               
	}
	
}
*/

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = [indexPath section];
	
	if (section == 0) 
		return [self basicPersonInfo: tableView forPersonAtIndexPath: indexPath];
	
	
	return [self personalProfileInfo: tableView forPersonAtIndexPath: indexPath];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


- (void) tableView:(UITableView *) tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *) indexPath {
	
}


#pragma mark private

- (UITableViewCell *)basicPersonInfo:(UITableView *)tableView forPersonAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"PersonCell";	
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	
	if (cell == NULL ) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		basicView = [ [APersonBasicView alloc] initWithFrame:CGRectMake(5.0, 5.0, 290.0, 150.0) personProfile:profile];
		[basicView setProfileValues:profile];

		[cell.contentView addSubview:basicView];
	}
	
	
	return cell;
}



- (UITableViewCell *)personalProfileInfo:(UITableView *)tableView forPersonAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"PersonalProfileCell";	
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == NULL ) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

//		personalView = [ [APersonProfileView alloc] initWithFrame:CGRectMake(5.0, 5.0, 290.0, 150.0) personalProfile:profile];
//		[personalView setPersonalProfileValues:profile];

		[cell.contentView addSubview:personalView];
	}
	
	return cell;
}



@end
