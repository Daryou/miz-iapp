//
//  LocationPromotions.h
//  Mizoon
//
//  Created by Daryoush Paknad on 5/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"Constants.h"
#import	"EGORefreshTableHeaderView.h"


//@interface LocationPromoController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {

@interface LocationPromoController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	int					selectedRow;
	UITableView			*promosTableView;
	NSTimer				*timer;

	
#ifdef	PULL_REFRESH
	EGORefreshTableHeaderView *refreshHeaderView;
	BOOL _reloading;
#endif
	
}

@property	int selectedRow;
@property (nonatomic, retain) UITableView			*promosTableView;



#ifdef	PULL_REFRESH
@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;

- (void)reloadTableViewDataSource;
- (void)dataSourceDidFinishLoadingNewData;
#endif

@end
