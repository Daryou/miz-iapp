    //
//  RestaurantViewController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 9/27/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import "RestaurantViewController.h"

#import	"MizoonLocation.h"
#import	"GAConnectionManager.h"
#import	"GAPlace.h"
#import	"NSObject+SBJSON.h"
#import	"LocationViewCell.h"
#import	"MizoonLocation.h"
#import "JSON.h"
//
//@interface  RestaurantViewController (private)
//- (NSString	*) contructSQuery: (NSString *) searchText;		
//@end



@implementation RestaurantViewController


#ifdef	PULL_REFRESH
@synthesize reloading=_reloading;
@synthesize refreshHeaderView;
#endif


@synthesize restaurantTableView;




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
//	geoapiManager_ = [[GAConnectionManager alloc] initWithAPIKey:GEO_API_KEY delegate:self];
//	[geoapiManager_ executeQuery:[self contructSQuery:nil]];
	
	self.view.frame = CGRectMake(0, 22, 320, 620);
	self.view.backgroundColor = [UIColor darkGrayColor];
	
	UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	tableView.delegate = self;
	tableView.dataSource = self;
	//	[tableView reloadData];
	self.restaurantTableView = tableView;
	[self.view addSubview:restaurantTableView];
	[tableView release];
	
	self.restaurantTableView.frame = CGRectMake(0.0, 24.0 , 320.0, 440.0);
	
//	[self.restaurantTableView reloadData];
	
	
#ifdef	PULL_REFRESH
	if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.restaurantTableView.bounds.size.height, 320.0f, self.restaurantTableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		refreshHeaderView.bottomBorderThickness = 1.0;
		[refreshHeaderView retain];
		[self.restaurantTableView addSubview:refreshHeaderView];
		[self.restaurantTableView bringSubviewToFront:refreshHeaderView];
		
		self.restaurantTableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
#endif
	
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	[restaurantTableView release];
//	[geoapiManager_ release];
//	[[Mizoon sharedMizoon].restaurantList release];
//	[Mizoon sharedMizoon].restaurantList = nil;
	
    [super dealloc];
}



#pragma mark Table view methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  
{
	int numRestaurants = [[MizDataManager sharedDataManager].restaurantList count];
	
	if (!numRestaurants)
		return	0;
	
	if ([indexPath section] == 0 && !numRestaurants) 
		return	40;
	
	return 80.0; //returns floating point which will be used for a cell row height at specified row index  
}  

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	int numRestaurants = [[MizDataManager sharedDataManager].restaurantList count];

	if (!numRestaurants)
		return	0;
	
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	int numRestaurants = [[MizDataManager sharedDataManager].restaurantList count];

	if (!numRestaurants) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Unable to locate any restaurants near by right now." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		
		return	0;
	}
	
	if (section==0) {
		if (!numRestaurants) {
			return	2;
		}
		return numRestaurants;
	}
    return 1;
}


- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section 
{
	int numRestaurants = [[MizDataManager sharedDataManager].restaurantList count];

	if (!numRestaurants)
		return	 @"Unable to locate any coffee shops near you";
	
	if (section==0) 
		return @"Restaurants near by";                                                                                
	
	return @"Still can't find it!";                                                                                
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	Mizoon	*miz = [Mizoon sharedMizoon];
    static NSString *EmptyIdentifier = @"EmptyCell";
	static NSString *CellIdentifier = @"PlacesCell";
	
	
	NSUInteger row = [indexPath row];
	
	//	if ([indexPath section] == 0) {
	
	if (![[miz nearbyRestaurnats] count]) {
		UITableViewCell  *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:EmptyIdentifier];
		if (cell == nil) 
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EmptyIdentifier] autorelease];
		return cell;
	}
	
	
	LocationViewCell *cell = (LocationViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[LocationViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];		
	} 
	
	MizoonLocation *aLocation = [[miz nearbyRestaurnats] objectAtIndex:row]; //[self searchGetlocation:row]; 
	
	cell.nameLbl.text = aLocation.name;
	cell.categoryLbl.text = aLocation.distance;
	
	NSString *fullAddress = [NSString stringWithFormat:@"%@, %@", aLocation.address, aLocation.city];	
	cell.addressLbl.text = fullAddress;
	
	
//	UIImage *icon = [miz getImageForLoction: aLocation.name catrgory: aLocation.category subType: aLocation.subCategory]; 
//	cell.iconView.image = icon;
	
	cell.iconView.image = [UIImage imageNamed:aLocation.icon];

	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	Mizoon *miz = [Mizoon sharedMizoon];
	
	[miz setSelectedLocationFromArray: [miz nearbyRestaurnats] atIndex: [indexPath row]];	
	[[miz getRootViewController] renderView:EXTERNAL_LOCATION_VIEW fromView: PLACES_VIEW];
}






#pragma mark Private


- (void) restaurant_haveCoord:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[timer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 	
	
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(renderRestaurnats:) name:@"MZ_Have_Restaurant_Data" object:nil];
	[[MizDataManager sharedDataManager] fetchNearbyRestaurants:nil];
	
	
	[pool release];
}


- (void) renderRestaurnats:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Restaurant_Data" object:nil];	 
	[[[Mizoon sharedMizoon] getRootViewController] reloadView:RESTAURANT_VIEW];
	
	[pool release];	
}





#ifdef	PULL_REFRESH

#pragma mark -
#pragma mark ScrollView Callbacks

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{		
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
		self.restaurantTableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
}


#pragma mark -
#pragma mark refreshHeaderView Methods

- (void)dataSourceDidFinishLoadingNewData{
	
	_reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.restaurantTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[refreshHeaderView setState:EGOOPullRefreshNormal];
}


- (void) reloadTableViewDataSource
{
	MizoonLog(@"Please override reloadTableViewDataSource");
	
	Mizoon *miz=[Mizoon sharedMizoon];	
	
	timer = [NSTimer scheduledTimerWithTimeInterval:RELOAD_TIMEOUT 
											 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
	
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(failedReguest:) name:@"GEOAPI_Request_Failed" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restaurant_haveCoord:) name:@"MZ_Have_Location_Coord" object:nil];
	
	[miz updateLocation];
	
	
	
}



- (void) failedReguest:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Restaurant_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"GEOAPI_Request_Failed" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Can't connect to server. Can you try again."
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert	release];
	[[Mizoon sharedMizoon] hideLoadMessage ];
	[[[Mizoon sharedMizoon] getRootViewController] reloadView:RESTAURANT_VIEW];

	[pool release];
}




- (void)timeout:(NSTimer*)theTimer {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    MizoonLog(@"Timedout...............................................") ;
	[theTimer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	[[[Mizoon sharedMizoon] getRootViewController] renderView:RESTAURANT_VIEW fromView: MAIN_VIEW];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't get your current location" message:@"Can you try again?" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[pool release];
}


#endif



@end
