//
//  registerViewController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 3/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RegisterViewController.h"
#import	"MizoonAppDelegate.h"
#import	"RootViewController.h"
#import	"MizDataManager.h"
#import	"LocationController.h"

@interface RegisterViewController()
- (void) regMizooner;
- (void) initTextfield: (UITextField *) textfield withPlaceholder: (NSString *) placeholder tag: (int) tag;
- (void) moveViewUp;
- (void) moveViewDown;
- (NSString *) validateFields;
@end


@implementation RegisterViewController

@synthesize	username,email,password,zip,phone, joinButton;



// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
		self.view.frame = CGRectMake(0.0, 0, 320.0, 460.0);		
		[self.view viewWithTag:kViewTableViewTag].frame = CGRectMake(0.0, TOP_BAR_WITH + 40, 320.0, 440.0);
		[self.view viewWithTag:kViewTableViewTag].backgroundColor = [UIColor clearColor];
		self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-l.png"]];

	}
    return self;
}



- (void)viewDidLoad 
{
	[super viewDidLoad];

	username = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 35)];
	[self initTextfield: username withPlaceholder: @"choose a username" tag: (int) tUsername];

	email = [UITextField alloc];
	[self initTextfield: email withPlaceholder: @"your email" tag: (int) tEmail];
	
	password = [UITextField alloc];
	[self initTextfield: password withPlaceholder: @"longer than 5 character" tag: (int) tPassword];
	
	zip = [UITextField alloc];
	[self initTextfield: zip withPlaceholder: @"your postal code" tag: (int) tZip];
	
	phone = [UITextField alloc];
	[self initTextfield: phone withPlaceholder: @"Optional" tag: (int) tPhone];
	
#if 1
	[[[Mizoon sharedMizoon] getRootViewController].view viewWithTag:2001].hidden = TRUE;	// home button
	 
	joinButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[joinButton setImage:[UIImage imageNamed:@"join-button.png"] forState:UIControlStateNormal];
	joinButton.frame = CGRectMake(260, 8 , 50, 30);
	[joinButton addTarget:self action:@selector(joinMizoon:) forControlEvents:UIControlEventTouchUpInside];	
	joinButton.tag = kJoinButtonTag;

//	[self.view addSubview:joinButton];
//	[self.view insertSubview: joinButton aboveSubview: [[[Mizoon sharedMizoon] getRootViewController].view viewWithTag:1000]];
//	[self.view bringSubviewToFront: joinButton];
	
	[[[Mizoon sharedMizoon] getRootViewController].view addSubview:joinButton];
	[joinButton release];
	
	backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[backButton setImage:[UIImage imageNamed:@"back-button.png"] forState:UIControlStateNormal];
	backButton.frame = CGRectMake(10, 8 , 50, 30);
	[backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];	
	[[[Mizoon sharedMizoon] getRootViewController].view addSubview:backButton];
	[backButton release];
	
	
#endif
	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	MizoonLog(@"---------------> didReceiveMemoryWarning: RegisterView");

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



- (void)dealloc 
{
	[username release];
	[email release];
	[zip	release];
	[phone	release];
	[password	release];
	
//	[joinButton removeFromSuperview];
//	[joinButton release];
	[super dealloc];
}


#pragma mark event handlers


- (IBAction) beginTextInput:(id) sender {
	[self moveViewUp];
}

-(void)touchesBegan: (NSSet *)touches withEvent:(UIEvent *)event
{
	MizoonLog(@"-------------------------------------------------------------------");
}


- (void) goBack
{	
	[[[Mizoon sharedMizoon] getRootViewController] goBack];
	[backButton removeFromSuperview];
}


- (IBAction) joinMizoon:(id) sender
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];


	NSString *errMsg = [self validateFields];
	if (errMsg) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration" message:errMsg delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[alert show];
		[alert release];	
		[errMsg release];
		
		return;
	}
	
	[errMsg release];
	[[Mizoon sharedMizoon] showLoadMessage: @"Registering..."];
	
	[self moveViewDown];
	[self resignFirstResponder];

	[self performSelector:@selector(regMizooner) withObject:nil afterDelay:0];	

	[pool release];
	
