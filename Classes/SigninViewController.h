//
//  SigninViewController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 3/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SigninViewController : UIViewController <UITextFieldDelegate> {
	UITextField			*uid;
	UITextField			*password;
}

@property (nonatomic, retain) IBOutlet UITextField	*uid;
@property (nonatomic, retain) IBOutlet UITextField	*password;

- (IBAction) textFieldDone:(id) sender;
- (IBAction) goToRegLoginView:(id) sender;
- (IBAction) beginTextInput:(id) sender;
- (IBAction) removeKeyboard:(id) sender;

@end
