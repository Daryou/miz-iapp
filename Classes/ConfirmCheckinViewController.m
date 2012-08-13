//
//  ShareCheckinViewController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 6/14/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import "ConfirmCheckinViewController.h"
#import	"UISwitch-Extended.h"
#import	"MizDataManager.h"
#import "MizProgressHUD.h"
//#import "FBPermissionDialog.h"

@interface ConfirmCheckinViewController (private)
- (UITableViewCell *) processLocationInfo: (UITableView *) tableView;
- (UITableViewCell *) checkinMessage: (UITableView *) tableView;
- (UITableViewCell *) socialMediaOptions: (UITableView *) tableView row: (NSInteger) rowNumber; 
- (IBAction) doCheckin;
- (void) fbLogin;
@end

@implementation ConfirmCheckinViewController
@synthesize	nameLbl, addressLbl,cityStateLbl, checkinMsg, maxCharLbl, switchCtl, attachMsg, confirmCK, postToFB,twtSwitchCtl,postToTwt,twtController;





 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
	
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
	
		self.view.frame = CGRectMake(0.0, 0, 320.0, 460.0);
		[self.view viewWithTag:kViewTableViewTag].frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 440.0);
		[self.view viewWithTag:kViewTableViewTag].backgroundColor = [UIColor whiteColor];
		self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];

		
		confirmCK = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		confirmCK.frame = CGRectMake( 70.0, 370.0 , 180.0, 50.0);
//		confirmCK.backgroundColor = [UIColor grayColor];
		[confirmCK setImage:[UIImage imageNamed:@"confirm-button.png"] forState:UIControlStateNormal];
		[confirmCK addTarget:self action:@selector(doCheckin) forControlEvents:UIControlEventTouchUpInside];	
		[self.view addSubview:confirmCK];    
		
		postToFB = YES;
		postToTwt = YES;
	}
	
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
//	[[Mizoon sharedMizoon].fbSession resume];

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
	MizoonLog(@"---------------> didReceiveMemoryWarning: ShareCheckinView");

    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
    [super dealloc];
	
	[nameLbl release];
	[addressLbl release];
	[cityStateLbl release];
	[twtController release];
}



#pragma mark Table view methods


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
	switch ([indexPath section]) {
		case 0:
			return 70.0;
		case 1:
			return 90.0;
		case 2:
			return 40.0;

	}
	return 90.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

	return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{	
	if (section == 2) {
		return 2;	// FB and Twitter 
	}
	return 1;
}


/*
- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section {
//	
//	if (section == 0) 
//		return @"Check in at:"; 
//	return @"ddddd";
}
*/

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch ([indexPath section]) {
		case 0:
			return [self processLocationInfo:tableView];
			
		case 1:
			return [self checkinMessage:tableView];

		case 2:
			return [self socialMediaOptions:tableView row: [indexPath row]];
			
		default:
			break;
	}
	return NULL;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 	

}


- (void) tableView:(UITableView *) tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *) indexPath {
	
}

#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	
	if (attachMsg) 
		return TRUE;
	
	checkinMsg.textColor = [UIColor blackColor];
	checkinMsg.text = @"";
	attachMsg = TRUE;
	
	return TRUE;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//	NSLog(@"xxxxxx %@", text);
	NSUInteger charLeft = MAX_STATUS_LENGTH - [textView.text length];
	
	if ([text isEqualToString:@"\n"])
		[textView resignFirstResponder];

	if (charLeft == 0) {
		[textView resignFirstResponder];
		return FALSE;
	}
	return TRUE;
}

- (void)textViewDidChange:(UITextView *)textView  {
	
	NSUInteger len = [textView.text length];
	NSUInteger charLeft = MAX_STATUS_LENGTH - len;
	
	if (len && (charLeft == 0 )) 
		[textView resignFirstResponder];

	if (len && [textView.text characterAtIndex:len-1] == '\n') 
		[textView resignFirstResponder];

	NSString *labelText = [NSString stringWithFormat:@"%d", charLeft];
	
	maxCharLbl.text = labelText;
//	NSLog(@"labelText - char=%c retain count=%lx", [textView.text characterAtIndex:len-1],[labelText retainCount]);
//	[labelText release];
}




