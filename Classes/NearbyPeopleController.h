//
//  NearbyPeopleController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 2/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import	"EGORefreshTableHeaderView.h"


@interface NearbyPeopleController :  UIViewController <UITableViewDelegate, UITableViewDataSource>   {
	NSUInteger				selectedRow;
	NSIndexPath				*selectPath;
	UITableView				*peopleTableView;
	int						totalNumCells;
	UILabel					*loadMore;
	UIActivityIndicatorView *activityIndicator;
	NSTimer					*timer;
	
#ifdef	PULL_REFRESH
	EGORefreshTableHeaderView *refreshHeaderView;
	BOOL _reloading;
#endif
}
@property (nonatomic, retain) UITableView			*peopleTableView;
//@property (nonatomic, retain) RootViewController	*rootViewController;
@property NSUInteger								selectedRow;
@property (nonatomic, retain) NSIndexPath			*selectPath;



#ifdef	PULL_REFRESH
@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;

- (void)reloadTableViewDataSource;
- (void)dataSourceDidFinishLoadingNewData;
#endif


@end

