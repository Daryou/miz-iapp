//
//  SettingsViewController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 3/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import	"MizDataManager.h"
#import	"TwtOAuthController.h"

#define	TWITTER_SERVICE 0
#define	MIZOON_SRV		1
#define	FB_SERVICE		2





@interface SettingsViewController: UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
//	IBOutlet FBLoginButton	*fbLoginButton;
	TwtOAuthController		*twtView;
	NSUInteger				logoutOfService;
}

@property (nonatomic, retain) TwtOAuthController *twtView;
@property	NSUInteger	logoutOfService;

- (IBAction) signOut: (id) sender;

@end
