//
//  ExtLocationViewController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 2/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"


@interface ALocationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

	RootViewController	*rootViewController;
	NSInteger			numSections;
	BOOL				hasVisitors;
	BOOL				hasReviews;
}

@property (nonatomic, retain) RootViewController	*rootViewController;
@property NSInteger	numSections;
@property BOOL		hasVisitors;
@property BOOL		hasReviews;

@end
