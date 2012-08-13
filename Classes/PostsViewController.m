//
//  PostsViewController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 3/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PostsViewController.h"
#import	"MizDataManager.h"
#import	"AsyncImageView.h"

@interface PostsViewController ()
- (UITableViewCell *) loadMoreCell: (UITableView *) tableView rowNumber: (NSUInteger) row;
- (UITableViewCell *) loadPhotoCell: (UITableView *) tableView rowNumber: (NSUInteger) row;
- (UITableViewCell *) loadPostsCell: (UITableView *) tableView rowNumber: (NSUInteger) row;
- (void) assignRowValues:(PostsViewCell *) cell atRow:(NSUInteger) row; 
- (void) assignPhotoCellValues:(PostsViewCell *) cell atRow:(NSUInteger) row; 
- (void) newPost;
@end


@implementation PostsViewController
@synthesize	selectedRow, selectPath, postsTableView;

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
		self.postsTableView = tableView;
		[self.view addSubview:postsTableView];
		[tableView release];
		
		self.postsTableView.frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 380.0);
		
#else	
		self.view.frame = CGRectMake(0.0, 0, 320.0, 480.0);
		[self.view viewWithTag:kViewTableViewTag].frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 400.0); // 44 pixels for the bottom toolbar
		[self.view viewWithTag:kViewTableViewTag].backgroundColor = [UIColor clearColor];
		
#endif

		self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
	}
	return self;
}


- (void)dealloc 
{
	[loadMore release];
	[activityIndicator release];
	[postsTableView	release];
    [super dealloc];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	[super viewDidLoad];
	
#ifdef	PULL_REFRESH
	if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.postsTableView.bounds.size.height, 320.0f, self.postsTableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		refreshHeaderView.bottomBorderThickness = 1.0;
		[self.postsTableView addSubview:refreshHeaderView];
		self.postsTableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
#endif
	
	UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:767];
//	UIImage	  *postImage = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"post-button" ofType:@"png"]];
//	UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithImage:postImage style:UIBarButtonItemStylePlain target:self action:@selector(newPost)];

	UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleBordered target:self action:@selector(newPost)];
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, postButton,nil]];
	
	[flexibleSpace release];
	
	[self.view addSubview:toolbar];
	
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	MizoonLog(@"---------------> didReceiveMemoryWarning: PostsViewController");

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */




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


- (void) haveMoreNearbyPosts:(NSNotification *)notification 
{	
	[self.postsTableView setUserInteractionEnabled:YES];
	
	[self.postsTableView reloadData];
	UITableViewCell *cell = [self.postsTableView cellForRowAtIndexPath:selectPath];

	[cell addSubview:loadMore];
}

- (void) newPost {
	
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *rvc = delegate.rootViewController;
	
	
//	NSLog(@"Button was pushed");
	[rvc renderView:NEW_POST_VIEW fromView: POSTS_VIEW];

}


#pragma mark Table view methods


- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section {
	return @"Near by posts...";                                                                                
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
	MizDataManager *dm = [MizDataManager sharedDataManager];
	NSUInteger postsCount = [dm.nearbyPosts count];

	if (indexPath.row >= postsCount)   // Load more cell
		return 80;
	
	
	NSDictionary *stream = (NSDictionary *)[dm.nearbyPosts objectAtIndex:[indexPath row]];
	NSString *photo = [stream valueForKey:@"photo"];
	
	if ([photo length] > 0)   // if we have photo set the height to 100; the views will be rearranged in assignRowValues
		return 100;
	
	
	return 80.0; //returns floating point which will be used for a cell row height at specified row index  
}  

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	tableView.separatorColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.0];

    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	MizDataManager *dm = [MizDataManager sharedDataManager];
	NSUInteger postsCount = [dm.nearbyPosts count];
	
	MizoonLog(@"Number of posts = %d", postsCount);

	return  postsCount+1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	MizDataManager	*dm = [MizDataManager sharedDataManager];
	NSUInteger		row = [indexPath row];
	NSUInteger		dataCount = [dm.nearbyPosts count];
	

	if (row >= dataCount ) 
		return [self loadMoreCell:tableView rowNumber: row];

	
	NSDictionary	*stream = (NSDictionary *)[dm.nearbyPosts objectAtIndex:row];
	if (row < dataCount && [[stream valueForKey:@"photo"] length] > 0 )   // a cell with photo
		return [self loadPhotoCell:tableView rowNumber: row];

	// normal nearpeople cell
	return [self loadPostsCell:tableView rowNumber: row];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 	
	MizDataManager	*dm = [MizDataManager sharedDataManager];
	NSUInteger		row = [indexPath row];
	NSUInteger		dataCount = [dm.nearbyPosts count];
	int				totalSize = dm.nearbyPostsSize;
	Mizoon			*miz = [Mizoon sharedMizoon];
	
	selectPath = indexPath;
	
	if (dataCount == totalSize)   // if we have displayed all the data that the server has to offer, don't display the "Load more"
		return;
	
	if (row < dataCount) {
		MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		RootViewController *rvc = delegate.rootViewController;
		
		
		miz.selectedPost = self.selectedRow = [indexPath row];
		[rvc renderView:A_POST_VIEW fromView: POSTS_VIEW];

	}
	
	if(row >= dataCount) {   // Load More cell was touched
		
		// Register for the notification
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(haveMoreNearbyPosts:)
													 name:@"WS_nearbyPosts_Completed" object:nil];
		
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		
		if ( cell ) {
			[[cell viewWithTag:kMorePostsTag] removeFromSuperview];
			
			// Disable user interaction if/when the loading/search results view appears.
			[tableView setUserInteractionEnabled:NO];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];	
			
			[self performSelectorInBackground:@selector(addSpinnerToCell:) withObject:indexPath];				
			
			//			[self performSelectorInBackground:@selector(getMoreNearbyPeople) withObject:nil];
			
			[dm fetchNearbyPosts: DEFAULT_RADIUS atIndex:dataCount numberToRet:NUM_POSTS_TO_REFEtCH ];
			
// 			[self performSelectorInBackground:@selector(removeSpinnerFromCell:) withObject:indexPath];
			[self removeSpinnerFromCell:indexPath];
			[tableView setUserInteractionEnabled:YES];
			
			[cell addSubview:loadMore];
			
			[tableView reloadData];
		}
	} 
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	
}





