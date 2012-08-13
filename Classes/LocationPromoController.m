//
//  LocationPromotions.m
//  Mizoon
//
//  Created by Daryoush Paknad on 5/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocationPromoController.h"
#import	"Constants.h"
#import	"AsyncImageView.h"
#import	"MizEntityConverter.h"
#import	"LocationViewCell.h"
#import	"MizoonLocation.h"



@implementation LocationPromoController
@synthesize	selectedRow, promosTableView;


#ifdef	PULL_REFRESH
@synthesize reloading=_reloading;
@synthesize refreshHeaderView;
#endif



// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
				
#if 1		
		UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
		tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
		tableView.delegate = self;
		tableView.dataSource = self;
//		[tableView reloadData];
		self.promosTableView = tableView;
		[self.view addSubview:promosTableView];
		[tableView release];
		
		self.promosTableView.frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 420.0);
		self.promosTableView.backgroundColor = [UIColor whiteColor];
		
#else	
		[self.view viewWithTag:kViewTableViewTag].frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 440.0);
		[self.view viewWithTag:kViewTableViewTag].backgroundColor = [UIColor whiteColor];
#endif
//		self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
		
	}
	return self;
}


- (void)dealloc {
	[promosTableView	release];
    [super dealloc];
}


 - (void)viewDidLoad {
	 [super viewDidLoad];
	 
	 
#ifdef	PULL_REFRESH
	 if (refreshHeaderView == nil) {
		 refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.promosTableView.bounds.size.height, 320.0f, self.promosTableView.bounds.size.height)];
		 refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		 refreshHeaderView.bottomBorderThickness = 1.0;
		 [self.promosTableView addSubview:refreshHeaderView];
		 self.promosTableView.showsVerticalScrollIndicator = YES;
		 [refreshHeaderView release];
	 }
#endif
	 
 }
 


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	MizoonLog(@"---------------> didReceiveMemoryWarning: LocationPromo");

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	return;
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	// Unselect the selected row if any
//	NSIndexPath*	selection = [self.tableView indexPathForSelectedRow];
//	if (selection)
//		[self.tableView deselectRowAtIndexPath:selection animated:YES];
//	
//	[self.tableView reloadData];
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
//
//
//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
//{
//	return UITableViewCellAccessoryDisclosureIndicator;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  	
	return 100.0;
}  



- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section {
	return @"Sales, Coupons and Promotions";                                                                                
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	tableView.separatorColor = [UIColor colorWithRed:71/255.0 green:204/255.0 blue:234/255.0 alpha:1.0];

    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	MizDataManager *md = [MizDataManager sharedDataManager];
	
	MizoonLog(@"Number of locations with promotions = %d", md.promoLocSize);

	return md.promoLocSize;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellLocWithPromo";
	
	MizDataManager	*md = [MizDataManager sharedDataManager];
	NSDictionary *locDict = [md.locationsWithPromos objectAtIndex:indexPath.row];
	MizoonLocation *aLocation = [[MizoonLocation alloc] initLocation:locDict];

//	MizoonLocation *aLocation = [[miz getNthLocation:indexPath.row] retain]; 
		
	
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	LocationViewCell *cell = (LocationViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	
    if (cell == nil) {
		cell = [[[LocationViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

	}
    
    // Set up the cell...
	
//	cell.nameLbl.text = [aLocation valueForKey:@"loc_name"];
	cell.nameLbl.text = aLocation.name;

	
//	NSString *fullAddress = [NSString stringWithFormat:@"%@, %@", [aLocation valueForKey:@"address"], [aLocation valueForKey:@"city"]];	
	NSString *fullAddress = [NSString stringWithFormat:@"%@, %@", aLocation.address, aLocation.city];	

	cell.addressLbl.text = fullAddress;
	
	MizEntityConverter *entityCnvt = [[MizEntityConverter alloc] init];
//	NSString *cleanCat = [entityCnvt convertEntiesInString:[aLocation valueForKey:@"type"]];
	NSString *cleanCat = [entityCnvt convertEntiesInString:aLocation.category];

	cell.categoryLbl.text = cleanCat;

//	UIImage *icon = [miz getImageForLocCatrgory: cleanCat];
//	UIImage *icon = [miz getImageForLoction: [aLocation valueForKey:@"loc_name"] catrgory: [aLocation valueForKey:@"type"] subType: [aLocation valueForKey:@"type2"]]; 
//	cell.iconView.image = icon;
	
	cell.iconView.image = [UIImage imageNamed:aLocation.icon];

	[cleanCat release];
	[entityCnvt release];	
	[aLocation release];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	MizDataManager	*md = [MizDataManager sharedDataManager];
	Mizoon	*miz = [Mizoon sharedMizoon];
	RootViewController *rvc = [miz getRootViewController];
	NSDictionary *aLocation = [md.locationsWithPromos objectAtIndex:indexPath.row]; 

	self.selectedRow = [indexPath row];
//	self.selectedLid = [[aLocation valueForKey:@"lid"] intValue];
	miz.lastSelectedLid = [[aLocation valueForKey:@"lid"] intValue];

	[rvc renderView:PROMOTIONS_VIEW fromView: LOCATIONS_WITH_PROMOTIONS_VIEW];
//	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}





#ifdef	PULL_REFRESH

#pragma mark -
#pragma mark ScrollView Callbacks

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	if (scrollView.isDragging) {
		if (refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		} else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshPulling];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	if (scrollView.contentOffset.y <= - 65.0f && !_reloading) {
		_reloading = YES;
		[self reloadTableViewDataSource];
		[refreshHeaderView setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.promosTableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
}


#pragma mark -
#pragma mark refreshHeaderView Methods

- (void)dataSourceDidFinishLoadingNewData{
	
	_reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.promosTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[refreshHeaderView setState:EGOOPullRefreshNormal];
}


- (void) reloadTableViewDataSource
{
	
	Mizoon *miz=[Mizoon sharedMizoon];	
//	[self performSelector:@selector(stopUpdatingLocation) withObject:@"Timed Out" afterDelay:RELOAD_TIMEOUT ];

	timer = [NSTimer scheduledTimerWithTimeInterval:RELOAD_TIMEOUT 
											 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(havePromoData:)
												 name:@"MZ_Have_Location_Coord" object:nil];
	
	[miz updateLocation];
	
	
	
}



- (void)timeout:(NSTimer*)theTimer {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    MizoonLog(@"Timedout...............................................") ;
	[theTimer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	[[[Mizoon sharedMizoon] getRootViewController] renderView:LOCATIONS_WITH_PROMOTIONS_VIEW fromView: MAIN_VIEW];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"People lookup timeout" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	
	[pool release];
}

//
//- (void)stopUpdatingLocation 
//{
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//	
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
//	[[[Mizoon sharedMizoon] getRootViewController] reloadView:LOCATIONS_WITH_PROMOTIONS_VIEW];
//	
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Promo lookup timeout" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
//	[alert show];
//	[alert release];
//	
//	[pool release];
//}


- (void) havePromoData:(NSNotification *)notification 
{
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];

	[timer invalidate];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	[rvc reloadView:LOCATIONS_WITH_PROMOTIONS_VIEW];
}


#endif




@end

