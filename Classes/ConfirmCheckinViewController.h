//
//  ShareCheckinViewController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 6/14/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import	"MizDataManager.h"
#import	"TwtOAuthController.h"
#import "FBConnect.h"

@interface ConfirmCheckinViewController : UIViewController    <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate,FBDialogDelegate> {
	UILabel		*nameLbl;
	UILabel		*addressLbl;
	UILabel		*cityStateLbl;
	UITextView	*checkinMsg;
	UILabel		*maxCharLbl;
	UISwitch	*switchCtl;
	UISwitch	*twtSwitchCtl;
	BOOL		attachMsg;
	UIButton	*confirmCK;
	
//	IBOutlet FBLoginButton	*fbLoginButton;
	TwtOAuthController		*twtController;
	BOOL		postToFB;
	BOOL		postToTwt;
}

@property (nonatomic, retain) UILabel *nameLbl;
@property (nonatomic, retain) UILabel *addressLbl;
@property (nonatomic, retain) UILabel *cityStateLbl;
@property (nonatomic, retain) UITextView *checkinMsg;
@property (nonatomic, retain) UIButton *confirmCK;

@property (nonatomic, retain) UILabel *maxCharLbl;
@property (nonatomic, retain, readonly) UISwitch *switchCtl;
@property (nonatomic, retain, readonly) UISwitch *twtSwitchCtl;

@property (nonatomic, retain) TwtOAuthController *twtController;
@property BOOL attachMsg;
@property BOOL postToFB;
@property BOOL postToTwt;


@end
