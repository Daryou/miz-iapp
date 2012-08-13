//
//  NearbyPeopleController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 2/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NearbyPeopleController.h"
#import "MizoonServer.h"
#import "AsyncImageView.h"
#import	"MizEntityConverter.h"
#import "MizDataManager.h"
#import	"MizProgressHUD.h"
#import	"NearbyPeopleViewCell.h"

#define FOLLOWUP_FONT_SIZE	12
#define DATA_COLUMN_X		70

@interface NearbyPeopleController()  // private methods
- (void) setupRowLayout: (UITableViewCell *) cell;
- (void) assignRowValues:(UITableViewCell *) cell atRow:(NSUInteger) row;
- (void)addCellActivityIndicator: (UITableViewCell *) cell;
- (void)runPiespinner:(BOOL)gettingMore;
- (void) removeSpinnerFromCell:(NSIndexPath *)indexPath;
- (void) removeSpinnerFromCell:(NSIndexPath *)indexPath;
@end


@implementation NearbyPeopleController
//@synthesize nearbyPeople;
@synthesize	selectedRow, peopleTableView, selectPath;


#ifdef	PULL_REFRESH
@synthesize reloading=_reloading;
@synthesize refreshHeaderView;
#endif



// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
		UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
		tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
		tableView.delegate = self;
		tableView.dataSource = self;
//		[tableView reloadData];
		self.peopleTableView = tableView;
		[self.view addSubview:peopleTableView];
		[tableView release];
		
		self.peopleTableView.frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 420.0);
		self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
	}
	return self;
}


- (void)dealloc 
{

	[loadMore release];
	[activityIndicator release];
	[peopleTableView release];
	[super dealloc];
}


- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	
#ifdef	PULL_REFRESH
	if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.peopleTableView.bounds.size.height, 320.0f, self.peopleTableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		refreshHeaderView.bottomBorderThickness = 1.0;
		[self.peopleTableView addSubview:refreshHeaderView];
		self.peopleTableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
#endif
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	MizoonLog(@"---------------> didReceiveMemoryWarning: NearbyPeople");

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


#pragma mark private

- (void) displayPersonInfo: (NSUInteger) row 
{
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	
	[rvc renderView:A_PERSON_VIEW fromView: PEOPLE_VIEW];
}



- (void)addCellActivityIndicator: (UITableViewCell *) cell {
//    CGRect rect = CGRectMake(cell.frame.origin.x + cell.frame.size.width - 35, 10, 20, 20);
//    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:rect];
	
	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activityIndicator.center = CGPointMake(cell.center.x, cell.center.y);

    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    activityIndicator.hidden = YES;
	
    [cell.contentView addSubview:activityIndicator];
}


- (void)runPiespinner:(BOOL)gettingMore {
	
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


- (void) addSpinnerToCell:(NSIndexPath *)indexPath {
	NSAutoreleasePool *apool = [[NSAutoreleasePool alloc] init];
	
	//get the cell
//	UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
	
	//set the spinner (cast to PostTableView "type" in order to avoid warnings)
	[self runPiespinner:YES];
	
	[apool release];
}


- (void) removeSpinnerFromCell:(NSIndexPath *)indexPath {
	NSAutoreleasePool *apool = [[NSAutoreleasePool alloc] init];
		
	[self runPiespinner:NO];
	
	[apool release];
}


- (void) haveMoreNearbyPeople:(NSNotification *)notification {
	
	[self.peopleTableView setUserInteractionEnabled:YES];

	[self.peopleTableView reloadData];
	UITableViewCell *cell = [self.peopleTableView cellForRowAtIndexPath:selectPath];

	[cell addSubview:loadMore];
}

- (void) getMoreNearbyPeople {
	NSAutoreleasePool *apool = [[NSAutoreleasePool alloc] init];

	MizDataManager	*dm = [MizDataManager sharedDataManager];
	
	[dm fetchNearbyPeople: 2 atIndex:2 numberToRet:4 ];
	
	[apool release];
}
#pragma mark Table view methods


- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section {
	return @"People near by...";                                                                                
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
	return 80.0; //returns floating point which will be used for a cell row height at specified row index  
}  

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//	tableView.separatorColor = [UIColor colorWithRed:3.0/255.0 green:151.0/255.0 blue:214.0/255.0 alpha:1.0];
	tableView.separatorColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.0];

//	self.tbView = tableView;
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	MizDataManager *dm = [MizDataManager sharedDataManager];
	NSUInteger peopleCount = [dm.nearbyPeople count];
	int			totalSize = dm.nearbyPeopleSize;

	MizoonLog(@"Number of people = %d", peopleCount);
	
	if (peopleCount != totalSize) 
		return  peopleCount+1;
	else 
		return  peopleCount;

	
	if([dm.nearbyPeople count]>= 30) {
		return [dm.nearbyPeople count]+1;
	}
	else {
		return [dm.nearbyPeople count];
		
	}
  //  return [self.nearbyPeople count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	MizDataManager *dm = [MizDataManager sharedDataManager];
	NSUInteger row = [indexPath row];
	NSUInteger dataCount = [dm.nearbyPeople count];
	int			totalSize = dm.nearbyPeopleSize;
	
    static NSString *CellIdentifier = @"PeopleCell";
	static NSString *MorePeopleCellIdentifier = @"MorePeopleCell";

	
