//
//  PlacesViewController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 1/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PlacesViewController.h"
#import "MizoonServer.h"
#import "AsyncImageView.h"
#import	"MizEntityConverter.h"
#import	"MizProgressHUD.h"
#import "MizDataManager.h"
#import	"LocationViewCell.h"
#import "EGORefreshTableHeaderView.h"
#import	"LocationController.h"

#import	"GAConnectionManager.h"
#import	"NSString+SBJSON.h"
#import	"JSON.h"


@interface  PlacesViewController(Private)
- (NSString	*) contructSQuery: (NSString *) searchText;
@end

@implementation PlacesViewController
//@synthesize places;
//@synthesize placesList;
@synthesize	selectedRow;


@synthesize	rootViewController, progressAlert;

#ifdef	PULL_REFRESH
@synthesize reloading=_reloading;
@synthesize refreshHeaderView;
#endif
@synthesize	placesTableView, theSearchBar;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

		
		UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
		tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
		tableView.delegate = self;
		tableView.dataSource = self;
//		[tableView reloadData];
		self.placesTableView = tableView;
		[self.view addSubview:placesTableView];
		[tableView release];
	
		self.placesTableView.frame = CGRectMake(0.0, TOP_BAR_WITH+30, 320.0, 440.0);
//		self.placesTableView.tableHeaderView = theSearchBar;
		
		self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
		
#if 1
		theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, TOP_BAR_WITH, 320.0f, 30.0f)];
		theSearchBar.delegate = self;
		theSearchBar.placeholder = @"Don't see the place.. search for it";
		[self.view addSubview:theSearchBar];
#endif
	}
	
	return self;
}


- (void)viewDidLoad 
{
	
#ifdef	PULL_REFRESH
	if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.placesTableView.bounds.size.height, 320.0f, self.placesTableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		refreshHeaderView.bottomBorderThickness = 1.0;
		[refreshHeaderView retain];
		[self.placesTableView addSubview:refreshHeaderView];
		[self.placesTableView bringSubviewToFront:refreshHeaderView];

		self.placesTableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
#endif
	[super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	MizoonLog(@"---------------> didReceiveMemoryWarning: PlacesView");
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	
	//	self.placesList = nil;
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	//	[super veiwDidUnload];
}



- (void)dealloc 
{
	[placesTableView	release];
	[progressAlert	release];
	[theSearchBar	release];
//	[geoapiManager_	release];
	
    [super dealloc];
}



#pragma mark Private



- (void) refresh
{
	Mizoon *miz=[Mizoon sharedMizoon];
	
	[self performSelector:@selector(stopUpdatingLocation) withObject:@"Timed Out" afterDelay:RELOAD_TIMEOUT ];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(places_haveLocationCoord:)
												 name:@"MZ_Have_Location_Coord" object:nil];	
	[miz updateLocation];

	progressAlert = [[MizProgressHUD alloc] initWithLabel:@"Locating..."];
	[progressAlert show];

//	[rvc renderView:PLACES_VIEW fromView: MAIN_VIEW];

	MizoonLog(@"Refreshing");
}


- (void) places_haveLocationCoord:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	
#ifdef MIZOON_DEBUG
	NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:[Mizoon sharedMizoon].methodStart];
	DebugLog(@"--> Loc coord fetch time=%f", executionTime);
#endif
	
	[timer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	
 	
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(renderPlaces:) name:@"MZ_Have_Places_Data" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(failedReguest:) name:@"GEOAPI_Request_Failed" object:nil];

	[[MizDataManager sharedDataManager] fetchNearbyPlaces:nil];
	
	[pool release];
}


- (void) failedReguest:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Places_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"GEOAPI_Request_Failed" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Search_Data" object:nil];	


	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Can't connect to server. Can you try again."
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert	release];
	
	[[Mizoon sharedMizoon] hideLoadMessage ];

	[pool release];
}



- (void) searchRequestFailed:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Places_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"GEOAPI_Request_Failed" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Search_Data" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SG_Not_Expected_Return" object:nil];	

	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
													message:@"Couldn't find the place you were looking for. Please try again in a few minutes."
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert	release];
	
	[[Mizoon sharedMizoon] hideLoadMessage ];
	
	[pool release];
}




- (void) renderPlaces:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Places_Data" object:nil];	
	
	[[[Mizoon sharedMizoon] getRootViewController] reloadView:PLACES_VIEW];
	
	[pool release];	
}



