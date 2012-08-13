//
//  registerViewController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 3/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"MizProgressHUD.h"

#define tUsername			1
#define tPassword			2
#define tEmail				3
#define tZip				4
#define tPhone				6

@interface RegisterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>{
	UITextField		*username;
	UITextField		*email;
	UITextField		*password;
	UITextField		*zip;
	UITextField		*phone;
	UIButton		*joinButton;
	UIButton		*backButton;
	
//	MizProgressHUD	*progressAlert;
}

@property (nonatomic, retain) UITextField	*username;
@property (nonatomic, retain) UITextField	*email;
@property (nonatomic, retain) UITextField	*password;
@property (nonatomic, retain) UITextField	*zip;
@property (nonatomic, retain) UITextField	*phone;
@property (nonatomic, retain) UIButton		*joinButton;


- (IBAction) goToRegLoginView:(id) sender;
- (IBAction) joinMizoon:(id) sender;
- (IBAction) beginTextInput:(id) sender;

@end
