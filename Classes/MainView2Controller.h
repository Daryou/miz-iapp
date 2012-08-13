//
//  MainView2Controller.h
//  Mizoon
//
//  Created by Daryoush Paknad on 8/6/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainView2Controller : UIViewController {
	NSTimer *timer;
}

- (IBAction) settingButtonPressed:(id) sender;
- (IBAction) nightLButtonPressed:(id) sender;
- (IBAction) shoppingPressed:(id) sender; 
- (IBAction) lodgingPressed:(id) sender; 

@end