#if 0
	if (![dm mizoonRegister:username.text withPassword:password.text andEmail:email.text zip:zip.text andPhone:phone.text] ) {
		[self moveViewDown];
		return;
	}
	
	rvc.locationController = [[LocationController alloc] init];
//	[rvc.locationController getLocation];
	[rvc renderView:MAIN_VIEW  fromView: REGISTER_VIEW];	
#endif
}


- (void) regMizooner
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	MizDataManager *dm = [MizDataManager sharedDataManager];
	Mizoon *miz = [Mizoon sharedMizoon];
	RootViewController *rvc = [miz getRootViewController];

	if (![dm mizoonRegister:username.text withPassword:password.text andEmail:email.text zip:zip.text andPhone:phone.text] ) {
		if (![miz hasNetworkConnection]) {
			[miz networkConnectionAlert];
		}
		[miz hideLoadMessage];
		[self moveViewDown];
		return;
	}
	[miz hideLoadMessage];
	rvc.locationController = [[LocationController alloc] init];
	[rvc renderView:MAIN_VIEW  fromView: REGISTER_VIEW];
	
	[pool	release];
	
#if 0
	if (![dm mizoonRegister:username.text withPassword:password.text andEmail:email.text zip:zip.text andPhone:phone.text] ) {
//		[self dismissModalViewControllerAnimated:YES];
//		[self dismissModalViewControllerAnimated:YES];

		return;
	}
//	[self dismissModalViewControllerAnimated:YES];

	[[miz getRootViewController] renderView:MAIN_VIEW  fromView: REGISTER_VIEW];	
#endif
}


- (NSString *) validateFields
{
	NSString *errMsg = nil;
	NSCharacterSet *emailCharSet = [NSCharacterSet characterSetWithCharactersInString:@"@."];
	NSCharacterSet *zipCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789-"] invertedSet];
	NSCharacterSet *phoneCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789-()."] invertedSet];
		
	if ([username.text length] == 0 ) {
		errMsg = [[NSString alloc] initWithString:@"Please enter a username"];
		[username becomeFirstResponder];
		return errMsg;
	}
	
	if ([password.text length] == 0 ) {
		errMsg = [[NSString alloc] initWithString:@"Please enter your desired password"];
		[password becomeFirstResponder];
		return errMsg;

	} else {
		if ([password.text length] < 5 ) {
			errMsg = [[NSString alloc] initWithString:@"Your password needs to be longer than 5 characters"];
			[password becomeFirstResponder];
			return errMsg;
		}
	}
	
	if ([email.text length] == 0 ) {
		errMsg = [[NSString alloc] initWithString:@"Please enter your email address"];
		[email becomeFirstResponder];
		return errMsg;
	} else {
		if ([email.text  rangeOfCharacterFromSet:emailCharSet].location == NSNotFound) {
			errMsg = [[NSString alloc] initWithString:@"Please enter a valid email address"];
			[email becomeFirstResponder];
			return errMsg;
		}
	}
	
	
	if ([zip.text length] == 0 ) {
		errMsg = [[NSString alloc] initWithString:@"Please enter your zip code"];
		[zip becomeFirstResponder];
		return errMsg;		
	} 
	if ([zip.text length] != 5 ) {
		errMsg = [[NSString alloc] initWithString:@"Please enter a valid 5 digit zip code"];
		[zip becomeFirstResponder];
		return errMsg;		
	} else {
		if ([zip.text  rangeOfCharacterFromSet:zipCharSet].location != NSNotFound) {
			errMsg = [[NSString alloc] initWithString:@"Please enter a valid zip code"];
			[zip becomeFirstResponder];
			return errMsg;			
		}
	}
	
	if ([phone.text length] != 0 ) {
		if ([phone.text  rangeOfCharacterFromSet:phoneCharSet].location != NSNotFound) {
			errMsg = [[NSString alloc] initWithString:@"Please enter a valid phone number"];
			[self moveViewUp];
			[phone becomeFirstResponder];
			return errMsg;
		}
	} else {
		phone.text = @" ";  // hack -- xmlrpc handler on the server sides expects fixed number of args
	}

	
	return errMsg;
}


// "Back" button handler
- (IBAction) goToRegLoginView:(id) sender
{
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *rvc = delegate.rootViewController;
	
	
	[rvc renderView:REG_LOGIN_VIEW  fromView: REGISTER_VIEW];	
}


