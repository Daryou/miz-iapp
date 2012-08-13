//
//  MessageViewController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 6/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MessageViewController : UIViewController {
	IBOutlet UITextView		*msgTextView;

	UIBarButtonItem			*postButton;
	UIBarButtonItem			*cancelButton;
	
	UIAlertView				*progressAlert;
}

@property (nonatomic, retain) IBOutlet UITextView	*msgTextView;

@end
