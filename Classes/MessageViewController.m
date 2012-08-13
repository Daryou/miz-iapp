//
//  MessageViewController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 6/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MessageViewController.h"
#import	"Mizoon.h"
#import	"MizProgressHUD.h"

@interface MessageViewController() // private
- (void) sendTheMessage;
@end


@implementation MessageViewController
@synthesize	msgTextView;



 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
//		self.view.frame = CGRectMake(0.0, 0, 320.0, 480.0);
//		[self.view.frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 440.0);
		
		
		self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];

	Mizoon *miz = [Mizoon sharedMizoon];

	UIToolbar	*toolbar = (UIToolbar *)[self.view viewWithTag:800];
	
	[msgTextView becomeFirstResponder];
	UILabel *test = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 2.0, 180.0, 20.0)];
	test.textAlignment = UITextAlignmentLeft;
	test.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0];
	test.textColor = [UIColor colorWithWhite:1.0 alpha:1];

	test.font = [UIFont systemFontOfSize:14.0];
	test.text = [[NSString alloc] initWithFormat: @"Message to %@", [miz getSelectedPersonUName]];

	UIBarButtonItem *photoButton = [[UIBarButtonItem alloc] initWithCustomView:test];

	cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelMessage)];
	postButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(sendPrivateMessage)];
	
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	[toolbar setItems:[NSArray arrayWithObjects:photoButton, postButton, flexibleSpace,  cancelButton,nil]];
		
	[self.view addSubview:toolbar];		
	[flexibleSpace release];
	[photoButton	release];  // xxx
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
	MizoonLog(@"---------------> didReceiveMemoryWarning: MessageView");

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark helper



- (void) cancelMessage {
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *rvc = delegate.rootViewController;
	
	[rvc popView];
	[rvc renderView:A_PERSON_VIEW fromView:SEND_MESSAGE_VIEW];
}


- (void) sendPrivateMessage 
{		
#if 0
	progressAlert = [[MizProgressHUD alloc] initWithLabel:@"Sending..."];
	[progressAlert show];
	
	[self performSelector:@selector(sendTheMessage) withObject:nil afterDelay:1.0];			 
	[self dismissModalViewControllerAnimated:YES];
#else
	[self sendTheMessage];
#endif
}



- (void) sendTheMessage 
{	
#if 0
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	Mizoon *miz = [Mizoon sharedMizoon];
	MizDataManager *md = [MizDataManager sharedDataManager];
	RootViewController *rvc = [miz getRootViewController];

	@try {
		[md sendMessage: msgTextView.text recipient: [miz getSelectedPersonUID]];
	}
	@catch (NSException * e) {
		MizoonLog(@"xxx hasn't been retained before!");
	}
	
	[progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    [progressAlert release];
	
	[self dismissModalViewControllerAnimated:YES];
		
	[rvc popView];
	[rvc renderView:rvc.prevView fromView:SEND_MESSAGE_VIEW];
	
	[pool release];
#else
	Mizoon *miz = [Mizoon sharedMizoon];
	MizDataManager *md = [MizDataManager sharedDataManager];
	RootViewController *rvc = [miz getRootViewController];
	
	@try {
		[md sendMessage: msgTextView.text recipient: [miz getSelectedPersonUID]];
	}
	@catch (NSException * e) {
		MizoonLog(@"xxx hasn't been retained before!");
	}
		
	[rvc popView];
	[rvc renderView:rvc.prevView fromView:SEND_MESSAGE_VIEW];
	
#endif	
}



@end
