//
//  SettingsViewController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 3/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import	"MizoonAppDelegate.h"
#import	"RootViewController.h"
#import	"MizDataManager.h"
#import "Mizoon.h"
#import "TwtOAuthEngine.h"
#import	"TwtOAuthController.h"

#define	ROW_LABEL_X			20
#define	ROW_LABEL_Y			5
#define	ROW_LABEL_WIDTH		120
#define	ROW_LABEL_HEIGHT	40
#define	CELL_SPACE			20

#define	kPointsTag		10


@interface SettingsViewController() // private
- (UITableViewCell *)logOut: (UITableView *) tableView;
- (UITableViewCell *)FBSetup: (UITableView *) tableView;
- (UITableViewCell *)pointsSetup: (UITableView *) tableView;
- (UITableViewCell *)twitterSetup: (UITableView *) tableView;
- (void) fbLogin;
- (void) fbLogout;

//- (NSString *) locateAuthPinInWebView: (UIWebView *) webView;
//- (void) gotPin: (NSString *) pin;
//- (void) denied;
//
//- (void) showActivity: (NSString *) message;
//- (void) hideActivity;
@end


@implementation SettingsViewController
@synthesize	logoutOfService, twtView;


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
 



 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
//	 Mizoon *miz = [Mizoon sharedMizoon];
	 
//	 [miz.fbSession resume];
	 	 
	 
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
	
	MizoonLog(@"---------------> didReceiveMemoryWarning: SettingsViewController");
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[twtView release];

    [super dealloc];
}




- (IBAction) signOut: (id) sender
{
	logoutOfService = MIZOON_SRV;

	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
															 delegate:self 
													cancelButtonTitle:@"Cancel" 
											   destructiveButtonTitle:@"Logout"
													otherButtonTitles:nil];
	
	[actionSheet showInView:self.view];
	[actionSheet release];	
}


#pragma mark Twitter

- (IBAction) twitterLogin: (id) sender
{
	TwtOAuthController *twtController = [[TwtOAuthController alloc] init];
	[self.view insertSubview:twtController.view atIndex:0];
	[self.view bringSubviewToFront:twtController.view];
	self.twtView = twtController;
	[twtController release];
	
	return;
}




- (IBAction) twitterLogout: (id) sender
{
	logoutOfService = TWITTER_SERVICE;
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
															 delegate:self 
													cancelButtonTitle:@"Cancel" 
											   destructiveButtonTitle:@"Logout"
													otherButtonTitles:nil];
	
	[actionSheet showInView:self.view];
	[actionSheet release];	
	

}


#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{	
	MizDataManager *dm = [MizDataManager sharedDataManager];

	if (buttonIndex == [actionSheet cancelButtonIndex]) 
		return;
	
	switch (logoutOfService) {
		case TWITTER_SERVICE:
			[[Mizoon sharedMizoon] twitterLogout];
			[[[Mizoon sharedMizoon] getRootViewController] reloadSetup];		
			break;
		case MIZOON_SRV:
			if (!dm.isAuthenticatedMizUser) {
				MizoonLog(@"User is lready logged out!!!");
				return;
			}
			[dm NSLogout:dm.username];
			[dm release];
			RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
			[rvc renderView:REG_LOGIN_VIEW  fromView: SETTINGS_VIEW];
			break;

		default:
			break;
	}
}