- (BOOL)textViewShouldEndEditing:(UITextView *)textView  {
	return YES;
}




- (void)textViewDidEndEditing:(UITextView *)textView {
	textView.text = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
}





#pragma mark private



-(IBAction) doCheckin 
{
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; XXXX
	
	
//	[self performSelectorInBackground:@selector(checkinStatusIpdate) withObject:nil ];	

//	NSInvocationOperation * genOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(checkinStatusIpdate) object:nil];
//    [[Mizoon  sharedMizoon].operationQueue  addOperation:genOp];
//    [genOp release];

	
	/*  TRY THIS
	[self performSelector:@selector(stopUpdatingLocation:) withObject:@"Timed Out" afterDelay:[[setupInfo objectForKey:kSetupInfoKeyTimeout] doubleValue]];

	*/
	[[Mizoon sharedMizoon] temporaryCheckin];
	[[[Mizoon sharedMizoon] getRootViewController] popView];
	[self performSelector:@selector(checkinStatusUpdate) withObject:nil afterDelay:0 ];
//	[self performSelectorInBackground:@selector(checkinStatusUpdate) withObject:nil ];  // FB and twitter are not updated!

#if 0
	Mizoon *miz = [Mizoon  sharedMizoon];
			
	if (attachMsg) {
		[miz checkinWithMessage: self.checkinMsg.text];
		
	} else {
		[miz checkinSelectedLocation];
	}
	
	if (postToFB)
		if (attachMsg) 
			[miz setFBStatus:self.checkinMsg.text atLocation: [miz getSelectedLocation]];
		else 
			[miz setFBStatus:NULL atLocation: [miz getSelectedLocation]];
	
	if (postToTwt)
		if (attachMsg) 
			[miz postToTwitter:self.checkinMsg.text atLocation: [miz getSelectedLocation]];
		else 
			[miz postToTwitter:nil atLocation: [miz getSelectedLocation]];
	
#endif	
	
	[[[Mizoon  sharedMizoon] getRootViewController] renderView:CHECKED_IN_VIEW fromView:SHARE_CHECKIN_VIEW];
	
//	[pool release]; XXXX
}


- (void) checkinStatusUpdate
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	Mizoon *miz = [Mizoon  sharedMizoon];
		
	if (attachMsg) {
		[miz checkinWithMessage: self.checkinMsg.text];
		
	} else {
		[miz checkinSelectedLocation];
	}
	
	[miz resetTmpCheckin];
	

	/*********************** FB TEST ***************************
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Facebook developer support sucks",@"message",
                                   @"Suck it!",@"name",
								   @"http://www.bushmackel.com/2010/01/11/facebook-development-sucks/", @"link",
								   @"http://www.flatblackfilms.com/finger.JPG", @"picture",
                                   nil];	
	[miz.fbSession requestWithGraphPath:@"/me/feed"   // or use page ID instead of 'me'
	                          andParams:params
	                      andHttpMethod:@"POST"
	                        andDelegate:miz];

	**********************************************************/
	
	if (postToFB)
		if (attachMsg) 
			[miz setFBStatus:self.checkinMsg.text atLocation: [miz getSelectedLocation]];
		else 
			[miz setFBStatus:NULL atLocation: [miz getSelectedLocation]];
	
	if (postToTwt)
		if (attachMsg) 
			[miz postToTwitter:self.checkinMsg.text atLocation: [miz getSelectedLocation]];
		else 
			[miz postToTwitter:nil atLocation: [miz getSelectedLocation]];
	
	[pool release];
}

