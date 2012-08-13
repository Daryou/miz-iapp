//
//  MizLoginController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 2/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"


@interface LoginViewController : UIViewController <UITextFieldDelegate> {
	UITextField			*uid;
	UITextField			*password;
	UILabel				*errorMsg;
	RootViewController	*rootViewController;	
}

@property (nonatomic, retain) IBOutlet RootViewController	*rootViewController;
@property (nonatomic, retain) IBOutlet UITextField			*uid;
@property (nonatomic, retain) IBOutlet UITextField			*password;
@property (nonatomic, retain) IBOutlet UILabel				*errorMsg;

- (IBAction) loginButtonPressed:(id) sender;
- (IBAction) registerButtonPressed:(id) sender;
- (IBAction) cancelButtonPressed:(id) sender;
- (IBAction) beginTextInput:(id) sender;
- (IBAction) removeKeyboard:(id) sender;
- (IBAction) clearErrorMsg:(id) sender;





@end