#pragma mark Table view methods


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	Mizoon *miz = [Mizoon sharedMizoon];
	
	UIView* customView = [[UIView alloc] initWithFrame:CGRectZero];
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:16];
	
	switch (section) {
		case 0:	// create the parent view that will hold header Label
			//			customView.frame = CGRectMake(10.0, 70.0, 300.0, 44.0);
			
			headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
			headerLabel.text = [miz getUserName];
			[customView addSubview:headerLabel];
			break;
		case 1:
			//			customView.frame = CGRectMake(10.0, 370.0, 300.0, 44.0);
			
			headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
			headerLabel.text = @"Visitors"; 
			[customView addSubview:headerLabel];
			break;	
	}
	[headerLabel release];
	
	return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  
{  
	NSUInteger section = [indexPath section];
	switch (section) {
		case 0:
			return 50;
		case 1:
			return 50.0;
		case 2:
			return 50.0;
		case 3:
			return 50.0;
		default:
			break;
	}
	return 50.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	tableView.separatorColor = [UIColor colorWithRed:220/255.0 green:220.0/255.0 blue:220/255.0 alpha:1.0];

	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{	
	return 4;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	
	switch (row) {
		case 0:
			return [self logOut: tableView];
		case 1:
			return [self FBSetup: tableView];
		case 2:
			return [self twitterSetup: tableView];
		case 3:
			return [self pointsSetup: tableView];
		default:
			NSLog(@"WTF!");
			break;
	} 
	return	nil;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{ 	
}


- (void) tableView:(UITableView *) tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *) indexPath {
	
}


#pragma mark Private

- (UITableViewCell *)logOut: (UITableView *) tableView
{
	static NSString *CellIdentifier = @"LogOutCell";	
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UILabel *logoutLbl = [[UILabel alloc] initWithFrame: CGRectMake(ROW_LABEL_X, ROW_LABEL_Y, ROW_LABEL_WIDTH, ROW_LABEL_HEIGHT)];
		logoutLbl.tag = kSocialMediaTag;
		logoutLbl.textAlignment = UITextAlignmentLeft;
		logoutLbl.font = [UIFont fontWithName:MIZOON_FONT_BOLD size:LOCATION_INFO_FONT_SIZE];
		logoutLbl.textColor = [UIColor colorWithRed:64/255.0 green:142/255.0 blue:206/255.0 alpha:1.0];

		logoutLbl.text = @"Mizoon";
		[cell.contentView addSubview:logoutLbl];	
		[logoutLbl release];

		
		UIButton *logoutBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[logoutBtn setImage:[UIImage imageNamed:@"mz-logout-button.png"] forState:UIControlStateNormal];
		logoutBtn.frame = CGRectMake(ROW_LABEL_X + ROW_LABEL_WIDTH + CELL_SPACE , ROW_LABEL_Y , 90.0, 40);
		[logoutBtn addTarget:self action:@selector(signOut:) forControlEvents:UIControlEventTouchUpInside];	
		[cell.contentView addSubview:logoutBtn];
		[logoutBtn release];
		
	}
	
	return cell;
}


- (UITableViewCell *)twitterSetup: (UITableView *) tableView
{
	static NSString *CellIdentifier = @"TwotterCell";	
	Mizoon	*miz = [Mizoon sharedMizoon];
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UILabel *smLbl = [[UILabel alloc] initWithFrame:CGRectMake(ROW_LABEL_X, ROW_LABEL_Y, ROW_LABEL_WIDTH, ROW_LABEL_HEIGHT)];
		smLbl.textAlignment = UITextAlignmentLeft;
		smLbl.font = [UIFont fontWithName:MIZOON_FONT_BOLD size:LOCATION_INFO_FONT_SIZE];
		smLbl.textColor = [UIColor colorWithRed:64/255.0 green:142/255.0 blue:206/255.0 alpha:1.0];
		smLbl.text = @"Twitter";
		[cell.contentView addSubview:smLbl];
		[smLbl release];
		
		UIButton *twitterBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[twitterBtn setImage:[UIImage imageNamed:@"twitter-button.png"] forState:UIControlStateNormal];
		twitterBtn.frame = CGRectMake(ROW_LABEL_X + ROW_LABEL_WIDTH + CELL_SPACE , ROW_LABEL_Y + 5 , 90.0, 30);
		
		if (![miz isLoggedInTwitter]) {
			[twitterBtn setImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
			[twitterBtn addTarget:self action:@selector(twitterLogin:) forControlEvents:UIControlEventTouchUpInside];	
		} else {
			[twitterBtn setImage:[UIImage imageNamed:@"twt-logout-button-2.png"] forState:UIControlStateNormal];			
			[twitterBtn addTarget:self action:@selector(twitterLogout:) forControlEvents:UIControlEventTouchUpInside];	
		}

		[cell.contentView addSubview:twitterBtn];
		[twitterBtn release];
		
	}
	return cell;
}



