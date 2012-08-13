//
//  NewPlaceViewController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 8/26/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import "NewLocationViewController.h"
#import	"Mizoon.h"


@interface  NewLocationViewController (private)
- (void) initTextfield: (UITextField *) textfield withPlaceholder: (NSString *) placeholder;

@end

@implementation NewLocationViewController
@synthesize	NLTableView, locName, locDescription, catPicker, subCatPicker;


#pragma mark -
#pragma mark View lifecycle



/*
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
*/


- (void)viewDidLoad 
{
    [super viewDidLoad];

	self.view.frame = [[UIScreen mainScreen] applicationFrame];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];

	UITableView *nltable = [[UITableView alloc] initWithFrame:CGRectMake(0, TOP_BAR_WITH, 320, 480) style:UITableViewStyleGrouped];
	nltable.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	nltable.delegate = self;
	nltable.dataSource = self;
	nltable.backgroundColor = [UIColor clearColor];
	nltable.separatorStyle = UITableViewCellSeparatorStyleNone;
	nltable.separatorColor = [UIColor clearColor];

	self.NLTableView = nltable;
	[self.view addSubview:NLTableView];
	[nltable release];
	
	
	locName = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 250, 35)];
	[self initTextfield: locName withPlaceholder: @"Location name" ];

	locDescription = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 250, 35)];
	[self initTextfield: locDescription withPlaceholder: @"Location description (Optional)" ];	
}


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



#pragma mark private

- (void) initTextfield: (UITextField *) textfield withPlaceholder: (NSString *) placeholder
{
	
	[textfield initWithFrame:CGRectMake( 10.0f,10.0f,250.0f,30.0f)];
	
	textfield.placeholder = placeholder;	
	textfield.keyboardType = UIKeyboardTypeDefault;
	textfield.backgroundColor = [UIColor whiteColor];
	textfield.autocorrectionType = UITextAutocorrectionTypeYes;
	textfield.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	textfield.textAlignment = UITextAlignmentLeft;
	textfield.clearButtonMode = UITextFieldViewModeNever;
	textfield.font = [UIFont fontWithName:MIZOON_FONT size:15.0f];
	
	textfield.delegate = self;
	
	[textfield setEnabled:YES];
}



#pragma mark -
#pragma mark Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  
{
	if ([indexPath section] == 0 ) 
		return	40;
	
	return 80.0; //returns floating point which will be used for a cell row height at specified row index  
}  


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section==0) 
		return 2;
	
	return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *LocNameCellIdentifier = @"LocNameCell";
	static NSString *CatCellIdentifier = @"CatCell";
	static NSString *DescCellIdentifier = @"DescriptionCell";
	
	tableView.separatorColor = [UIColor clearColor];

	if ([indexPath section] == 0 ) {
		if ([indexPath row] == 0 ) {
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LocNameCellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LocNameCellIdentifier] autorelease];
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.backgroundColor = [UIColor whiteColor];

				[cell.contentView addSubview: locName];
//				UILabel *catLbl = [[UILabel alloc] initWithFrame: CGRectMake(10.0f, 10.0f, 250.0f, 35)];
//				catLbl.textAlignment = UITextAlignmentLeft;
//				catLbl.font = [UIFont fontWithName:MIZOON_FONT_BOLD size:LOCATION_INFO_FONT_SIZE];
//				catLbl.textColor = [UIColor colorWithRed:64/255.0 green:142/255.0 blue:206/255.0 alpha:1.0];
//				
//				catLbl.text = @"Category1";
//				[cell.contentView addSubview:catLbl];	
//				[catLbl release];
				
			}
			return cell;
		}
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CatCellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CatCellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			
			UILabel *catLbl = [[UILabel alloc] initWithFrame: CGRectMake(10.0f, 10.0f, 250.0f, 35)];
			catLbl.textAlignment = UITextAlignmentLeft;
			catLbl.font = [UIFont fontWithName:MIZOON_FONT_BOLD size:LOCATION_INFO_FONT_SIZE];
			catLbl.textColor = [UIColor colorWithRed:64/255.0 green:142/255.0 blue:206/255.0 alpha:1.0];
			
			catLbl.text = @"Category";
			[cell.contentView addSubview:catLbl];	
			[catLbl release];
			
		}
		return cell;
	}
	
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DescCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DescCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.backgroundColor = [UIColor whiteColor];

		[cell.contentView addSubview: locDescription];
	//	UILabel *catLbl = [[UILabel alloc] initWithFrame: CGRectMake(10.0f, 10.0f, 250.0f, 35)];
//		catLbl.textAlignment = UITextAlignmentLeft;
//		catLbl.font = [UIFont fontWithName:MIZOON_FONT_BOLD size:LOCATION_INFO_FONT_SIZE];
//		catLbl.textColor = [UIColor colorWithRed:64/255.0 green:142/255.0 blue:206/255.0 alpha:1.0];
//		
//		catLbl.text = @"Category2";
//		[cell.contentView addSubview:catLbl];	
//		[catLbl release];
		
	}
	return cell;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

#pragma mark textfield delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	MizoonLog(@"textFieldDidEndEditing");	
}


- (void) textFieldDidBeginEditing:(UITextField *)textField
{
	MizoonLog(@"textFieldDidBeginEditing");	
//	[self moveViewUp];
}


- (BOOL) textFieldShouldReturn: (UITextField *) textField 
{
	[textField becomeFirstResponder];
	MizoonLog(@"textFieldShouldReturn");	
	return NO;
}



#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

