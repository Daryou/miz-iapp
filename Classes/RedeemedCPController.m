//
//  RedeemedCPController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 5/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RedeemedCPController.h"
#import	"Mizoon.h"

#define	kGainedPoints	40
#define	kPromotionID	80
#define	kLocationNameTag	200

@implementation RedeemedCPController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	Mizoon	*miz = [Mizoon sharedMizoon];
	
    [super viewDidLoad];
	
	UILabel *name = (UILabel *) [self.view viewWithTag: kLocationNameTag];
	name.text = [miz getSelectedLocation].name;
	
	UILabel *prid = (UILabel *) [self.view viewWithTag: kPromotionID];
	prid.text = miz.redeemedCP;
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
	MizoonLog(@"---------------> didReceiveMemoryWarning: RedemmedCP");

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	return;
}


- (void)dealloc {
    [super dealloc];
}


@end