//	MizoonLog(@"----------- dataCount=%d  totalPeople=%d", dataCount, totalSize);
	
	if ( row < dataCount )  {   // normal nearpeople cell
		NearbyPeopleViewCell *cell = (NearbyPeopleViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (cell == nil) {
			cell = [[[NearbyPeopleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
		} else {
			AsyncImageView* oldImage = (AsyncImageView*) [cell.contentView viewWithTag:kPersonPictureTag];
			[oldImage removeFromSuperview];
		}
		/*
		UIView *cellView = [[cell subviews] objectAtIndex:0];
		if (indexPath.row % 2) {
			[cellView setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:0.5]];
		} else {
//			[cellView setBackgroundColor:[UIColor colorWithRed:0/255.0 green:180/255.0 blue:220/255.0 alpha:1.0]];
//			[cellView setBackgroundColor:[UIColor colorWithRed:70/255.0 green:204/255.0 blue:234/255.0 alpha:1.0]];
			
			UIImage *bkgImg = [UIImage imageNamed:@"g-background2.png"];
			UIImageView *imageView = [[UIImageView alloc] initWithImage:bkgImg];
			imageView.contentMode = UIViewContentModeScaleToFill;
			cell.backgroundView = imageView;
			[imageView release];
			 
		}
		*/
		// Set up the cell...
		[self assignRowValues:cell atRow:row];
		
		return cell;
	}
	
	// create and add a "Load More" cell
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:MorePeopleCellIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MorePeopleCellIdentifier] autorelease];
		UIView *cellView = [[cell subviews] objectAtIndex:0];
		[cellView setBackgroundColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0]];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		[self addCellActivityIndicator: cell];
		loadMore = (UILabel *) [cell viewWithTag:kMorePersonTag];
		if (!loadMore) {
			loadMore =[[UILabel alloc]initWithFrame: CGRectMake(0,20,320,30)];
			loadMore.textColor = [UIColor blackColor];
			loadMore.backgroundColor = [UIColor clearColor];
//			loadMore.font=[UIFont fontWithName:@"Verdana" size:20];
			loadMore.font = [UIFont fontWithName:MIZOON_FONT size:20.0f];

			loadMore.textAlignment=UITextAlignmentCenter;
			loadMore.font=[UIFont boldSystemFontOfSize:14];
			loadMore.text=@"Load more...";
			[loadMore setTag:kMorePersonTag];
			
		}
		
	} 
	if (dataCount != totalSize)   // if we have displayed all the data that the server has to offer, don't display the "Load more"
		[cell addSubview:loadMore];
	else {
		UILabel *more = (UILabel *) [cell viewWithTag: kMorePersonTag];
		[more removeFromSuperview];
	}


	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 	
	MizDataManager *dm = [MizDataManager sharedDataManager];
	NSUInteger row = [indexPath row];
	NSUInteger dataCount = [dm.nearbyPeople count];
	selectPath = indexPath;

	if(row >= dataCount) {   // Load More cell was touched
			
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

		if ( cell ) {
			
			[[cell viewWithTag:kMorePersonTag] removeFromSuperview];

			// Disable user interaction if/when the loading/search results view appears.
			[tableView setUserInteractionEnabled:NO];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];	

			[self performSelectorInBackground:@selector(addSpinnerToCell:) withObject:indexPath];				
			
//			[self performSelectorInBackground:@selector(getMoreNearbyPeople) withObject:nil];

			[dm fetchNearbyPeople: DEFAULT_RADIUS atIndex:dataCount numberToRet:NUM_PEOPLE_TO_REFEtCH ];
			
 			[self performSelectorInBackground:@selector(removeSpinnerFromCell:) withObject:indexPath];
 
			[tableView setUserInteractionEnabled:YES];

			[cell addSubview:loadMore];

			[tableView reloadData];
		}
		return;
	} 
	
	Mizoon *miz = [Mizoon sharedMizoon];	
	[miz setSelectedPerson: row];

	[self displayPersonInfo: row];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	
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

- (void) tableView:(UITableView *) tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *) indexPath {
	UIImage *bkgImg = [UIImage imageNamed:@"g-background2.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:bkgImg];
	imageView.contentMode = UIViewContentModeScaleToFill;
	cell.backgroundView = imageView;
	[imageView release];

	return;
	
	if (indexPath.row % 2) {
		cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
	} else {
//		cell.backgroundColor = [UIColor colorWithHue:0.3 saturation:0.5 brightness:1.0 alpha:1.0];
		cell.backgroundColor = [UIColor colorWithRed:70/255.0 green:204/255.0 blue:220/234.0 alpha:1.0];
	}
}



- (void) setupRowLayout: (UITableViewCell *) cell 
{

	UILabel *nameValue = [[UILabel alloc] initWithFrame:CGRectMake(DATA_COLUMN_X, 0, 220, 30)];
	
	nameValue.tag = kPersonNameTag;
	[nameValue setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.0]];
	nameValue.font = [UIFont fontWithName:MIZOON_FONT_BOLD size:FOLLOWUP_FONT_SIZE];

	[cell.contentView addSubview:nameValue];
	[nameValue release];
	
	UILabel *profile1Value = [[UILabel alloc] initWithFrame:CGRectMake(DATA_COLUMN_X, 30, 220, 15)];
	profile1Value.tag = kPersonProfile1Tag;
	profile1Value.textAlignment = UITextAlignmentLeft;
	[profile1Value setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.0]];