- (void) tableView:(UITableView *) tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *) indexPath {
	
	UIImage *bkgImg = [UIImage imageNamed:@"g-background2.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:bkgImg];
	imageView.contentMode = UIViewContentModeScaleToFill;
	cell.backgroundView = imageView;
	[imageView release];
	
	/*
	if (indexPath.row % 2) {
		cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.5];
	} else {
		cell.backgroundColor = [UIColor colorWithRed:0/255.0 green:180/255.0 blue:220/255.0 alpha:1.0];	
	}
	*/
//	if (indexPath.row % 2) {
//		cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
//	} else {
//		//		cell.backgroundColor = [UIColor colorWithHue:0.3 saturation:0.5 brightness:1.0 alpha:1.0];
//		cell.backgroundColor = [UIColor colorWithRed:0/255.0 green:180/255.0 blue:220/255.0 alpha:1.0];	
//	}
//	//	cell.backgroundColor = [UIColor grayColor];
}


#pragma mark Private methods

- (UITableViewCell *) loadPostsCell: (UITableView *) tableView rowNumber: (NSUInteger) row {

    static NSString *CellIdentifier = @"PostCell";

	PostsViewCell *cell = (PostsViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil) {
		cell = [[[PostsViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	} else {
		AsyncImageView* oldImage = (AsyncImageView*) [cell.contentView viewWithTag:kPersonPictureTag];
		[oldImage removeFromSuperview];
	}

	// Assign cell values...
	[self assignRowValues:cell atRow:row];

	return cell;
}


- (UITableViewCell *) loadPhotoCell: (UITableView *) tableView rowNumber: (NSUInteger) row {

	static NSString *CellPhotoIdentifier = @"PostPhotoCell";

	PostsViewPhotoCell *cell = (PostsViewPhotoCell *)[tableView dequeueReusableCellWithIdentifier:CellPhotoIdentifier];

	if (cell == nil) {
		cell = [[[PostsViewPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellPhotoIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	} else {
		AsyncImageView* oldImage = (AsyncImageView*) [cell.contentView viewWithTag:kPersonPictureTag];
		[oldImage removeFromSuperview];
		
		AsyncImageView* oldPhoto = (AsyncImageView*) [cell.contentView viewWithTag:kPostPhotoTag];
		[oldPhoto removeFromSuperview];

	}

	// Assign cell values...
	[self assignPhotoCellValues:cell atRow:row];

	return cell;
}


- (UITableViewCell *) loadMoreCell: (UITableView *) tableView rowNumber: (NSUInteger) row {
	
	static NSString *MorePostsCellIdentifier = @"MorePostsCell";
	MizDataManager	*dm = [MizDataManager sharedDataManager];
	NSUInteger		dataCount = [dm.nearbyPosts count];
	int				totalSize = dm.nearbyPostsSize;
	
	// create and add a "Load More" cell
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:MorePostsCellIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MorePostsCellIdentifier] autorelease];
		UIView *cellView = [[cell subviews] objectAtIndex:0];
		[cellView setBackgroundColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0]];

		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		[self addCellActivityIndicator: cell];
		loadMore = (UILabel *) [cell viewWithTag:kMorePostsTag];
		if (!loadMore) {
			loadMore =[[UILabel alloc]initWithFrame: CGRectMake(0,20,320,30)];
			loadMore.textColor = [UIColor blackColor];
			loadMore.backgroundColor = [UIColor clearColor];
			loadMore.font=[UIFont fontWithName:@"Verdana" size:20];
			loadMore.textAlignment=UITextAlignmentCenter;
			loadMore.font=[UIFont boldSystemFontOfSize:14];
			loadMore.text=@"Load more...";
			[loadMore setTag:kMorePostsTag];
			
		}
		
	} 
	if (dataCount != totalSize)   // if we have displayed all the data that the server has to offer, don't display the "Load more"
		[cell addSubview:loadMore];
	else {
		UILabel *more = (UILabel *) [cell viewWithTag: kMorePostsTag];
		[more removeFromSuperview];
	}
	
	
	return cell;
}



- (void) assignPhotoCellValues:(PostsViewPhotoCell *) cell atRow:(NSUInteger) row 
{
	MizDataManager *dm = [MizDataManager sharedDataManager];
	NSDictionary *stream = (NSDictionary *)[dm.nearbyPosts objectAtIndex:row];
	NSString *image = [stream valueForKey:@"pic"];
	NSString *photo = [stream valueForKey:@"photo"];
	

	[cell setPhoto:photo];
	[cell setImage:image];
	[cell setName:[stream valueForKey:@"name"]];
	[cell setMessage:[stream valueForKey:@"message"]];
	[cell setPostInfo:[stream valueForKey:@"postinfo"]];   //name, uid, pic, lid, loc_name, p_date, message, photo
}


//- (void) assignRowValues:(UITableViewCell *) cell atRow:(NSUInteger) row 
- (void) assignRowValues:(PostsViewCell *) cell atRow:(NSUInteger) row 
{
	MizDataManager *dm = [MizDataManager sharedDataManager];
	NSDictionary *stream = (NSDictionary *)[dm.nearbyPosts objectAtIndex:row];
	NSString *image = [stream valueForKey:@"pic"];

	[cell setImage:image];
	[cell setName:[stream valueForKey:@"name"]];
	[cell setMessage:[stream valueForKey:@"message"]];
	[cell setPostInfo:[stream valueForKey:@"postinfo"]];   //name, uid, pic, lid, loc_name, p_date, message, photo
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
		self.postsTableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
}


#pragma mark -
#pragma mark refreshHeaderView Methods

- (void)dataSourceDidFinishLoadingNewData{
	
	_reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.postsTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
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
											 selector:@selector(havePostData:)
												 name:@"MZ_Have_Location_Coord" object:nil];
	
	[miz updateLocation];
	
	
	
}



- (void)timeout:(NSTimer*)theTimer {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    MizoonLog(@"Timedout...............................................") ;
	[theTimer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	[[[Mizoon sharedMizoon] getRootViewController] renderView:POSTS_VIEW fromView: MAIN_VIEW];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Posts lookup timeout" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	
	[pool release];
}

//- (void)stopUpdatingLocation 
//{
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//	
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
//	[[[Mizoon sharedMizoon] getRootViewController] reloadView:POSTS_VIEW];
//	
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Posts lookup timeout" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
//	[alert show];
//	[alert release];
//	
//	[pool release];
//}


- (void) havePostData:(NSNotification *)notification 
{
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	MizoonLog(@"Please havePostData havePostData havePostData havePostData havePostData havePostData havePostData havePostData");
	[timer invalidate];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MZ_Have_Location_Coord" object:nil];	 
	[rvc reloadView:POSTS_VIEW];
}


#endif



@end
