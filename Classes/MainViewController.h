//
//  BlueViewController.h
//  View Switcher
//
//  Created by Daryoush Paknad on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface MainViewController : UIViewController {
	RootViewController *rootController;
	NSTimer *timer;
//	UIAlertView					*progressAlert;
}
@property (nonatomic, retain) IBOutlet RootViewController *rootController;

- (IBAction) blueButtonPressed:(id) sender;
- (IBAction) placesButtonPressed:(id) sender;
- (IBAction) postsButtonPressed:(id) sender;
- (IBAction) promoButtonPressed:(id) sender;
- (IBAction) peopleNearButtonPressed:(id) sender;
- (IBAction) cafeNearButtonPressed:(id) sender;
- (IBAction) restaurantButtonPressed:(id) sender;

- (IBAction) testButtonPressed:(id) sender;


@end