- (UITableViewCell *) processLocationInfo: (UITableView *) tableView {
	
	Mizoon *miz = [Mizoon sharedMizoon];
	MizoonLocation *loc;
	NSString *cityState;

	
	static NSString *CellIdentifier = @"ShareCheckinCell";	

	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//	tableView.backgroundColor = [UIColor grayColor];
	tableView.backgroundColor = [UIColor clearColor];

//	tableView.separatorColor = [UIColor grayColor];
	tableView.separatorColor = [UIColor clearColor];


	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.backgroundColor = [UIColor clearColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

	
		nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 5.0, 220.0, 18.0)];
		nameLbl.tag = kLocNameTag;
		nameLbl.textAlignment = UITextAlignmentLeft;
		nameLbl.textColor = [UIColor whiteColor];
		nameLbl.backgroundColor = [UIColor clearColor];
		nameLbl.font = [UIFont boldSystemFontOfSize:LOCATION_INFO_FONT_SIZE];
		[cell addSubview:nameLbl];
	
		addressLbl = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0, 220.0, 18.0)];
		addressLbl.tag = kLocAddressTag;
		addressLbl.textAlignment = UITextAlignmentLeft;
		addressLbl.textColor = [UIColor whiteColor];
		addressLbl.backgroundColor = [UIColor clearColor];
		addressLbl.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];
		[cell addSubview:addressLbl];
	
		cityStateLbl = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 35.0, 240.0, 18.0)];
		cityStateLbl.textAlignment = UITextAlignmentLeft;
		cityStateLbl.textColor = [UIColor whiteColor];
		cityStateLbl.backgroundColor = [UIColor clearColor];
		cityStateLbl.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];
		[cell addSubview:cityStateLbl];
	}	


	loc = [miz getSelectedLocation];
	nameLbl.text = loc.name;
	addressLbl.text = loc.address;

	if (loc.zip && [loc.zip isEqualToString:@"0"]) 
		cityState = [[NSString alloc] initWithFormat:@"%@, %@", loc.city, loc.state];
	else
		cityState = [[NSString alloc] initWithFormat:@"%@, %@ %@", loc.city, loc.state, loc.zip];

	cityStateLbl.text = cityState;
	[cityState release];

	return cell;
}



- (UITableViewCell *) checkinMessage: (UITableView *) tableView {

	static NSString *CellIdentifier = @"CheckinTextCell";	
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	checkinMsg = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 5.0, 280.0, 85.0)];
	//			checkinMsg.backgroundColor = [UIColor grayColor];
	checkinMsg.scrollEnabled = NO;
	checkinMsg.delegate = self;
	checkinMsg.keyboardType = UIKeyboardTypeDefault;
	checkinMsg.returnKeyType = UIReturnKeyDone;
	checkinMsg.textColor = [UIColor grayColor];
	checkinMsg.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];

	checkinMsg.text = @"Check in message? (optional)";
	[cell addSubview:checkinMsg];
	
	maxCharLbl = [[UILabel alloc] initWithFrame:CGRectMake(280.0, 70.0, 25.0, 18.0)];
	maxCharLbl.textAlignment = UITextAlignmentLeft;
	maxCharLbl.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];
	maxCharLbl.text = @"140";
	[cell addSubview:maxCharLbl];
	
	return cell;
}



