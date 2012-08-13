//
//  SigninViewController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 3/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SigninViewController.h"
#import	"MizoonAppDelegate.h"
#import	"LocationController.h"
#import	"RootViewController.h"

#import	"MizDataManager.h"




@interface SigninViewController()  // private methods
- (void) moveViewUp;
- (void) moveViewDown;
@end


@implementation SigninViewController
@synthesize	uid, password;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	
    [super viewDidLoad];
	
	self.view.frame = CGRectMake(0.0, 0, 320.0, 460.0);		
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-l.png"]];

//	[rvc.view bringSubviewToFront:[rvc.view viewWithTag:2000]];  // top bar
//	[rvc.view bringSubviewToFront:[rvc.view viewWithTag:2001]];		// home button
//	[rvc.view bringSubviewToFront:[rvc.view viewWithTag:2002]];		// back button

	uid.delegate = self;
	password.delegate = self;
	
	[[[Mizoon sharedMizoon] getRootViewController] hideHomeButton];
}

- (IBAction) beginTextInput:(id) sender {
	MizoonLog(@"beginTextInut");
	[self moveViewUp];
}



- (IBAction) removeKeyboard:(id) sender {
	[password resignFirstResponder];
	[uid resignFirstResponder];
	[self moveViewDown];
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
	frame.origin.y = -110;
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


- (IBAction) goToRegLoginView:(id) sender
{
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *rvc = delegate.rootViewController;
	
	
	/******** TEST ***************/
	MizDataManager *dm = [MizDataManager sharedDataManager];
	MizoonLog(@"dp's password is=%@", [dm getMizPasswordFromKeychainWithUsername:@"dp"]);
	/****************************/

	
	[rvc renderView:REG_LOGIN_VIEW  fromView: SIGN_IN_VIEW];	
}

/*
- (void)textFieldDidEndEditing:(UITextField *)textField {
	MizoonLog(@"textFieldDidEndEditing");	

	if (textField == password) {
		[textField resignFirstResponder];
	}
}
*/

- (IBAction) textFieldDone:(id) sender
{
	UITextField *theField = (UITextField *) sender;
	
	if (theField == uid) {
		MizoonLog(@"textFieldDone -- uid");	

		[self.password becomeFirstResponder];
	}
	if (theField == password) {
		MizoonLog(@"textFieldDone -- password");	

		[theField resignFirstResponder];
	}
	MizoonLog(@"textFieldDone");	
}


- (BOOL) textFieldShouldReturn: (UITextField *) textField 
{
	Mizoon *miz = [Mizoon sharedMizoon];
	RootViewController *rvc = [miz getRootViewController];
	
	MizoonLog(@"textFieldShouldReturn");	

	if (textField == uid) {
		[self.password becomeFirstResponder];
	}
	if (textField == password) {
		NSString *username = [self.uid.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		if ([username length] == 0) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing username" message:@"Please enter your username" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
			[alert show];
			[alert release];
			
			[self.uid resignFirstResponder];
		} else {
			if ([self.password.text length] == 0) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid password" message:@"Please enter a valid password" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
				[alert show];
				[alert release];
				
				[textField resignFirstResponder];
			}	else {
				MizDataManager *dm = [MizDataManager sharedDataManager];
				if (![dm authenticate:username withPaswword:self.password.text]) {
					if (![miz hasNetworkConnection]) {
						[miz networkConnectionAlert];
						return NO;
					}
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Failed" message:@"Your username or password may be incorrent" delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
					[alert show];
					[alert release];
					[self.uid becomeFirstResponder];
				} else {
					[rvc renderView:MAIN_VIEW  fromView: SIGN_IN_VIEW];
					rvc.locationController = [[LocationController alloc] init];
//					[rvc.locationController getLocation];

				}

			}
		}

	}
	
	
	return NO;
}




 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

//		self.view.frame = CGRectMake(0.0, 0, 320.0, 460.0);		
//		self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
		
		
	}
    return self;
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
	MizoonLog(@"---------------> didReceiveMemoryWarning: SigninViewController");

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[password release];
	[uid	release];
    [super dealloc];
}


@end