#pragma mark Table view methods


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
	return 70.0; //80.0; //returns floating point which will be used for a cell row height at specified row index  
}  

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{	
#ifdef GET_DATA_FROM_MIZOON 
	MizDataManager *dm = [MizDataManager sharedDataManager];

    return [dm.nearbyPlaces count] + 1;
#else
	if ([[[Mizoon sharedMizoon] nearbyLocations] count] == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Unable to locate places near by right now." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[alert show];
		[alert release];

		return 0;
	}
	MizoonLog(@"Number of places = %d", [[[Mizoon sharedMizoon] nearbyLocations] count]);
	return [[[Mizoon sharedMizoon] nearbyLocations] count];
#endif
}

//
//- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section {
//	return @"Places near you";                                                                                
//}
//

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	Mizoon	*miz = [Mizoon sharedMizoon];
#ifdef GET_DATA_FROM_MIZOON
	NSUInteger dataCount = [[MizDataManager sharedDataManager].nearbyPlaces count];
#else
	NSUInteger dataCount = [[[Mizoon sharedMizoon] nearbyLocations] count];
#endif
    static NSString *CellIdentifier = @"PlacesCell";
	static NSString *searchCellIdentifier = @"SearchCell";

	NSUInteger row = [indexPath row];

	if (row == dataCount) {
		
		UITableViewCell  *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
		
		
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCellIdentifier] autorelease];
			UIView *cellView = [[cell subviews] objectAtIndex:0];
			[cellView setBackgroundColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0]];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			
			UILabel *searchCell =[[UILabel alloc]initWithFrame: CGRectMake(10,10,320,30)];
			searchCell.textColor = [UIColor blackColor];
			searchCell.backgroundColor = [UIColor clearColor];
			searchCell.textAlignment=UITextAlignmentCenter;
			searchCell.font=[UIFont boldSystemFontOfSize:12];
			searchCell.numberOfLines = 0;
			searchCell.lineBreakMode = UILineBreakModeWordWrap;
			searchCell.text= @"Don't see the place you are looking for? \nTap here  to search for it.";
			[cell.contentView addSubview:searchCell];
		}
		return cell;

	} else {
		LocationViewCell *cell = (LocationViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		
		if (cell == nil) {
			cell = [[[LocationViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];		
		} 
		
		MizoonLocation *aLocation = [[miz getNthLocation:row] retain]; 
	
		cell.nameLbl.text = aLocation.name;
//		cell.categoryLbl.text = aLocation.distance;  holds the distance

		NSString *fullAddress = [NSString stringWithFormat:@"%@, %@", aLocation.address, aLocation.city];	
		cell.addressLbl.text = fullAddress;
	
	
//		UIImage *icon = [miz getImageForLoction: aLocation.name catrgory: aLocation.category subType: aLocation.subCategory]; 
//		cell.iconView.image = icon;
		
		cell.iconView.image = [UIImage imageNamed:aLocation.icon];

		cell.location = aLocation;
		[aLocation release];
		
		return cell;
	}
		
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Mizoon *miz = [Mizoon sharedMizoon];
//#ifdef GET_DATA_FROM_MIZOON
//	NSUInteger dataCount = [[MizDataManager sharedDataManager].nearbyPlaces count];
//#else
//	NSUInteger dataCount = [[[Mizoon sharedMizoon] nearbyLocations] count];
//#endif	

	
	
	[miz setSelectedLocationAtRow:[indexPath row]];

	self.selectedRow = [indexPath row];
	[self.rootViewController renderView:EXTERNAL_LOCATION_VIEW fromView: PLACES_VIEW];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
		self.placesTableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
}
	
	
#pragma mark -
#pragma mark refreshHeaderView Methods

- (void)dataSourceDidFinishLoadingNewData{
	
	_reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.placesTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[refreshHeaderView setState:EGOOPullRefreshNormal];
}
	
	
- (void) reloadTableViewDataSource
{
//	MizoonLog(@"Please override reloadTableViewDataSource");

	Mizoon *miz=[Mizoon sharedMizoon];	
	
	timer = [NSTimer scheduledTimerWithTimeInterval:RELOAD_TIMEOUT 
											 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];

#ifdef MIZOON_DEBUG
	[Mizoon sharedMizoon].methodStart  = [NSDate date];
#endif
	
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(failedReguest:) name:@"GEOAPI_Request_Failed" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(places_haveLocationCoord:) name:@"MZ_Have_Location_Coord" object:nil];
	
	[miz updateLocation];
	
	
	
}



- (void)timeout:(NSTimer*)theTimer {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    MizoonLog(@"Timedout...............................................") ;
	
	[theTimer invalidate];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Search_Data" object:nil];	

	
	[[[Mizoon sharedMizoon] getRootViewController] renderView:PLACES_VIEW fromView: MAIN_VIEW];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't get your current location" message:@"Can you try again?" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
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
//	[[[Mizoon sharedMizoon] getRootViewController] reloadView:PLACES_VIEW];
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"location lookup timeout" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
//	[alert show];
//	[alert release];
//	
//	[pool release];
//}


#endif


#pragma mark UISearchBarDelegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText 
{
//	[geoapiManager_ executeQuery:[self contructSQuery:searchText]];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar 
{
	[self searchBar:searchBar activate:YES];
	//	NSLog(@"searchBarTextDidBeginEditing");
	
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar 
{
	//	NSLog(@"searchBarTextDidEndEditing");
	
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	// Clear the search text
	// Deactivate the UISearchBar
	searchBar.text=@"";
	[self searchBar:searchBar activate:NO];
	//	NSLog(@"searchBarCancelButtonClicked");
	
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{
//	[geoapiManager_ executeQuery:[self contructSQuery:searchBar.text]];
	
	[[Mizoon sharedMizoon] showLoadMessage: @"Searching..." ];

	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(failedReguest:) name:@"GEOAPI_Request_Failed" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(havePlacesData:) name:@"MZ_Have_Search_Data" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(failedToFetchData:) name:@"MZ_NO_Data" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(searchRequestFailed:) name:@"SG_Not_Expected_Return" object:nil];

	// Since we are handling the NO_DATA situation here, remove the MizData handler
	[[NSNotificationCenter defaultCenter] removeObserver:[MizDataManager sharedDataManager] name:@"MZ_NO_Data" object:nil];	
    
//    timer = [NSTimer scheduledTimerWithTimeInterval:RELOAD_TIMEOUT 
//											 target:self selector:@selector(searchTimeout:) userInfo:nil repeats:NO];
    


	[[MizDataManager sharedDataManager] placesSearch: searchBar.text];
//	[[MizDataManager sharedDataManager] placeRegExpSearch: searchBar.text];

	
	[self searchBar:searchBar activate:NO];
	//		
	//	[self.placesTableView removeAllObjects];
	//	[self.placesTableView addObjectsFromArray:results];
	//	[self.placesTableView reloadData];
//	NSLog(@"searchBarSearchButtonClicked");
}





- (void)searchTimeout:(NSTimer*)theTimer {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    MizoonLog(@"Timedout...............................................") ;
	
	[theTimer invalidate];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Search_Data" object:nil];	
    
	
	[[[Mizoon sharedMizoon] getRootViewController] renderView:PLACES_VIEW fromView: MAIN_VIEW];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't find what you were searching for. " message:@"Can you try again?" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	
	[pool release];
}



- (void) havePlacesData:(NSNotification *)notification 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[placesTableView reloadData];
	[[Mizoon sharedMizoon] hideLoadMessage ];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Search_Data" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_NO_Data" object:nil];	

	[pool release];
}

- (void) failedToFetchData:(NSNotification *)notification 
{
    /*
	[[Mizoon sharedMizoon] hideLoadMessage];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
													message:@"Couldn't find the place you were looking for. Please try again in a few minutes."
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert	release];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Search_Data" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_NO_Data" object:nil];	

//	[[Mizoon sharedMizoon] hideLoadMessage ];
//	[[[Mizoon sharedMizoon] getRootViewController] popView];
//	[[[Mizoon sharedMizoon] getRootViewController] reloadView:PLACES_VIEW];
  */  
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Places_Data" object:nil];	 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"GEOAPI_Request_Failed" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Search_Data" object:nil];	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Search_Data" object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_NO_Data" object:nil];	

    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
													message:@"Couldn't find the place you were looking for. Please try again in a few minutes."
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];	[alert show];
	[alert	release];
	
	[[Mizoon sharedMizoon] hideLoadMessage ];
    
	[pool release];

}


- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active
{	
//	NSLog(@"searchBar activate");
	
	//	self.searchTableView.allowsSelection = !active;
	//	self.searchTableView.scrollEnabled = !active;
	if (!active) {
		//		[disableViewOverlay removeFromSuperview];
		[searchBar resignFirstResponder];
	} else {
		//		self.disableViewOverlay.alpha = 0;
		//		[self.view addSubview:self.disableViewOverlay];
		//		
		//		[UIView beginAnimations:@"FadeIn" context:nil];
		//		[UIView setAnimationDuration:0.5];
		//		self.disableViewOverlay.alpha = 0.6;
		//		[UIView commitAnimations];
		
		// probably not needed if you have a details view since you 
		// will go there on selection
		//		NSIndexPath *selected = [self.searchTableView 
		//								 indexPathForSelectedRow];
		//		if (selected) {
		//			[self.searchTableView deselectRowAtIndexPath:selected 
		//												animated:NO];
		//		}
	}
	[searchBar setShowsCancelButton:active animated:YES];
}



@end

