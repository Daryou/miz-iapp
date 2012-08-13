//
//  View_SwitcherAppDelegate.h
//  View Switcher
//
//  Created by Daryoush Paknad on 12/16/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;


@interface MizoonAppDelegate : NSObject <UIApplicationDelegate> {
//@interface MizoonAppDelegate : NSObject <UIApplicationDelegate> {

    UIWindow *window;
	RootViewController *rootViewController;
	
	BOOL alertRunning;
	NSMutableData *statsData;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property (nonatomic, getter = isAlertRunning) BOOL alertRunning;


- (void) checkIfStatsShouldRun;
- (void) runStats;

@end