- (void) initTextfield: (UITextField *) textfield withPlaceholder: (NSString *) placeholder tag: (int) tag
{
	
	[textfield initWithFrame:CGRectMake( 120,8,180,20)];
	
	textfield.placeholder = placeholder;
	textfield.tag = tag;
	
	textfield.keyboardType = UIKeyboardTypeDefault;

	if (textfield == phone || textfield == zip) 
		textfield.returnKeyType = UIReturnKeyJoin;
	else	
		textfield.returnKeyType = UIReturnKeyNext;

	if (textfield == password) 
		textfield.secureTextEntry = YES;
	
	textfield.backgroundColor = [UIColor whiteColor];
	textfield.autocorrectionType = UITextAutocorrectionTypeNo;
	textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
	textfield.textAlignment = UITextAlignmentLeft;
	textfield.clearButtonMode = UITextFieldViewModeNever;
	textfield.font = [UIFont fontWithName:MIZOON_FONT size:15.0f];

	textfield.delegate = self;
	
	[textfield setEnabled:YES];
}


// Move the view up by 40 px as soon as the uid filed is clicked.
// called from beginTextInput Action
- (void) moveViewUp {
	//	CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 130.0);
	
	CGRect frame = self.view.frame;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.75];
	
	// Slide up based on y axis
	// A better solution over a hard-coded value would be to
	// determine the size of the title and msg labels and 
	// set this value accordingly
	frame.origin.y = -40;
	self.view.frame = frame;
	
	[UIView commitAnimations];
	
	//	[super setTransform:myTransform];
}



- (void) moveViewDown {
	//	CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 130.0);
	
	CGRect frame = self.view.frame;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.75];
	
	// Slide up based on y axis
	// A better solution over a hard-coded value would be to
	// determine the size of the title and msg labels and 
	// set this value accordingly
	frame.origin.y = 0;
	self.view.frame = frame;
	
	[UIView commitAnimations];
	
	//	[super setTransform:myTransform];
}



#pragma mark Table view methods




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  
{  	
	return 35.0; //returns floating point which will be used for a cell row height at specified row index  
}  



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//	tableView.backgroundColor = [UIColor colorWithRed:0/255.0 green:180/255.0 blue:220/255.0 alpha:1.0];
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.textColor = [UIColor colorWithRed:64/255.0 green:142/255.0 blue:206/255.0 alpha:1.0];

		switch ([indexPath row]) {
			case 0: 
				[cell addSubview: username];
				break;
				
			case 1: 			
				[cell addSubview: email];
				break;
	
			case 2: 			
				[cell addSubview: password];
				break;

			case 3: 			
				[cell addSubview: zip];
				break;

			case 4: 			
				[cell addSubview: phone];
				break;
				
			default:
				break;
		}
    }

    switch ([indexPath row]) {
		case 0:
			cell.textLabel.text = @"Username:";
			break;
		case 1:
			cell.textLabel.text = @"Email:";
			break;
		case 2:
			cell.textLabel.text = @"Password:";
			break;
		case 3:
			cell.textLabel.text = @"Zip:";
			break;
		case 4:
			cell.textLabel.text = @"Phone:";
			break;
		default:
			break;
	}
    // Set up the cell...
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
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

#pragma mark textfield delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	MizoonLog(@"textFieldDidEndEditing");	
}


- (void) textFieldDidBeginEditing:(UITextField *)textField
{
//	if (textField.tag == tPhone) 
		[self moveViewUp];
}
	

- (BOOL) textFieldShouldReturn: (UITextField *) textField 
{
	
	switch (textField.tag) {
		case tUsername:
//			[username resignFirstResponder];
			[email becomeFirstResponder];

			break;
		case tEmail:
			[password becomeFirstResponder];
			break;
		case tPassword:
			[zip becomeFirstResponder];
			break;
		case tZip:
			[self moveViewUp];
			[phone becomeFirstResponder];
			break;
		case tPhone:
			[self moveViewUp];
			[username resignFirstResponder];
			[email resignFirstResponder];
			[password resignFirstResponder];
			[zip resignFirstResponder];
			[phone resignFirstResponder];
			[self joinMizoon:(id) textField];

			break;
		default:
			break;
	}
	MizoonLog(@"textFieldShouldReturn");	
	
	
	return NO;
}


@end

