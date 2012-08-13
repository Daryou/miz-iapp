//
//  PostsViewController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 3/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import	"PostsViewCell.h"
#import	"PostsViewPhotoCell.h"
#import	"EGORefreshTableHeaderView.h"

@interface PostsViewController :  UIViewController <UITableViewDelegate, UITableViewDataSource>   {
	NSUInteger			selectedRow;
	NSIndexPath			*selectPath;
	int					totalNumCells;
	UILabel				*loadMore;
	UIActivityIndicatorView *activityIndicator;
	UITableView			*postsTableView;
	NSTimer				*timer;

#ifdef	PULL_REFRESH
	EGORefreshTableHeaderView *refreshHeaderView;
	BOOL _reloading;
#endif
	
}

@property (nonatomic, retain) UITableView			*postsTableView;
@property NSUInteger								selectedRow;
@property (nonatomic, retain) NSIndexPath			*selectPath;



#ifdef	PULL_REFRESH
@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;

- (void)reloadTableViewDataSource;
- (void)dataSourceDidFinishLoadingNewData;
#endif

@end