- (UITableViewCell *) socialMediaOptions: (UITableView *) tableView row: (NSInteger) rowNumber 
{	
	Mizoon	*miz = [Mizoon sharedMizoon];
	
	static NSString *CellIdentifier = @"SocialMediaCell";	
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (rowNumber == 0) {	// Facebook
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			
			UILabel *smLbl = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 14.0, 220.0, 18.0)];
			smLbl.tag = kSocialMediaTag;
			smLbl.textAlignment = UITextAlignmentLeft;
			smLbl.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];
			smLbl.text = @"Post to Facebook";
			[cell addSubview:smLbl];
			
			if (![miz isUserFBAuthenticated]) {
//				fbLoginButton = [[[FBLoginButton alloc] initWithFrame:CGRectMake(198.0, 12.0, 94.0, 27.0)] autorelease];
//				[cell addSubview:fbLoginButton];
				UIButton *fbBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
				fbBtn.frame = CGRectMake(192.0, 12.0, 94.0, 27.0);
				
				[fbBtn setImage:[UIImage imageNamed:@"FBConnect.bundle/images/LoginNormal.png"] forState:UIControlStateNormal];
				[fbBtn setImage:[UIImage imageNamed:@"FBConnect.bundle/images/LoginPressed.png"] forState: UIControlStateHighlighted |UIControlStateSelected];
				[fbBtn addTarget:self action:@selector(fbLogin) forControlEvents:UIControlEventTouchUpInside];	
				
//				[cell.contentView addSubview:fbBtn];
				[cell addSubview:fbBtn];

//				[fbBtn release];
				
			} else {
				if (switchCtl == nil)  {
					switchCtl = [UISwitch switchWithLeftText:@"YES" andRight:@"NO"];
					switchCtl.center = CGPointMake(250.0f, 20.0f);
					[switchCtl addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
					
					// in case the parent view draws with a custom color or gradient, use a transparent color
					switchCtl.backgroundColor = [UIColor clearColor];
					
					[switchCtl setAccessibilityLabel:NSLocalizedString(@"StandardSwitch", @"")];
					switchCtl.on = TRUE;
					
				}
				[cell addSubview:switchCtl];
			}
		}
	
		/*******************
		FBPermissionDialog* dialog = [[[FBPermissionDialog alloc] init] autorelease];
		dialog.delegate = self;
		dialog.permission = @"read_stream, publish_stream, read_friendlists, photo_upload";
		[dialog show];
		*******************/
		return cell;
	}
	
	// Twitter
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		
		UILabel *smLbl = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 8.0, 150.0, 18.0)];
		smLbl.tag = kSocialMediaTag;
		smLbl.textAlignment = UITextAlignmentLeft;
		smLbl.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];
		smLbl.text = @"Post to Twitter";
		[cell addSubview:smLbl];
		
		if (![miz isLoggedInTwitter]) {
			UIButton *twitterBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			[twitterBtn setImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
			twitterBtn.frame = CGRectMake(190.0, 2.0 , 90.0 ,30.0);
			[twitterBtn addTarget:self action:@selector(twitterLogin:) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:twitterBtn];
		} else {
			if (twtSwitchCtl == nil)  {
				twtSwitchCtl = [UISwitch switchWithLeftText:@"YES" andRight:@"NO"];
				twtSwitchCtl.center = CGPointMake(250.0f, 16.0f);

				[twtSwitchCtl addTarget:self action:@selector(twtSwitchAction:) forControlEvents:UIControlEventValueChanged];
				
				// in case the parent view draws with a custom color or gradient, use a transparent color
				twtSwitchCtl.backgroundColor = [UIColor clearColor];
				
				[twtSwitchCtl setAccessibilityLabel:NSLocalizedString(@"StandardSwitch", @"")];
				twtSwitchCtl.on = TRUE;
				
			}
			[cell addSubview:twtSwitchCtl];
		}
	}
	
	return cell;	

}



- (void) fbLogin
{
	[[Mizoon sharedMizoon] mizFBLogin];
}


- (void)switchAction:(id)sender
{
	MizoonLog(@"switchAction: value = %d", [sender isOn]);
	if ([sender isOn]) {
		postToFB = YES;
	} else {
		postToFB = NO;
	}
}



- (void) twtSwitchAction:(id)sender
{
	MizoonLog(@"switchAction: value = %d", [sender isOn]);
	if ([sender isOn]) {
		postToTwt = YES;
	} else {
		postToTwt = NO;
	}
}



- (IBAction) twitterLogin: (id) sender
{
	TwtOAuthController *twtControllerView = [[TwtOAuthController alloc] init];
	[self.view insertSubview:twtControllerView.view atIndex:0];
	[self.view bringSubviewToFront:twtControllerView.view];
	self.twtController = twtControllerView;
	[twtControllerView release];
	
	return;
}



@end
