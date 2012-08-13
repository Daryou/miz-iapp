//
//  RegLoginViewController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 3/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RegLoginViewController.h"
#import "RootViewController.h"

#import	"MizoonAppDelegate.h"


@implementation RegLoginViewController




// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
		
		self.view.frame = CGRectMake(0.0, 0, 320.0, 460.0);		
		self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-l.png"]];
		
		UIButton *signinBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[signinBtn setImage:[UIImage imageNamed:@"register-bg.png"] forState:UIControlStateNormal];
		signinBtn.frame = CGRectMake( 50.0, 250.0 , 220	, 37);
		[signinBtn addTarget:self action:@selector(userLogin:) forControlEvents:UIControlEventTouchUpInside];	
		[self.view addSubview:signinBtn];
		[signinBtn release];

		UIButton *signupBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[signupBtn setImage:[UIImage imageNamed:@"signup-bg.png"] forState:UIControlStateNormal];
		signupBtn.frame = CGRectMake( 50.0, 295.0 , 220	, 37);
		[signupBtn addTarget:self action:@selector(userRegister:) forControlEvents:UIControlEventTouchUpInside];	
		[self.view addSubview:signupBtn];
		[signupBtn release];
		
//		UIButton *b1 = (UIButton *) [self.view viewWithTag: 20];
//		b1.backgroundColor = [UIColor	clearColor];
//		b1.showsTouchWhenHighlighted = NO;
//		b1.reversesTitleShadowWhenHighlighted = NO;
//		b1.highlighted = NO;

		
	}
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
}



/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
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
	MizoonLog(@"---------------> didReceiveMemoryWarning: RegLoginView");

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}



- (IBAction) userLogin: (id) sender
{
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *rvc = delegate.rootViewController;

	[rvc renderView:SIGN_IN_VIEW fromView: REG_LOGIN_VIEW];

	MizoonLog(@"User login");
}



- (IBAction) userRegister: (id) sender
{
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *rvc = delegate.rootViewController;
	
	[rvc renderView:REGISTER_VIEW fromView: REG_LOGIN_VIEW];
	
	MizoonLog(@"User register");

}


@end
