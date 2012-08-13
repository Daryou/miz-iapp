//
//  NightLifeViewController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 9/30/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import	"Constants.h"

@interface NightLifeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView			*NLTableView;
	NSTimer				*timer;
	
#ifdef	PULL_REFRESH
	EGORefreshTableHeaderView *refreshHeaderView;
	BOOL _reloading;
#endif
	
}

@property (nonatomic, retain)  UITableView			*NLTableView;

#ifdef	PULL_REFRESH
@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;

- (void)reloadTableViewDataSource;
- (void)dataSourceDidFinishLoadingNewData;
#endif


@end
