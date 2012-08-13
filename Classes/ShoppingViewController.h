//
//  ShoppingViewController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 10/14/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import	"Constants.h"



@interface ShoppingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView			*shoppingTableView;
	NSTimer				*timer;
	
#ifdef	PULL_REFRESH
	EGORefreshTableHeaderView *refreshHeaderView;
	BOOL _reloading;
#endif
	
}

@property (nonatomic, retain)  UITableView			*shoppingTableView;

#ifdef	PULL_REFRESH
@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;

- (void)reloadTableViewDataSource;
- (void)dataSourceDidFinishLoadingNewData;
#endif



@end