//	profile1Value.font = [UIFont systemFontOfSize:FOLLOWUP_FONT_SIZE];
	profile1Value.font = [UIFont fontWithName:MIZOON_FONT size:FOLLOWUP_FONT_SIZE];

	profile1Value.text = NULL;
	[cell.contentView addSubview:profile1Value];
	[profile1Value release];
	
	UILabel *profile2Value = [[UILabel alloc] initWithFrame:CGRectMake(DATA_COLUMN_X, 45, 220, 15)];
	profile2Value.tag = kPersonProfile2Tag;
	profile2Value.textAlignment = UITextAlignmentLeft;
//	profile2Value.font = [UIFont systemFontOfSize:FOLLOWUP_FONT_SIZE];
	profile2Value.font = [UIFont fontWithName:MIZOON_FONT size:FOLLOWUP_FONT_SIZE];

	profile2Value.text =  NULL;
	[profile2Value setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.0]];
	[cell.contentView addSubview:profile2Value];
	[profile2Value release];
	
	CGRect profile3VR = CGRectMake(DATA_COLUMN_X, 60, 220, 15);
	UILabel *profile3Value = [[UILabel alloc] initWithFrame:profile3VR];
	profile3Value.tag = kPersonProfile3Tag;
	profile3Value.textAlignment = UITextAlignmentLeft;
//	profile3Value.font = [UIFont systemFontOfSize:FOLLOWUP_FONT_SIZE];
	profile3Value.font = [UIFont fontWithName:MIZOON_FONT size:FOLLOWUP_FONT_SIZE];

	[profile3Value setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.0]];

	profile3Value.text =  NULL;
	[cell.contentView addSubview:profile3Value];
	[profile3Value release];	
}



//- (void) assignRowValues:(UITableViewCell *) cell atRow:(NSUInteger) row 
- (void) assignRowValues:(NearbyPeopleViewCell *) cell atRow:(NSUInteger) row 
{
	MizDataManager *dm = [MizDataManager sharedDataManager];
	NSDictionary *stream = (NSDictionary *)[dm.nearbyPeople objectAtIndex:row];
	NSString *image = [stream valueForKey:@"pic"];

	[cell setImage:image];
	[cell setName:[stream valueForKey:@"name"]];
	
	[cell setProfile:[stream valueForKey:@"a00"] withValue:[stream valueForKey:@"v00"]];
	[cell setProfile:[stream valueForKey:@"a01"] withValue:[stream valueForKey:@"v01"]];
	[cell setProfile:[stream valueForKey:@"a02"] withValue:[stream valueForKey:@"v02"]];
	
//	[cell setProfile:[stream valueForKey:@"a1"] withValue:[stream valueForKey:@"v1"]];
//	[cell setProfile:[stream valueForKey:@"a2"] withValue:[stream valueForKey:@"v2"]];
//	[cell setProfile:[stream valueForKey:@"a3"] withValue:[stream valueForKey:@"v3"]];

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
		self.peopleTableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
}


#pragma mark -
#pragma mark refreshHeaderView Methods

- (void)dataSourceDidFinishLoadingNewData{
	
	_reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.peopleTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[refreshHeaderView setState:EGOOPullRefreshNormal];
}


- (void) reloadTableViewDataSource
{
	MizoonLog(@"Please override reloadTableViewDataSource");
	
	Mizoon *miz=[Mizoon sharedMizoon];	
//	[self performSelector:@selector(stopUpdatingLocation) withObject:@"Timed Out" afterDelay:RELOAD_TIMEOUT ];

	timer = [NSTimer scheduledTimerWithTimeInterval:RELOAD_TIMEOUT 
											 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(havePeopleData:)
												 name:@"MZ_Have_Location_Coord" object:nil];
	
	[miz updateLocation];
	
	
	
}



- (void)timeout:(NSTimer*)theTimer {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    MizoonLog(@"Timedout...............................................") ;
	[theTimer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	[[[Mizoon sharedMizoon] getRootViewController] renderView:PEOPLE_VIEW fromView: MAIN_VIEW];
	
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
//	[rvc renderView:PEOPLE_VIEW fromView: MAIN_VIEW];
//	
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"People lookup timeout" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
//	[alert show];
//	[alert release];
//	
//	[pool release];
//}



- (void) havePeopleData:(NSNotification *)notification 
{
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	
	[timer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	[rvc reloadView:PEOPLE_VIEW];
}


#endif




@end

