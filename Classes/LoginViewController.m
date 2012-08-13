//
//  MizLoginController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 2/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import	"MizDataManager.h"
#import	"NSString+Util.h"
#import	"MizoonServer.h"


@interface LoginViewController()  // private methods
- (void) moveViewUp;
- (void) moveViewDown;
- (BOOL) mizAuthenticate: (NSString *) username withPassword: (NSString *) password;

@end



@implementation LoginViewController
@synthesize	rootViewController, password, uid, errorMsg;


- (BOOL) mizAuthenticate: (NSString *) username withPassword: (NSString *) password {
//	MizoonServer *ms = [MizoonServer sharedMizoonServer];
	return TRUE;
}




 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	 uid.delegate = self;
	 password.delegate = self;
	 
 }



- (IBAction) removeKeyboard:(id) sender {
	[password resignFirstResponder];
	[uid resignFirstResponder];
	[self moveViewDown];
}



- (IBAction) loginButtonPressed:(id) sender {
//    MizDataManager *dm = [MizDataManager sharedDataManager];
	
	MizoonLog( @"Username=%@- password=%@-",uid.text, password.text	);
	
	[password resignFirstResponder];
	[uid resignFirstResponder];
	[self moveViewDown];
	
	
	// Need to validate the uid and passord here
	if ([uid.text isEmpty] || [password.text isEmpty] || [password.text hasWhitespace]) {
		// add error to the dialog
		[self moveViewDown];
		errorMsg.text = @"Please enter a vlaid username and password";
		
		return;
	}



}



- (IBAction) clearErrorMsg:(id) sender {
	errorMsg.text = @"";
}



- (IBAction) registerButtonPressed:(id) sender {
}


- (IBAction) cancelButtonPressed:(id) sender {
	RootViewController *rvc = self.rootViewController;
	
	uid.text = NULL;
	password.text = NULL;
	[self moveViewDown];
	
	[rvc goBack];
}

/*
- (IBAction) textFieldGo:(id) sender {
	[self moveViewDown];

	[sender resignFirstResponder];
}
*/
- (IBAction) beginTextInput:(id) sender {
	
	[self moveViewUp];
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
	
	if (textField == password) {
		[textField resignFirstResponder];
	}
}




- (BOOL) textFieldShouldReturn: (UITextField *) textField {
	if (textField == uid) {
		[self.password becomeFirstResponder];
	}
	if (textField == password) {
		[textField resignFirstResponder];
	}
	
	
	return NO;
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
	frame.origin.y = -60;
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


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/
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
	MizoonLog(@"---------------> didReceiveMemoryWarning: LoginView");

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[uid	release];
	[password release];
	[errorMsg	release];
    [super dealloc];
}


@end