- (UITableViewCell *)FBSetup: (UITableView *) tableView
{
	static NSString *CellIdentifier = @"FBCell";	
//	[MizDataManager sharedDataManager].isFBAuthenticatedUser = TRUE;

	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UILabel *smLbl = [[UILabel alloc] initWithFrame:CGRectMake(ROW_LABEL_X, ROW_LABEL_Y, ROW_LABEL_WIDTH, ROW_LABEL_HEIGHT)];
		smLbl.textAlignment = UITextAlignmentLeft;
		smLbl.font = [UIFont fontWithName:MIZOON_FONT_BOLD size:LOCATION_INFO_FONT_SIZE];
		smLbl.textColor = [UIColor colorWithRed:64/255.0 green:142/255.0 blue:206/255.0 alpha:1.0];
		smLbl.text = @"Facebook";
		[cell.contentView addSubview:smLbl];
		[smLbl release];

//		fbLoginButton = [[[FBLoginButton alloc] initWithFrame:CGRectMake( ROW_LABEL_X + ROW_LABEL_WIDTH + CELL_SPACE, ROW_LABEL_Y , 90.0, ROW_LABEL_HEIGHT)] autorelease];
//		[cell.contentView addSubview:fbLoginButton];	
		
		UIButton *fbBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		fbBtn.frame = CGRectMake(ROW_LABEL_X + ROW_LABEL_WIDTH , 0, ROW_LABEL_WIDTH, 50);
		
		if ([MizDataManager sharedDataManager].isFBAuthenticatedUser) {
			[fbBtn setImage:[UIImage imageNamed:@"FBConnect.bundle/images/LogoutNormal.png"] forState:UIControlStateNormal];
			[fbBtn setImage:[UIImage imageNamed:@"FBConnect.bundle/images/LogoutPressed.png"] forState: UIControlStateHighlighted |UIControlStateSelected];
			[fbBtn addTarget:self action:@selector(fbLogout) forControlEvents:UIControlEventTouchUpInside];	
		} else {
			[fbBtn setImage:[UIImage imageNamed:@"FBConnect.bundle/images/LoginNormal.png"] forState:UIControlStateNormal];
			[fbBtn setImage:[UIImage imageNamed:@"FBConnect.bundle/images/LoginPressed.png"] forState: UIControlStateHighlighted |UIControlStateSelected];
			[fbBtn addTarget:self action:@selector(fbLogin) forControlEvents:UIControlEventTouchUpInside];	
		}
		
		[cell.contentView addSubview:fbBtn];
		[fbBtn release];

	}
	return cell;
}

- (void) fbLogin
{
	[[Mizoon sharedMizoon] mizFBLogin];
}


- (void) fbLogout
{
	[[Mizoon sharedMizoon] mizFBLogout];
}

- (UITableViewCell *)pointsSetup: (UITableView *) tableView
{
	static NSString *CellIdentifier = @"PointsCell";	
	Mizoon *miz = [Mizoon sharedMizoon];
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UILabel *smLbl = [[UILabel alloc] initWithFrame:CGRectMake(ROW_LABEL_X, ROW_LABEL_Y, ROW_LABEL_WIDTH, ROW_LABEL_HEIGHT)];
		smLbl.textAlignment = UITextAlignmentLeft;
		smLbl.font = [UIFont fontWithName:MIZOON_FONT_BOLD size:LOCATION_INFO_FONT_SIZE];
		smLbl.textColor = [UIColor colorWithRed:64/255.0 green:142/255.0 blue:206/255.0 alpha:1.0];
		smLbl.text = @"Mizoon Points";
		[cell.contentView addSubview:smLbl];
		[smLbl release];
		
		UILabel *points = [[UILabel alloc] initWithFrame:CGRectMake( ROW_LABEL_X + ROW_LABEL_WIDTH + CELL_SPACE , ROW_LABEL_Y ,
																	100.0, ROW_LABEL_HEIGHT)];
		points.textAlignment = UITextAlignmentLeft;
		points.font = [UIFont fontWithName:MIZOON_FONT_BOLD size:18];
		points.textColor = [UIColor colorWithRed:64/255.0 green:142/255.0 blue:240/255.0 alpha:1.0];
		points.tag = kPointsTag;
		
		[cell.contentView addSubview:points];
		[points release];
	}
	UILabel *points = (UILabel *) [cell.contentView viewWithTag:kPointsTag];
	points.text = [NSString stringWithFormat:@"%d", [miz getMizoonerPoints]];

	return cell;
}


@end
